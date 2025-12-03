<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PredictionLeaderboard extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'season_id',
        'round_id',
        'total_points',
        'total_predictions',
        'correct_scores',
        'correct_differences',
        'correct_winners',
        'rank',
    ];

    protected $casts = [
        'total_points' => 'integer',
        'total_predictions' => 'integer',
        'correct_scores' => 'integer',
        'correct_differences' => 'integer',
        'correct_winners' => 'integer',
        'rank' => 'integer',
    ];

    /**
     * User
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Round
     */
    public function round(): BelongsTo
    {
        return $this->belongsTo(Round::class);
    }

    /**
     * Get accuracy percentage
     */
    public function getAccuracyAttribute(): float
    {
        if ($this->total_predictions === 0) {
            return 0;
        }

        return round(($this->correct_scores / $this->total_predictions) * 100, 1);
    }

    /**
     * Update or create leaderboard entry for user
     */
    public static function updateForUser(User $user, ?Season $season = null, ?Round $round = null): void
    {
        $query = Prediction::where('user_id', $user->id)
            ->whereNotNull('calculated_at');

        if ($season) {
            $query->whereHas('match.round', function ($q) use ($season) {
                $q->where('season_id', $season->id);
            });
        }

        if ($round) {
            $query->whereHas('match', function ($q) use ($round) {
                $q->where('round_id', $round->id);
            });
        }

        $stats = $query->selectRaw('
            SUM(points_earned) as total_points,
            COUNT(*) as total_predictions,
            SUM(is_correct_score) as correct_scores,
            SUM(is_correct_difference) as correct_differences,
            SUM(is_correct_winner) as correct_winners
        ')->first();

        self::updateOrCreate([
            'user_id' => $user->id,
            'season_id' => $season?->id,
            'round_id' => $round?->id,
        ], [
            'total_points' => $stats->total_points ?? 0,
            'total_predictions' => $stats->total_predictions ?? 0,
            'correct_scores' => $stats->correct_scores ?? 0,
            'correct_differences' => $stats->correct_differences ?? 0,
            'correct_winners' => $stats->correct_winners ?? 0,
        ]);
    }

    /**
     * Recalculate ranks for a leaderboard
     */
    public static function recalculateRanks(?int $seasonId = null, ?int $roundId = null): void
    {
        $query = self::query();

        if ($seasonId) {
            $query->where('season_id', $seasonId);
        }

        if ($roundId) {
            $query->where('round_id', $roundId);
        }

        $entries = $query->orderByDesc('total_points')
            ->orderByDesc('correct_scores')
            ->get();

        $rank = 1;
        foreach ($entries as $entry) {
            $entry->rank = $rank++;
            $entry->save();
        }
    }
}
