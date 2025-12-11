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
        'format',
        'round_type',
        'max_teams',
        'min_teams',
        'registration_start_date',
        'registration_end_date',
        'registration_locked',
        'sponsor_user_id',
        'description',
        'location',
        'prize',
        'rules',
        'contact',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'registration_start_date' => 'date',
        'registration_end_date' => 'date',
        'is_current' => 'boolean',
        'registration_locked' => 'boolean',
        'max_teams' => 'integer',
        'min_teams' => 'integer',
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

    /**
     * Sponsor who created/manages this season
     */
    public function sponsor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sponsor_user_id');
    }

    /**
     * Get approved teams count
     */
    public function getApprovedTeamsCountAttribute(): int
    {
        return $this->teams()->wherePivot('status', 'approved')->count();
    }

    /**
     * Check if registration is full
     */
    public function getIsRegistrationFullAttribute(): bool
    {
        return $this->approved_teams_count >= $this->max_teams;
    }

    /**
     * Check if can still register
     */
    public function getCanRegisterAttribute(): bool
    {
        return !$this->registration_locked && !$this->is_registration_full;
    }
}
