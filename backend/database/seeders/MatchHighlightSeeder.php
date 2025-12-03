<?php

namespace Database\Seeders;

use App\Models\FootballMatch;
use App\Models\MatchHighlight;
use Illuminate\Database\Seeder;
use Illuminate\Support\Arr;
use Illuminate\Support\Str;

class MatchHighlightSeeder extends Seeder
{
    public function run(): void
    {
        $matches = FootballMatch::finished()
            ->with(['homeTeam', 'awayTeam'])
            ->limit(12)
            ->get();

        if ($matches->isEmpty()) {
            return;
        }

        $videoLibrary = [
            [
                'label' => 'Toàn cảnh trận đấu',
                'provider' => 'YouTube',
                'video_id' => 'y6120QOlsfU',
                'duration_seconds' => 180,
                'description' => 'Xem lại toàn bộ diễn biến hấp dẫn nhất của trận đấu.',
            ],
            [
                'label' => 'Top 5 pha bóng',
                'provider' => 'YouTube',
                'video_id' => 'i1EG-MKy4so',
                'duration_seconds' => 150,
                'description' => 'Tổng hợp những pha bóng xuất sắc thay đổi cục diện trận đấu.',
            ],
            [
                'label' => 'Bàn thắng & Highlights',
                'provider' => 'YouTube',
                'video_id' => 'kXYiU_JCYtU',
                'duration_seconds' => 210,
                'description' => 'Các bàn thắng mãn nhãn cùng khoảnh khắc đáng chú ý.',
            ],
            [
                'label' => 'Khoảnh khắc định đoạt',
                'provider' => 'YouTube',
                'video_id' => '3YxaaGgTQYM',
                'duration_seconds' => 165,
                'description' => 'Khoảnh khắc then chốt mang tới chiến thắng cho đội bóng.',
            ],
        ];

        foreach ($matches as $match) {
            $videos = Arr::random($videoLibrary, rand(1, 2));

            foreach (Arr::wrap($videos) as $video) {
                $scoreDisplay = ($match->home_score !== null && $match->away_score !== null)
                    ? $match->home_score . ' - ' . $match->away_score
                    : 'vs';
                $title = sprintf('%s %s %s',
                    $match->homeTeam->name ?? 'Đội nhà',
                    $scoreDisplay,
                    $match->awayTeam->name ?? 'Đội khách'
                );

                MatchHighlight::create([
                    'match_id' => $match->id,
                    'title' => trim($title . ' - ' . $video['label']),
                    'description' => $video['description'],
                    'provider' => $video['provider'],
                    'video_url' => 'https://www.youtube.com/watch?v=' . $video['video_id'],
                    'thumbnail_url' => 'https://img.youtube.com/vi/' . $video['video_id'] . '/hqdefault.jpg',
                    'duration_seconds' => $video['duration_seconds'],
                    'published_at' => now()->subDays(rand(0, 5))->subHours(rand(1, 12)),
                    'is_featured' => (bool) rand(0, 1),
                    'view_count' => rand(2_500, 35_000),
                    'meta' => [
                        'video_id' => $video['video_id'],
                        'slug' => Str::slug(
                            ($match->homeTeam->name ?? 'doi-nha') . '-' .
                            ($match->awayTeam->name ?? 'doi-khach') . '-' .
                            $video['label']
                        ),
                    ],
                ]);
            }
        }
    }
}
