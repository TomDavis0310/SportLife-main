<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SeasonChampion extends Model
{
    use HasFactory;

    protected $fillable = [
        'season_id',
        'champion_team_id',
        'confirmed_at',
    ];

    protected $casts = [
        'confirmed_at' => 'datetime',
    ];

    /**
     * Season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Champion team
     */
    public function championTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'champion_team_id');
    }

    /**
     * Calculate points for all predictions when champion is confirmed
     */
    public function calculateAllPredictions(): void
    {
        $predictions = ChampionPrediction::where('season_id', $this->season_id)
            ->where('status', ChampionPrediction::STATUS_PENDING)
            ->get();

        foreach ($predictions as $prediction) {
            $points = $prediction->calculatePoints();
            
            // Update user sport points
            if ($points > 0) {
                $prediction->user->addPoints($points, 'champion_prediction_win', 
                    "Dự đoán đúng đội vô địch mùa giải {$this->season->name}");
            }

            // Update leaderboard
            $this->updateLeaderboard($prediction);
        }
    }

    /**
     * Update champion prediction leaderboard
     */
    private function updateLeaderboard(ChampionPrediction $prediction): void
    {
        // Update season leaderboard
        $leaderboard = ChampionPredictionLeaderboard::firstOrCreate(
            [
                'user_id' => $prediction->user_id,
                'season_id' => $prediction->season_id,
            ],
            [
                'total_predictions' => 0,
                'correct_predictions' => 0,
                'total_points_wagered' => 0,
                'total_points_earned' => 0,
            ]
        );

        $leaderboard->increment('total_predictions');
        $leaderboard->increment('total_points_wagered', $prediction->points_wagered);
        
        if ($prediction->status === ChampionPrediction::STATUS_WON) {
            $leaderboard->increment('correct_predictions');
            $leaderboard->increment('total_points_earned', $prediction->points_earned);
        }

        // Update all-time leaderboard
        $allTimeLeaderboard = ChampionPredictionLeaderboard::firstOrCreate(
            [
                'user_id' => $prediction->user_id,
                'season_id' => null,
            ],
            [
                'total_predictions' => 0,
                'correct_predictions' => 0,
                'total_points_wagered' => 0,
                'total_points_earned' => 0,
            ]
        );

        $allTimeLeaderboard->increment('total_predictions');
        $allTimeLeaderboard->increment('total_points_wagered', $prediction->points_wagered);
        
        if ($prediction->status === ChampionPrediction::STATUS_WON) {
            $allTimeLeaderboard->increment('correct_predictions');
            $allTimeLeaderboard->increment('total_points_earned', $prediction->points_earned);
        }

        // Update ranks
        $this->updateRanks($prediction->season_id);
    }

    /**
     * Update leaderboard ranks
     */
    private function updateRanks(?int $seasonId): void
    {
        $leaderboards = ChampionPredictionLeaderboard::where('season_id', $seasonId)
            ->orderByDesc('total_points_earned')
            ->orderByDesc('correct_predictions')
            ->get();

        foreach ($leaderboards as $index => $leaderboard) {
            $leaderboard->update(['rank' => $index + 1]);
        }
    }
}
