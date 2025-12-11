<?php

namespace Database\Seeders;

use App\Models\ChampionPrediction;
use App\Models\ChampionPredictionLeaderboard;
use App\Models\SeasonChampion;
use App\Models\Season;
use App\Models\User;
use Illuminate\Database\Seeder;

class ChampionPredictionSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::all();
        $seasons = Season::with('teams')->get();

        if ($users->isEmpty() || $seasons->isEmpty()) {
            $this->command->info('No users or seasons found. Skipping ChampionPredictionSeeder.');
            return;
        }

        foreach ($seasons as $season) {
            $teams = $season->teams;
            
            if ($teams->isEmpty()) {
                continue;
            }

            // Create some champion predictions for each season
            $usersToPredict = $users->random(min($users->count(), rand(5, 15)));
            
            foreach ($usersToPredict as $user) {
                $team = $teams->random();
                
                ChampionPrediction::create([
                    'user_id' => $user->id,
                    'season_id' => $season->id,
                    'predicted_team_id' => $team->id,
                    'reason' => $this->getRandomReason($team->name),
                    'confidence_level' => rand(30, 95),
                    'points_wagered' => rand(1, 10) * 50,
                    'status' => 'pending',
                ]);
            }

            $this->command->info("Created champion predictions for season: {$season->name}");
        }

        // Create leaderboard entries
        $this->createLeaderboards();
    }

    private function getRandomReason(string $teamName): string
    {
        $reasons = [
            "Đội hình $teamName năm nay rất mạnh",
            "$teamName có phong độ tốt nhất giải",
            "Tin tưởng vào HLV của $teamName",
            "$teamName có lực lượng dày nhất",
            "Cầu thủ của $teamName đang ở đỉnh cao sự nghiệp",
            "$teamName có chiều sâu đội hình tốt",
            "Kinh nghiệm của $teamName sẽ giúp họ vô địch",
        ];

        return $reasons[array_rand($reasons)];
    }

    private function createLeaderboards(): void
    {
        $users = User::all();

        foreach ($users as $index => $user) {
            // All-time leaderboard
            ChampionPredictionLeaderboard::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'season_id' => null,
                ],
                [
                    'total_predictions' => rand(0, 10),
                    'correct_predictions' => rand(0, 3),
                    'total_points_wagered' => rand(100, 2000),
                    'total_points_earned' => rand(0, 3000),
                    'rank' => $index + 1,
                ]
            );
        }

        // Update ranks based on points earned
        $leaderboards = ChampionPredictionLeaderboard::whereNull('season_id')
            ->orderByDesc('total_points_earned')
            ->get();

        foreach ($leaderboards as $index => $leaderboard) {
            $leaderboard->update(['rank' => $index + 1]);
        }

        $this->command->info('Created champion prediction leaderboards');
    }
}
