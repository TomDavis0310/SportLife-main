<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Round extends Model
{
    use HasFactory;

    protected $fillable = [
        'season_id',
        'name',
        'round_number',
        'start_date',
        'end_date',
        'is_current',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_current' => 'boolean',
        'round_number' => 'integer',
    ];

    public function getNumberAttribute(): ?int
    {
        return $this->round_number;
    }

    public function setNumberAttribute($value): void
    {
        $this->attributes['round_number'] = $value;
    }

    /**
     * Round's season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Matches in this round
     */
    public function matches(): HasMany
    {
        return $this->hasMany(FootballMatch::class)->orderBy('match_date');
    }

    /**
     * Prediction leaderboards for this round
     */
    public function leaderboards(): HasMany
    {
        return $this->hasMany(PredictionLeaderboard::class);
    }

    /**
     * Get competition through season
     */
    public function getCompetitionAttribute()
    {
        return $this->season?->competition;
    }
}
