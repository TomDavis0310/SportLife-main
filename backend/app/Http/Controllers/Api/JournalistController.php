<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NewsResource;
use App\Models\News;
use App\Services\NewsScraperService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class JournalistController extends Controller
{
    protected NewsScraperService $scraperService;

    public function __construct(NewsScraperService $scraperService)
    {
        $this->scraperService = $scraperService;
    }

    /**
     * Lấy danh sách bài viết của journalist
     */
    public function myArticles(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = News::where('author_id', $user->id)
            ->with(['team'])
            ->orderByDesc('created_at');

        // Filter by status
        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            }
        }

        // Filter by category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Search
        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('title', 'like', "%{$request->search}%")
                    ->orWhere('content', 'like', "%{$request->search}%");
            });
        }

        $news = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => NewsResource::collection($news),
            'meta' => [
                'current_page' => $news->currentPage(),
                'last_page' => $news->lastPage(),
                'total' => $news->total(),
            ],
        ]);
    }

    /**
     * Tạo bài viết mới
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'content' => 'required|string',
            'content_en' => 'nullable|string',
            'excerpt' => 'nullable|string|max:500',
            'category' => 'required|in:hot_news,highlight,interview,team_news,transfer',
            'team_id' => 'nullable|exists:teams,id',
            'video_url' => 'nullable|url',
            'thumbnail' => 'nullable|image|max:5120',
            'is_featured' => 'boolean',
            'is_published' => 'boolean',
            'published_at' => 'nullable|date',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ]);

        $validated['author_id'] = $request->user()->id;
        $validated['slug'] = Str::slug($validated['title']) . '-' . time();

        // Set default values
        $isPublished = filter_var($validated['is_published'] ?? false, FILTER_VALIDATE_BOOLEAN);
        $validated['is_published'] = $isPublished;
        $validated['published_at'] = $isPublished ? now() : null;
        $validated['is_auto_fetched'] = false;

        // Handle thumbnail upload
        if ($request->hasFile('thumbnail')) {
            $path = $request->file('thumbnail')->store('news', 'public');
            $validated['thumbnail'] = Storage::url($path);
        }

        $news = News::create($validated);
        $news->load(['author', 'team']);

        return response()->json([
            'success' => true,
            'message' => 'Bài viết đã được tạo thành công',
            'data' => new NewsResource($news),
        ], 201);
    }

    /**
     * Cập nhật bài viết
     */
    public function update(Request $request, News $news): JsonResponse
    {
        // Kiểm tra quyền sở hữu
        if ($news->author_id !== $request->user()->id && !$request->user()->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền chỉnh sửa bài viết này',
            ], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'content' => 'sometimes|string',
            'content_en' => 'nullable|string',
            'excerpt' => 'nullable|string|max:500',
            'category' => 'sometimes|in:hot_news,highlight,interview,team_news,transfer',
            'team_id' => 'nullable|exists:teams,id',
            'video_url' => 'nullable|url',
            'thumbnail' => 'nullable|image|max:5120',
            'is_featured' => 'boolean',
            'is_published' => 'boolean',
            'published_at' => 'nullable|date',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ]);

        // Handle thumbnail upload
        if ($request->hasFile('thumbnail')) {
            // Delete old thumbnail if exists
            if ($news->thumbnail && !Str::startsWith($news->thumbnail, 'http')) {
                Storage::delete(str_replace('/storage/', 'public/', $news->thumbnail));
            }
            
            $path = $request->file('thumbnail')->store('news', 'public');
            $validated['thumbnail'] = Storage::url($path);
        }

        // Update slug if title changed
        if (isset($validated['title']) && $validated['title'] !== $news->title) {
            $validated['slug'] = Str::slug($validated['title']) . '-' . time();
        }

        // Set published_at if publishing for the first time
        if (isset($validated['is_published']) && $validated['is_published'] && !$news->is_published) {
            $validated['published_at'] = $validated['published_at'] ?? now();
        }

        $news->update($validated);
        $news->load(['author', 'team']);

        return response()->json([
            'success' => true,
            'message' => 'Bài viết đã được cập nhật',
            'data' => new NewsResource($news),
        ]);
    }

    /**
     * Xóa bài viết
     */
    public function destroy(Request $request, News $news): JsonResponse
    {
        // Kiểm tra quyền sở hữu
        if ($news->author_id !== $request->user()->id && !$request->user()->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền xóa bài viết này',
            ], 403);
        }

        // Delete thumbnail if exists
        if ($news->thumbnail && !Str::startsWith($news->thumbnail, 'http')) {
            Storage::delete(str_replace('/storage/', 'public/', $news->thumbnail));
        }

        $news->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bài viết đã được xóa',
        ]);
    }

    /**
     * Xuất bản/Hủy xuất bản bài viết
     */
    public function togglePublish(Request $request, News $news): JsonResponse
    {
        // Kiểm tra quyền sở hữu
        if ($news->author_id !== $request->user()->id && !$request->user()->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền thay đổi trạng thái bài viết này',
            ], 403);
        }

        $news->is_published = !$news->is_published;
        
        if ($news->is_published && !$news->published_at) {
            $news->published_at = now();
        }
        
        $news->save();

        return response()->json([
            'success' => true,
            'message' => $news->is_published ? 'Bài viết đã được xuất bản' : 'Bài viết đã được gỡ xuống',
            'data' => new NewsResource($news),
        ]);
    }

    /**
     * Lấy thống kê bài viết
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();

        $stats = [
            'total_articles' => News::where('author_id', $user->id)->count(),
            'published_articles' => News::where('author_id', $user->id)->where('is_published', true)->count(),
            'draft_articles' => News::where('author_id', $user->id)->where('is_published', false)->count(),
            'featured_articles' => News::where('author_id', $user->id)->where('is_featured', true)->count(),
            'total_views' => News::where('author_id', $user->id)->sum('views_count'),
            'articles_today' => News::where('author_id', $user->id)->whereDate('created_at', today())->count(),
            'articles_this_week' => News::where('author_id', $user->id)->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])->count(),
            'articles_this_month' => News::where('author_id', $user->id)->whereMonth('created_at', now()->month)->count(),
            'by_category' => News::where('author_id', $user->id)
                ->selectRaw('category, count(*) as count')
                ->groupBy('category')
                ->pluck('count', 'category'),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Fetch tin tức tự động từ các nguồn
     */
    public function fetchNews(Request $request): JsonResponse
    {
        // Kiểm tra quyền
        if (!$request->user()->hasPermissionTo('news.scrape') && !$request->user()->hasRole(['admin', 'journalist'])) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền thực hiện chức năng này',
            ], 403);
        }

        $validated = $request->validate([
            'source' => 'nullable|string',
        ]);

        try {
            if (isset($validated['source'])) {
                $results = $this->scraperService->fetchFromSourceByName($validated['source']);
            } else {
                $results = $this->scraperService->fetchAllNews();
            }

            return response()->json([
                'success' => true,
                'message' => "Đã fetch {$results['success']} bài viết mới, bỏ qua {$results['skipped']} bài đã tồn tại",
                'data' => $results,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi fetch tin tức: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Lấy danh sách nguồn tin
     */
    public function getSources(): JsonResponse
    {
        $sources = $this->scraperService->getAvailableSources();

        return response()->json([
            'success' => true,
            'data' => $sources,
        ]);
    }

    /**
     * Lấy danh sách bài viết auto-fetched
     */
    public function autoFetchedNews(Request $request): JsonResponse
    {
        $query = News::autoFetched()
            ->with(['author', 'team'])
            ->orderByDesc('fetched_at');

        // Filter by source
        if ($request->filled('source')) {
            $query->fromSource($request->source);
        }

        // Filter by date
        if ($request->filled('date')) {
            $query->whereDate('fetched_at', $request->date);
        }

        $news = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => NewsResource::collection($news),
            'meta' => [
                'current_page' => $news->currentPage(),
                'last_page' => $news->lastPage(),
                'total' => $news->total(),
            ],
        ]);
    }

    /**
     * Dọn dẹp tin cũ
     */
    public function cleanOldNews(Request $request): JsonResponse
    {
        if (!$request->user()->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Chỉ admin mới có quyền thực hiện chức năng này',
            ], 403);
        }

        $daysOld = $request->input('days', 30);
        $count = $this->scraperService->cleanOldAutoFetchedNews($daysOld);

        return response()->json([
            'success' => true,
            'message' => "Đã xóa {$count} bài viết cũ hơn {$daysOld} ngày",
        ]);
    }
}
