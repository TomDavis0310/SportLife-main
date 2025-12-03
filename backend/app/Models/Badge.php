<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Badge extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'name',
        'name_en',
        'description',
        'description_en',
        'icon',
        'type',
        'requirement_type',
        'requirement_value',
        'points_reward',
        'is_active',
    ];

    protected $casts = [
        'requirement_value' => 'integer',
        'points_reward' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('icon')
            ->singleFile()
            ->useFallbackUrl('/images/default-badge.png');
    }

    /**
     * Get the badge's icon URL
     */
    public function getIconUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('icon') ?: ($this->icon ?? '/images/default-badge.png');
    }

    /**
     * Users who have earned this badge
     */
    public function userBadges(): HasMany
    {
        return $this->hasMany(UserBadge::class);
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
     * Get localized description
     */
    public function getLocalizedDescriptionAttribute(): string
    {
        $locale = app()->getLocale();
        return $locale === 'en' && $this->description_en ? $this->description_en : $this->description;
    }

    /**
     * Check if user qualifies for this badge
     */
    public function checkUserQualification(User $user): bool
    {
        return match ($this->requirement_type) {
            'correct_predictions' => $user->predictions()
                ->where('is_correct_score', true)
                ->count() >= $this->requirement_value,
            
            'prediction_streak' => $user->max_prediction_streak >= $this->requirement_value,
            
            'total_predictions' => $user->predictions()->count() >= $this->requirement_value,
            
            'sport_points' => $user->sport_points >= $this->requirement_value,
            
            'referrals' => $user->referrals()->count() >= $this->requirement_value,
            
            'daily_login_streak' => $user->prediction_streak >= $this->requirement_value,
            
            default => false,
        };
    }
}
