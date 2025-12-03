<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class SponsorCampaign extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'sponsor_id',
        'team_id',
        'name',
        'type',
        'banner_image',
        'video_url',
        'click_url',
        'points_per_view',
        'bonus_points_correct_prediction',
        'budget',
        'spent',
        'start_date',
        'end_date',
        'impressions_count',
        'clicks_count',
        'is_active',
    ];

    protected $casts = [
        'points_per_view' => 'integer',
        'bonus_points_correct_prediction' => 'integer',
        'budget' => 'decimal:2',
        'spent' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date',
        'impressions_count' => 'integer',
        'clicks_count' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('banner')
            ->singleFile();

        $this->addMediaCollection('video')
            ->singleFile();
    }

    /**
     * Campaign's sponsor
     */
    public function sponsor(): BelongsTo
    {
        return $this->belongsTo(Sponsor::class);
    }

    /**
     * Team being sponsored (if any)
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Campaign interactions
     */
    public function interactions(): HasMany
    {
        return $this->hasMany(CampaignInteraction::class, 'campaign_id');
    }

    /**
     * Check if campaign is currently active
     */
    public function getIsCurrentlyActiveAttribute(): bool
    {
        return $this->is_active &&
            $this->start_date <= now() &&
            $this->end_date >= now() &&
            $this->spent < $this->budget;
    }

    /**
     * Get remaining budget
     */
    public function getRemainingBudgetAttribute(): float
    {
        return max(0, $this->budget - $this->spent);
    }

    /**
     * Record an impression
     */
    public function recordImpression(): void
    {
        $this->increment('impressions_count');
    }

    /**
     * Record a click
     */
    public function recordClick(): void
    {
        $this->increment('clicks_count');
    }

    /**
     * Scope for active campaigns
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now())
            ->whereRaw('spent < budget');
    }
}
