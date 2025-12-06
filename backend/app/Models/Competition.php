<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Competition extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'name',
        'name_en',
        'short_name',
        'logo',
        'country',
        'type',
        'description',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('logo')
            ->singleFile()
            ->useFallbackUrl('/images/default-competition-logo.png');
    }

    /**
     * Get the competition's logo URL
     */
    public function getLogoUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('logo') ?: ($this->logo ?? '/images/default-competition-logo.png');
    }

    /**
     * Competition seasons
     */
    public function seasons(): HasMany
    {
        return $this->hasMany(Season::class);
    }

    /**
     * Current season
     */
    public function currentSeason(): HasMany
    {
        return $this->hasMany(Season::class)->where('is_current', true);
    }

    /**
     * Get localized name
     */
    public function getLocalizedNameAttribute(): string
    {
        $locale = app()->getLocale();
        return $locale === 'en' && $this->name_en ? $this->name_en : $this->name;
    }
}
