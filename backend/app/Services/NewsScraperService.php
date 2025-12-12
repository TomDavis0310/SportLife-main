<?php

namespace App\Services;

use App\Models\News;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Carbon\Carbon;

class NewsScraperService
{
    /**
     * Các nguồn tin tức thể thao chính thống
     */
    protected array $sources = [
        'vnexpress' => [
            'name' => 'VnExpress',
            'rss_url' => 'https://vnexpress.net/rss/the-thao.rss',
            'base_url' => 'https://vnexpress.net',
            'logo' => 'https://s1.vnecdn.net/vnexpress/restruct/i/v9505/v2_2019/pc/graphics/logo.svg',
        ],
        'thanhnien' => [
            'name' => 'Thanh Niên',
            'rss_url' => 'https://thanhnien.vn/rss/the-thao.rss',
            'base_url' => 'https://thanhnien.vn',
            'logo' => 'https://static.thanhnien.vn/thanhnien.vn/image/logo-tn.svg',
        ],
        'tuoitre' => [
            'name' => 'Tuổi Trẻ',
            'rss_url' => 'https://tuoitre.vn/rss/the-thao.rss',
            'base_url' => 'https://tuoitre.vn',
            'logo' => 'https://static.tuoitre.vn/tto/i/s/logo/logo-tuoitre.svg',
        ],
        'bongdaplus' => [
            'name' => 'Bóng Đá Plus',
            'rss_url' => 'https://bongdaplus.vn/rss/trang-chu.rss',
            'base_url' => 'https://bongdaplus.vn',
            'logo' => 'https://bongdaplus.vn/images/logo-bdp.png',
        ],
        'bongda24h' => [
            'name' => 'Bongda24h',
            'rss_url' => 'https://bongda24h.vn/rss/bong-da-viet-nam.rss',
            'base_url' => 'https://bongda24h.vn',
            'logo' => 'https://bongda24h.vn/images/logo.png',
        ],
    ];

    /**
     * Các từ khóa thể thao để lọc tin
     */
    protected array $sportsKeywords = [
        'bóng đá', 'football', 'soccer', 'V-League', 'V.League', 'Premier League',
        'La Liga', 'Serie A', 'Bundesliga', 'Champions League', 'World Cup',
        'Euro', 'AFF Cup', 'SEA Games', 'ASIAD', 'Olympic',
        'đội tuyển', 'cầu thủ', 'HLV', 'huấn luyện viên', 'bàn thắng', 'penalty',
        'thẻ đỏ', 'thẻ vàng', 'chuyển nhượng', 'hợp đồng',
        'tennis', 'basketball', 'bóng rổ', 'F1', 'Formula 1',
        'MMA', 'boxing', 'võ thuật', 'golf', 'marathon', 'điền kinh',
        'bơi lội', 'cầu lông', 'badminton', 'bóng chuyền', 'volleyball',
    ];

