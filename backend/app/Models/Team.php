<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Team extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'name',
        'name_en',
        'short_name',
        'logo',
        'stadium',
        'city',
        'country',
        'founded_year',
        'manager_user_id',
        'description',
        'description_en',
        'primary_color',
        'secondary_color',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'founded_year' => 'integer',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('logo')
            ->singleFile()
            ->useFallbackUrl('/images/default-team-logo.png');

        $this->addMediaCollection('photos');
    }

    /**
     * Get the team's logo URL
     */
    public function getLogoUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('logo') ?: ($this->logo ?? '/images/default-team-logo.png');
    }

    /**
     * Team manager (club_manager user)
     */
    public function manager(): BelongsTo
    {
        return $this->belongsTo(User::class, 'manager_user_id');
    }

    /**
     * Team players
     */
    public function players(): HasMany
    {
        return $this->hasMany(Player::class);
    }

    /**
     * Active players
     */
    public function activePlayers(): HasMany
    {
        return $this->hasMany(Player::class)->where('is_active', true);
    }

    /**
     * Home matches
     */
    public function homeMatches(): HasMany
    {
        return $this->hasMany(FootballMatch::class, 'home_team_id');
    }

    /**
     * Away matches
     */
    public function awayMatches(): HasMany
    {
        return $this->hasMany(FootballMatch::class, 'away_team_id');
    }

    /**
     * Seasons the team participates in
     */
    public function seasons(): BelongsToMany
    {
        return $this->belongsToMany(Season::class, 'season_teams');
    }

    /**
     * Team standings across seasons
     */
    public function standings(): HasMany
    {
        return $this->hasMany(Standing::class);
    }

    /**
     * Users who follow this team
     */
    public function followers(): MorphMany
    {
        return $this->morphMany(Follow::class, 'followable');
    }

    /**
     * Sponsor campaigns for this team
     */
    public function sponsorCampaigns(): HasMany
    {
        return $this->hasMany(SponsorCampaign::class);
    }

    /**
     * News related to this team
     */
    public function news(): HasMany
    {
        return $this->hasMany(News::class);
    }

    /**
     * Get localized name
     */
    public function getLocalizedNameAttribute(): string
    {
        $locale = app()->getLocale();
        return $locale === 'en' && $this->name_en ? $this->name_en : $this->name;
    }

    /**
     * Backward compatible colors payload for API callers expecting a single field
     */
    public function getColorsAttribute(): array
    {
        return [
            'primary' => $this->primary_color,
            'secondary' => $this->secondary_color,
        ];
    }
}
