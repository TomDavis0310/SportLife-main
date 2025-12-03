<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class Prediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'match_id',
        'home_score',
        'away_score',
        'first_scorer_id',
        'points_earned',
        'is_correct_score',
        'is_correct_difference',
        'is_correct_winner',
        'is_correct_scorer',
        'streak_multiplier',
        'calculated_at',
    ];

    protected $casts = [
        'home_score' => 'integer',
        'away_score' => 'integer',
        'points_earned' => 'integer',
        'is_correct_score' => 'boolean',
        'is_correct_difference' => 'boolean',
        'is_correct_winner' => 'boolean',
        'is_correct_scorer' => 'boolean',
        'streak_multiplier' => 'decimal:2',
        'calculated_at' => 'datetime',
    ];

    /**
     * Prediction's user
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Prediction's match
     */
    public function match(): BelongsTo
    {
        return $this->belongsTo(FootballMatch::class, 'match_id');
    }

    /**
     * Predicted first scorer
     */
    public function firstScorer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'first_scorer_id');
    }

    /**
     * Comments on this prediction
     */
    public function comments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    /**
     * Likes on this prediction
     */
    public function likes(): MorphMany
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get predicted winner: 'home', 'away', 'draw'
     */
    public function getPredictedWinnerAttribute(): string
    {
        if ($this->home_score > $this->away_score) {
            return 'home';
        } elseif ($this->away_score > $this->home_score) {
            return 'away';
        }
        return 'draw';
    }

    /**
     * Get predicted goal difference
     */
    public function getPredictedDifferenceAttribute(): int
    {
        return abs($this->home_score - $this->away_score);
    }

    /**
     * Check if prediction has been calculated
     */
    public function getIsCalculatedAttribute(): bool
    {
        return $this->calculated_at !== null;
    }

    /**
     * Calculate points for this prediction
     */
    public function calculatePoints(): int
    {
        $match = $this->match;

        if (!$match->is_finished) {
            return 0;
        }

        $points = 0;

        // Check exact score (50 points)
        if ($this->home_score === $match->home_score && $this->away_score === $match->away_score) {
            $this->is_correct_score = true;
            $points += 50;
        }

        // Check goal difference (30 points)
        if ($this->predicted_difference === abs($match->goal_difference)) {
            $this->is_correct_difference = true;
            $points += 30;
        }

        // Check winner (15 points)
        if ($this->predicted_winner === $match->winner) {
            $this->is_correct_winner = true;
            $points += 15;
        }

        // Check first scorer (20 points)
        if ($this->first_scorer_id && $this->first_scorer_id === $match->first_scorer_id) {
            $this->is_correct_scorer = true;
            $points += 20;
        }

        // Apply streak multiplier
        $points = (int) round($points * $this->streak_multiplier);

        $this->points_earned = $points;
        $this->calculated_at = now();
        $this->save();

        return $points;
    }

    /**
     * Get display prediction
     */
    public function getDisplayPredictionAttribute(): string
    {
        return "{$this->home_score} - {$this->away_score}";
    }

    /**
     * Scope for uncalculated predictions
     */
    public function scopeUncalculated($query)
    {
        return $query->whereNull('calculated_at');
    }

    /**
     * Scope for a specific user
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }
}