    /**
     * Fetch tin tức từ tất cả các nguồn
     */
    public function fetchAllNews(): array
    {
        $results = [
            'success' => 0,
            'failed' => 0,
            'skipped' => 0,
            'errors' => [],
        ];

        foreach ($this->sources as $sourceKey => $source) {
            try {
                $sourceResult = $this->fetchFromSource($sourceKey, $source);
                $results['success'] += $sourceResult['success'];
                $results['skipped'] += $sourceResult['skipped'];
            } catch (\Exception $e) {
                $results['failed']++;
                $results['errors'][] = "{$source['name']}: " . $e->getMessage();
                Log::error("News fetch failed for {$source['name']}", [
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);
            }
        }

        return $results;
    }

    /**
     * Fetch tin tức từ một nguồn cụ thể
     */
    public function fetchFromSource(string $sourceKey, array $source): array
    {
        $results = ['success' => 0, 'skipped' => 0];
        
        try {
            $response = Http::timeout(30)->get($source['rss_url']);
            
            if (!$response->successful()) {
                throw new \Exception("HTTP error: " . $response->status());
            }

            $xml = simplexml_load_string($response->body());
            
            if ($xml === false) {
                throw new \Exception("Failed to parse RSS XML");
            }

            $items = $xml->channel->item ?? [];
            $systemAuthor = $this->getSystemAuthor();

            foreach ($items as $item) {
                $title = (string) $item->title;
                $link = (string) $item->link;
                $description = (string) $item->description;
                $pubDate = (string) $item->pubDate;

                // Kiểm tra xem có phải tin thể thao không
                if (!$this->isSportsNews($title, $description)) {
                    continue;
                }

                // Kiểm tra tin đã tồn tại chưa
                if ($this->newsExists($link, $title)) {
                    $results['skipped']++;
                    continue;
                }

                // Tạo tin mới
                $news = $this->createNewsFromItem([
                    'title' => $title,
                    'link' => $link,
                    'description' => $description,
                    'pubDate' => $pubDate,
                    'source' => $source,
                    'sourceKey' => $sourceKey,
                ], $systemAuthor);

                if ($news) {
                    $results['success']++;
                }
            }

        } catch (\Exception $e) {
            Log::error("Error fetching from {$source['name']}", [
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }

        return $results;
    }

    /**
     * Kiểm tra xem tin tức có liên quan đến thể thao không
     */
    protected function isSportsNews(string $title, string $description): bool
    {
        $text = strtolower($title . ' ' . $description);
        
        foreach ($this->sportsKeywords as $keyword) {
            if (Str::contains($text, strtolower($keyword))) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Kiểm tra tin đã tồn tại chưa
     */
    protected function newsExists(string $url, string $title): bool
    {
        return News::where('original_url', $url)
            ->orWhere('title', $title)
            ->exists();
    }

    /**
     * Lấy user hệ thống để làm author
     */
    protected function getSystemAuthor(): User
    {
        // Tìm user journalist hoặc admin
        $author = User::whereHas('roles', function ($query) {
            $query->whereIn('name', ['journalist', 'admin']);
        })->first();

        if (!$author) {
            // Fallback: lấy admin đầu tiên
            $author = User::whereHas('roles', function ($query) {
                $query->where('name', 'admin');
            })->first();
        }

        if (!$author) {
            // Fallback cuối cùng: tạo system user
            $author = User::firstOrCreate(
                ['email' => 'system@sportlife.vn'],
                [
                    'name' => 'SportLife News Bot',
                    'password' => bcrypt(Str::random(32)),
                ]
            );
        }

        return $author;
    }

    /**
     * Tạo news từ RSS item
     */
    protected function createNewsFromItem(array $item, User $author): ?News
    {
        try {
            // Clean HTML từ description
            $excerpt = strip_tags($item['description']);
            $excerpt = html_entity_decode($excerpt);
            $excerpt = Str::limit($excerpt, 500);

            // Parse publish date
            $publishedAt = null;
            if (!empty($item['pubDate'])) {
                try {
                    $publishedAt = Carbon::parse($item['pubDate']);
                } catch (\Exception $e) {
                    $publishedAt = now();
                }
            }

            // Xác định category dựa trên nội dung
            $category = $this->detectCategory($item['title'], $excerpt);

            // Tìm thumbnail từ description (nếu có)
            $thumbnail = $this->extractThumbnail($item['description']);

            // Tạo tags từ title
            $tags = $this->generateTags($item['title']);

            $news = News::create([
                'author_id' => $author->id,
                'title' => Str::limit($item['title'], 255),
                'slug' => Str::slug($item['title']) . '-' . time() . '-' . Str::random(5),
                'content' => $this->formatContent($excerpt, $item['link'], $item['source']['name']),
                'thumbnail' => $thumbnail,
                'category' => $category,
                'is_featured' => false,
                'is_published' => true,
                'published_at' => $publishedAt ?? now(),
                'source_name' => $item['source']['name'],
                'source_url' => $item['source']['base_url'],
                'original_url' => $item['link'],
                'is_auto_fetched' => true,
                'fetched_at' => now(),
                'tags' => $tags,
            ]);

            Log::info("Created news from {$item['source']['name']}", [
                'news_id' => $news->id,
                'title' => $news->title,
            ]);

            return $news;

        } catch (\Exception $e) {
            Log::error("Failed to create news", [
                'title' => $item['title'] ?? 'Unknown',
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Phát hiện category từ nội dung
     */
    protected function detectCategory(string $title, string $content): string
    {
        $text = strtolower($title . ' ' . $content);

        if (Str::contains($text, ['chuyển nhượng', 'transfer', 'ký hợp đồng', 'gia nhập', 'rời'])) {
            return 'transfer';
        }

        if (Str::contains($text, ['highlight', 'bàn thắng', 'goal', 'kết quả', 'tỉ số'])) {
            return 'highlight';
        }

        if (Str::contains($text, ['phỏng vấn', 'interview', 'chia sẻ', 'tiết lộ', 'tâm sự'])) {
            return 'interview';
        }

        if (Str::contains($text, ['clb', 'đội bóng', 'câu lạc bộ'])) {
            return 'team_news';
        }

        return 'hot_news';
    }

    /**
     * Trích xuất thumbnail từ HTML
     */
    protected function extractThumbnail(string $html): ?string
    {
        // Tìm img tag
        if (preg_match('/<img[^>]+src=["\']([^"\']+)["\']/', $html, $matches)) {
            return $matches[1];
        }

        // Tìm enclosure (trong RSS)
        if (preg_match('/enclosure[^>]+url=["\']([^"\']+)["\']/', $html, $matches)) {
            return $matches[1];
        }

        return null;
    }

    /**
     * Format nội dung với nguồn
     */
    protected function formatContent(string $excerpt, string $originalUrl, string $sourceName): string
    {
        $footer = "\n\n---\n\n📰 *Nguồn: [{$sourceName}]({$originalUrl})*\n\n*Bài viết được tổng hợp tự động từ các nguồn tin uy tín.*";
        
        return $excerpt . $footer;
    }

    /**
     * Tạo tags từ title
     */
    protected function generateTags(string $title): array
    {
        $tags = [];
        
        // Các từ khóa phổ biến
        $commonTags = [
            'V-League' => ['v-league', 'v.league', 'vleague'],
            'Premier League' => ['premier league', 'ngoại hạng anh'],
            'Champions League' => ['champions league', 'cúp c1', 'cup c1'],
            'Đội tuyển Việt Nam' => ['đội tuyển việt nam', 'tuyển việt nam', 'dtqg'],
            'World Cup' => ['world cup', 'world-cup'],
            'Chuyển nhượng' => ['chuyển nhượng', 'transfer'],
        ];

        $lowerTitle = strtolower($title);
        
        foreach ($commonTags as $tag => $keywords) {
            foreach ($keywords as $keyword) {
                if (Str::contains($lowerTitle, $keyword)) {
                    $tags[] = $tag;
                    break;
                }
            }
        }

        return array_unique($tags);
    }

    /**
     * Fetch tin tức từ một nguồn theo tên
     */
    public function fetchFromSourceByName(string $sourceName): array
    {
        $sourceKey = strtolower($sourceName);
        
        if (!isset($this->sources[$sourceKey])) {
            throw new \InvalidArgumentException("Source '{$sourceName}' not found");
        }

        return $this->fetchFromSource($sourceKey, $this->sources[$sourceKey]);
    }

    /**
     * Lấy danh sách các nguồn tin
     */
    public function getAvailableSources(): array
    {
        return array_map(function ($source, $key) {
            return [
                'key' => $key,
                'name' => $source['name'],
                'url' => $source['base_url'],
            ];
        }, $this->sources, array_keys($this->sources));
    }

    /**
     * Xóa tin cũ (quá 30 ngày)
     */
    public function cleanOldAutoFetchedNews(int $daysOld = 30): int
    {
        $count = News::autoFetched()
            ->where('created_at', '<', now()->subDays($daysOld))
            ->where('is_featured', false)
            ->delete();

        Log::info("Cleaned {$count} old auto-fetched news articles");
        
        return $count;
    }
}
