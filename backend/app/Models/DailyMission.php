<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DailyMission extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'name_en',
        'description',
        'description_en',
        'type',
        'target_value',
        'points_reward',
        'is_weekly',
        'is_active',
    ];

    protected $casts = [
        'target_value' => 'integer',
        'points_reward' => 'integer',
        'is_weekly' => 'boolean',
        'is_active' => 'boolean',
    ];

    /**
     * User missions
     */
    public function userMissions(): HasMany
    {
        return $this->hasMany(UserMission::class, 'mission_id');
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
        return $locale === 'en' && $this->description_en ? $this->description_en : ($this->description ?? '');
    }

    /**
     * Scope for active missions
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope for daily missions
     */
    public function scopeDaily($query)
    {
        return $query->where('is_weekly', false);
    }

    /**
     * Scope for weekly missions
     */
    public function scopeWeekly($query)
    {
        return $query->where('is_weekly', true);
    }
}
