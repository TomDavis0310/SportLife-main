<?php

namespace Database\Seeders;

use App\Models\PredictionLeaderboard;
use App\Models\User;
use App\Models\Season;
use App\Models\Round;
use Illuminate\Database\Seeder;

class PredictionLeaderboardSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::all();
        
        if ($users->isEmpty()) {
            return;
        }

        // Create All-Time Leaderboard
        foreach ($users as $index => $user) {
            PredictionLeaderboard::create([
                'user_id' => $user->id,
                'season_id' => null,
                'round_id' => null,
                'total_points' => rand(10, 500),
                'total_predictions' => rand(5, 50),
                'correct_scores' => rand(0, 10),
                'correct_differences' => rand(0, 15),
                'correct_winners' => rand(0, 20),
                'rank' => $index + 1,
            ]);
        }

        // Create Season Leaderboard (for the first season found)
        $season = Season::where('is_current', true)->first() ?? Season::first();
        if ($season) {
            foreach ($users as $index => $user) {
                PredictionLeaderboard::create([
                    'user_id' => $user->id,
                    'season_id' => $season->id,
                    'round_id' => null,
                    'total_points' => rand(5, 200),
                    'total_predictions' => rand(2, 20),
                    'correct_scores' => rand(0, 5),
                    'correct_differences' => rand(0, 8),
                    'correct_winners' => rand(0, 10),
                    'rank' => $index + 1,
                ]);
            }

            // Create Weekly Leaderboard (for the current round)
            // First, ensure there is a current round
            $currentDate = now();
            $currentRound = Round::where('season_id', $season->id)
                ->where('start_date', '<=', $currentDate)
                ->where('end_date', '>=', $currentDate)
                ->first();
            
            // If no round matches current date, just pick the 15th round (approx Dec)
            if (!$currentRound) {
                $currentRound = Round::where('season_id', $season->id)
                    ->where('round_number', 15)
                    ->first();
            }

            if ($currentRound) {
                // Mark as current round
                Round::where('is_current', true)->update(['is_current' => false]);
                $currentRound->update(['is_current' => true]);

                foreach ($users as $index => $user) {
                    PredictionLeaderboard::create([
                        'user_id' => $user->id,
                        'season_id' => null,
                        'round_id' => $currentRound->id,
                        'total_points' => rand(0, 50),
                        'total_predictions' => rand(1, 5),
                        'correct_scores' => rand(0, 2),
                        'correct_differences' => rand(0, 3),
                        'correct_winners' => rand(0, 4),
                        'rank' => $index + 1,
                    ]);
                }
            }
        }
    }
}
