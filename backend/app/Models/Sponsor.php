<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Sponsor extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'company_name',
        'company_logo',
        'contact_email',
        'contact_phone',
        'balance',
        'is_approved',
    ];

    protected $casts = [
        'balance' => 'decimal:2',
        'is_approved' => 'boolean',
    ];

    /**
     * Sponsor's user account
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Sponsor's campaigns
     */
    public function campaigns(): HasMany
    {
        return $this->hasMany(SponsorCampaign::class);
    }

    /**
     * Sponsor's rewards
     */
    public function rewards(): HasMany
    {
        return $this->hasMany(Reward::class);
    }

    /**
     * Active campaigns
     */
    public function activeCampaigns(): HasMany
    {
        return $this->hasMany(SponsorCampaign::class)
            ->where('is_active', true)
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now());
    }

    /**
     * Add balance
     */
    public function addBalance(float $amount): void
    {
        $this->increment('balance', $amount);
    }

    /**
     * Deduct balance
     */
    public function deductBalance(float $amount): bool
    {
        if ($this->balance < $amount) {
            return false;
        }

        $this->decrement('balance', $amount);
        return true;
    }
}
