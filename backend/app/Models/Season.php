<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Season extends Model
{
    use HasFactory;

    protected $fillable = [
        'competition_id',
        'name',
        'start_date',
        'end_date',
        'is_current',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_current' => 'boolean',
    ];

    /**
     * Season's competition
     */
    public function competition(): BelongsTo
    {
        return $this->belongsTo(Competition::class);
    }

    /**
     * Teams in this season
     */
    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class, 'season_teams')
            ->withPivot('status')
            ->withTimestamps();
    }

    /**
     * Season rounds
     */
    public function rounds(): HasMany
    {
        return $this->hasMany(Round::class);
    }

    /**
     * Current round
     */
    public function currentRound(): HasMany
    {
        return $this->hasMany(Round::class)->where('is_current', true);
    }

    /**
     * Season standings
     */
    public function standings(): HasMany
    {
        return $this->hasMany(Standing::class)->orderBy('position');
    }

    /**
     * Season matches (through rounds)
     */
    public function matches()
    {
        return FootballMatch::whereHas('round', function ($query) {
            $query->where('season_id', $this->id);
        });
    }

    /**
     * Prediction leaderboards for this season
     */
    public function leaderboards(): HasMany
    {
        return $this->hasMany(PredictionLeaderboard::class);
    }

    /**
     * Check if season is active
     */
    public function getIsActiveAttribute(): bool
    {
        return $this->start_date <= now() && $this->end_date >= now();
    }
}
