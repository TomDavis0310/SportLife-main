<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Reward extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'sponsor_id',
        'name',
        'name_en',
        'description',
        'description_en',
        'image',
        'type',
        'points_required',
        'stock',
        'is_physical',
        'expiry_date',
        'voucher_prefix',
        'is_active',
    ];

    protected $casts = [
        'points_required' => 'integer',
        'stock' => 'integer',
        'is_physical' => 'boolean',
        'expiry_date' => 'date',
        'is_active' => 'boolean',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('image')
            ->singleFile()
            ->useFallbackUrl('/images/default-reward.png');
    }

    /**
     * Get the reward's image URL
     */
    public function getImageUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('image') ?: ($this->image ?? '/images/default-reward.png');
    }

    /**
     * Reward's sponsor
     */
    public function sponsor(): BelongsTo
    {
        return $this->belongsTo(Sponsor::class);
    }

    /**
     * Redemptions of this reward
     */
    public function redemptions(): HasMany
    {
        return $this->hasMany(RewardRedemption::class);
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
     * Check if reward is available
     */
    public function getIsAvailableAttribute(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if ($this->stock <= 0) {
            return false;
        }

        if ($this->expiry_date && $this->expiry_date < now()) {
            return false;
        }

        return true;
    }

    /**
     * Generate voucher code
     */
    public function generateVoucherCode(): string
    {
        $prefix = $this->voucher_prefix ?? 'SL';
        return strtoupper($prefix . '-' . substr(md5(uniqid()), 0, 8));
    }

    /**
     * Scope for available rewards
     */
    public function scopeAvailable($query)
    {
        return $query->where('is_active', true)
            ->where('stock', '>', 0)
            ->where(function ($q) {
                $q->whereNull('expiry_date')
                    ->orWhere('expiry_date', '>=', now());
            });
    }
}
