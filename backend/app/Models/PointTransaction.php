<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class PointTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'type',
        'points',
        'description',
        'reference_type',
        'reference_id',
    ];

    protected $casts = [
        'points' => 'integer',
    ];

    /**
     * User
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Reference (Prediction, Badge, Reward, etc.)
     */
    public function reference(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Get type label
     */
    public function getTypeLabelAttribute(): string
    {
        return match ($this->type) {
            'prediction' => __('Dự đoán'),
            'referral' => __('Giới thiệu bạn bè'),
            'daily_bonus' => __('Điểm danh hàng ngày'),
            'ad_view' => __('Xem quảng cáo'),
            'mission' => __('Hoàn thành nhiệm vụ'),
            'redemption' => __('Đổi quà'),
            'badge_reward' => __('Nhận huy hiệu'),
            'admin_adjustment' => __('Admin điều chỉnh'),
            'sponsor_bonus' => __('Thưởng nhà tài trợ'),
            default => $this->type,
        };
    }

    /**
     * Check if positive (earned)
     */
    public function getIsEarnedAttribute(): bool
    {
        return $this->points > 0;
    }

    /**
     * Scope for earnings
     */
    public function scopeEarnings($query)
    {
        return $query->where('points', '>', 0);
    }

    /**
     * Scope for spendings
     */
    public function scopeSpendings($query)
    {
        return $query->where('points', '<', 0);
    }
}
