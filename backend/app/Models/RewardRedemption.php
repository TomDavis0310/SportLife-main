<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RewardRedemption extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'reward_id',
        'voucher_code',
        'points_spent',
        'status',
        'shipping_name',
        'shipping_phone',
        'shipping_address',
        'notes',
        'processed_at',
    ];

    protected $casts = [
        'points_spent' => 'integer',
        'processed_at' => 'datetime',
    ];

    /**
     * User who redeemed
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Redeemed reward
     */
    public function reward(): BelongsTo
    {
        return $this->belongsTo(Reward::class);
    }

    /**
     * Check if pending
     */
    public function getIsPendingAttribute(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Get status label
     */
    public function getStatusLabelAttribute(): string
    {
        return match ($this->status) {
            'pending' => __('Chờ xử lý'),
            'approved' => __('Đã duyệt'),
            'shipped' => __('Đang giao'),
            'delivered' => __('Đã giao'),
            'cancelled' => __('Đã hủy'),
            default => $this->status,
        };
    }

    /**
     * Scope for pending redemptions
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }
}
