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
        'predicted_outcome', // 'home', 'draw', 'away'
        'points_earned',
        'is_correct_outcome',
        'streak_multiplier',
        'calculated_at',
    ];

    protected $casts = [
        'points_earned' => 'integer',
        'is_correct_outcome' => 'boolean',
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
     * Get predicted outcome label
     */
    public function getPredictedOutcomeLabelAttribute(): string
    {
        return match($this->predicted_outcome) {
            'home' => 'Đội nhà thắng',
            'draw' => 'Hòa',
            'away' => 'Đội khách thắng',
            default => 'Chưa dự đoán',
        };
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

        // Determine actual match outcome
        $actualOutcome = 'draw';
        if ($match->home_score > $match->away_score) {
            $actualOutcome = 'home';
        } elseif ($match->away_score > $match->home_score) {
            $actualOutcome = 'away';
        }

        // Check if prediction is correct (10 points)
        if ($this->predicted_outcome === $actualOutcome) {
            $this->is_correct_outcome = true;
            $points = 10;
        } else {
            $this->is_correct_outcome = false;
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
        return $this->predicted_outcome_label;
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
