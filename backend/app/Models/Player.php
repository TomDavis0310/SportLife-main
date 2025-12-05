<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Player extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'team_id',
        'name',
        'name_en',
        'nickname',
        'photo',
        'avatar',
        'position',
        'jersey_number',
        'nationality',
        'birth_date',
        'dob',
        'height',
        'weight',
        'market_value',
        'contract_until',
        'is_active',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'dob' => 'date',
        'contract_until' => 'date',
        'is_active' => 'boolean',
        'jersey_number' => 'integer',
        'height' => 'integer',
        'weight' => 'integer',
        'market_value' => 'decimal:2',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('photo')
            ->singleFile()
            ->useFallbackUrl('/images/default-player.png');
    }

    /**
     * Get the player's photo URL
     */
    public function getPhotoUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('photo') ?: ($this->photo ?? '/images/default-player.png');
    }

    /**
     * Player's team
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Match events involving this player
     */
    public function matchEvents(): HasMany
    {
        return $this->hasMany(MatchEvent::class);
    }

    /**
     * Goals scored by this player
     */
    public function goals(): HasMany
    {
        return $this->hasMany(MatchEvent::class)->whereIn('type', ['goal', 'penalty']);
    }

    /**
     * Matches where this player was first scorer
     */
    public function firstScorerMatches(): HasMany
    {
        return $this->hasMany(FootballMatch::class, 'first_scorer_id');
    }

    /**
     * Predictions where this player was predicted as first scorer
     */
    public function predictedAsFirstScorer(): HasMany
    {
        return $this->hasMany(Prediction::class, 'first_scorer_id');
    }

    /**
     * Get player's age
     */
    public function getAgeAttribute(): ?int
    {
        return $this->birth_date?->age;
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
     * Get position label
     */
    public function getPositionLabelAttribute(): string
    {
        return match ($this->position) {
            'goalkeeper' => __('Thủ môn'),
            'defender' => __('Hậu vệ'),
            'midfielder' => __('Tiền vệ'),
            'forward' => __('Tiền đạo'),
            default => $this->position,
        };
    }
}
