<?php

namespace App\Jobs;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\PredictionLeaderboard;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class CalculatePredictionPoints implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public FootballMatch $match
    ) {}

    public function handle(): void
    {
        // Get all predictions for this match
        $predictions = Prediction::where('match_id', $this->match->id)->get();

        foreach ($predictions as $prediction) {
            $points = $prediction->calculatePoints();

            $prediction->update([
                'points_earned' => $points,
                'is_correct' => $points > 0,
                'is_perfect' => $prediction->predicted_home_score === $this->match->home_score
                    && $prediction->predicted_away_score === $this->match->away_score,
            ]);

            // Add points to user
            if ($points > 0) {
                $prediction->user->addPoints(
                    $points,
                    'prediction',
                    "Prediction points for {$this->match->homeTeam->name} vs {$this->match->awayTeam->name}",
                    $prediction
                );
            }

            // Update leaderboard
            $this->updateLeaderboard($prediction);
        }
    }

    private function updateLeaderboard(Prediction $prediction): void
    {
        $round = $this->match->round;
        $season = $round->season;

        // Update season leaderboard
        PredictionLeaderboard::updateOrCreate(
            [
                'user_id' => $prediction->user_id,
                'season_id' => $season->id,
            ],
            []
        )->increment('total_points', $prediction->points_earned);

        // Recalculate ranks
        $leaderboards = PredictionLeaderboard::where('season_id', $season->id)
            ->orderByDesc('total_points')
            ->orderBy('updated_at')
            ->get();

        $rank = 1;
        foreach ($leaderboards as $leaderboard) {
            $leaderboard->update(['rank' => $rank++]);
        }
    }
}
