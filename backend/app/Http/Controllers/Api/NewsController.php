<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NewsResource;
use App\Http\Resources\CommentResource;
use App\Models\News;
use App\Models\Comment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NewsController extends Controller
{
    /**
     * List news articles
     */
    public function index(Request $request): JsonResponse
    {
        $query = News::published()->with(['author', 'team']);

        // Filter by category
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter by team
        if ($request->filled('team_id')) {
            $query->where('team_id', $request->team_id);
        }

        // Filter by competition
        if ($request->filled('competition_id')) {
            $query->where('competition_id', $request->competition_id);
        }

        // Search
        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('title', 'like', "%{$request->search}%")
                    ->orWhere('content', 'like', "%{$request->search}%");
            });
        }

        $news = $query->orderByDesc('published_at')->paginate(20);

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
     * Get featured news
     */
    public function featured(): JsonResponse
    {
        $news = News::published()
            ->featured()
            ->with(['author', 'team', 'competition'])
            ->orderByDesc('published_at')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => NewsResource::collection($news),
        ]);
    }

    /**
     * Show news article
     */
    public function show(News $news): JsonResponse
    {
        if (!$news->is_published) {
            return response()->json([
                'success' => false,
                'message' => 'News not found',
            ], 404);
        }

        // Increment view count
        $news->increment('views_count');

        $news->load(['author', 'team']);
        $news->loadCount(['comments', 'likes']);

        return response()->json([
            'success' => true,
            'data' => new NewsResource($news),
        ]);
    }

    /**
     * Get comments for a news article
     */
    public function comments(News $news): JsonResponse
    {
        $comments = $news->comments()
            ->with('user')
            ->whereNull('parent_id')
            ->orderByDesc('created_at')
            ->paginate(20);

        // Load replies for each comment
        $comments->load('replies.user');

        return response()->json([
            'success' => true,
            'data' => CommentResource::collection($comments),
        ]);
    }

    /**
     * Add comment to news
     */
    public function addComment(Request $request, News $news): JsonResponse
    {
        $request->validate([
            'content' => 'required|string|max:1000',
            'parent_id' => 'nullable|exists:comments,id',
        ]);

        $comment = $news->comments()->create([
            'user_id' => $request->user()->id,
            'content' => $request->content,
            'parent_id' => $request->parent_id,
        ]);

        $comment->load('user');

        // Award points for commenting
        $request->user()->addPoints(
            config('sportlife.points.comment', 2),
            'comment',
            'Commented on news',
            $news
        );

        return response()->json([
            'success' => true,
            'message' => 'Comment added successfully',
            'data' => new CommentResource($comment),
        ], 201);
    }

    /**
     * Delete comment
     */
    public function deleteComment(Comment $comment, Request $request): JsonResponse
    {
        if ($comment->user_id !== $request->user()->id && !$request->user()->hasRole('admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $comment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Comment deleted successfully',
        ]);
    }

    /**
     * Like a news article
     */
    public function like(News $news, Request $request): JsonResponse
    {
        $user = $request->user();

        if ($news->isLikedBy($user)) {
            return response()->json([
                'success' => false,
                'message' => 'Already liked',
            ], 422);
        }

        $news->likes()->create([
            'user_id' => $user->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'News liked successfully',
            'data' => [
                'likes_count' => $news->likes()->count(),
            ],
        ]);
    }

    /**
     * Unlike a news article
     */
    public function unlike(News $news, Request $request): JsonResponse
    {
        $news->likes()->where('user_id', $request->user()->id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'News unliked successfully',
            'data' => [
                'likes_count' => $news->likes()->count(),
            ],
        ]);
    }

    /**
     * Get related news
     */
    public function related(News $news): JsonResponse
    {
        $related = News::published()
            ->where('id', '!=', $news->id)
            ->where(function ($query) use ($news) {
                $query->where('category', $news->category)
                    ->orWhere('team_id', $news->team_id)
                    ->orWhere('competition_id', $news->competition_id);
            })
            ->with(['author', 'team'])
            ->orderByDesc('published_at')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => NewsResource::collection($related),
        ]);
    }
}
