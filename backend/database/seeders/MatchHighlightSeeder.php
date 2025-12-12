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
                'label' => 'Liverpool vs Man Utd (7-0)',
                'provider' => 'YouTube',
                'video_id' => 'iBuTEywEQ6U',
                'duration_seconds' => 134,
                'description' => 'Highlights trận thắng lịch sử 7-0 của Liverpool trước Manchester United tại Anfield.',
            ],
            [
                'label' => 'Man City vs Arsenal (4-1)',
                'provider' => 'YouTube',
                'video_id' => 'o3Dadq-qLpw',
                'duration_seconds' => 615,
                'description' => 'Man City đánh bại Arsenal 4-1 trong trận cầu quyết định ngôi vô địch Premier League.',
            ],
            [
                'label' => 'Vietnam vs Thailand (2-2)',
                'provider' => 'YouTube',
                'video_id' => 'eQ4Z7z_UZIU',
                'duration_seconds' => 544,
                'description' => 'Trận chung kết lượt đi kịch tính giữa Việt Nam và Thái Lan trên sân Mỹ Đình.',
            ],
            [
                'label' => 'Hanoi FC vs Viettel',
                'provider' => 'YouTube',
                'video_id' => 'dzWVZEPvd20',
                'duration_seconds' => 600,
                'description' => 'Trận derby Thủ đô căng thẳng và hấp dẫn giữa Hà Nội FC và Viettel.',
            ],
            [
                'label' => 'Tottenham vs Chelsea (1-4)',
                'provider' => 'YouTube',
                'video_id' => '5QUu1LBneyw',
                'duration_seconds' => 185,
                'description' => 'Trận đấu điên rồ với 5 bàn thắng và 2 thẻ đỏ dành cho Tottenham.',
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
