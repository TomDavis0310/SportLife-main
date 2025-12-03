<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements MustVerifyEmail, HasMedia
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles, InteractsWithMedia;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar',
        'phone',
        'sport_points',
        'prediction_streak',
        'max_prediction_streak',
        'referral_code',
        'referred_by',
        'favorite_team_id',
        'fcm_token',
        'google_id',
        'facebook_id',
        'apple_id',
        'last_login_at',
        'last_daily_bonus_at',
        'is_blocked',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
        'google_id',
        'facebook_id',
        'apple_id',
        'fcm_token',
    ];

    /**
     * Get the attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'last_daily_bonus_at' => 'datetime',
            'password' => 'hashed',
            'is_blocked' => 'boolean',
            'sport_points' => 'integer',
            'prediction_streak' => 'integer',
            'max_prediction_streak' => 'integer',
        ];
    }

    /**
     * Generate unique referral code on creation
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($user) {
            if (!$user->referral_code) {
                $user->referral_code = strtoupper(substr(md5(uniqid()), 0, 8));
            }
        });
    }

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('avatar')
            ->singleFile()
            ->useFallbackUrl('/images/default-avatar.png');
    }

    /**
     * Get the user's avatar URL
     */
    public function getAvatarUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('avatar') ?: ($this->avatar ?? '/images/default-avatar.png');
    }

    /**
     * The user who referred this user
     */
    public function referrer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'referred_by');
    }

    /**
     * Users referred by this user
     */
    public function referrals(): HasMany
    {
        return $this->hasMany(User::class, 'referred_by');
    }

    /**
     * User's favorite team
     */
    public function favoriteTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'favorite_team_id');
    }

    /**
     * Team managed by this user (if club_manager)
     */
    public function managedTeam(): HasOne
    {
        return $this->hasOne(Team::class, 'manager_user_id');
    }

    /**
     * User's predictions
     */
    public function predictions(): HasMany
    {
        return $this->hasMany(Prediction::class);
    }

    /**
     * User's point transactions
     */
    public function pointTransactions(): HasMany
    {
        return $this->hasMany(PointTransaction::class);
    }

    /**
     * User's badges
     */
    public function badges(): HasMany
    {
        return $this->hasMany(UserBadge::class);
    }

    /**
     * User's reward redemptions
     */
    public function redemptions(): HasMany
    {
        return $this->hasMany(RewardRedemption::class);
    }

    /**
     * User's comments
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    /**
     * User's likes
     */
    public function likes(): HasMany
    {
        return $this->hasMany(Like::class);
    }

    /**
     * User's follows (what they follow)
     */
    public function follows(): HasMany
    {
        return $this->hasMany(Follow::class, 'follower_id');
    }

    /**
     * User's followers (who follows them)
     */
    public function followers(): MorphMany
    {
        return $this->morphMany(Follow::class, 'followable');
    }

    /**
     * User's friend requests sent
     */
    public function friendRequestsSent(): HasMany
    {
        return $this->hasMany(UserFriend::class, 'user_id');
    }

    /**
     * User's friend requests received
     */
    public function friendRequestsReceived(): HasMany
    {
        return $this->hasMany(UserFriend::class, 'friend_id');
    }

    /**
     * User's notifications
     */
    public function userNotifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * User's sponsor profile (if sponsor role)
     */
    public function sponsor(): HasOne
    {
        return $this->hasOne(Sponsor::class);
    }

    /**
     * User's leaderboard entries
     */
    public function leaderboards(): HasMany
    {
        return $this->hasMany(PredictionLeaderboard::class);
    }

    /**
     * User's missions progress
     */
    public function missions(): HasMany
    {
        return $this->hasMany(UserMission::class);
    }

    /**
     * News articles authored by user
     */
    public function newsArticles(): HasMany
    {
        return $this->hasMany(News::class, 'author_id');
    }

    /**
     * Add sport points to user
     */
    public function addPoints(int $points, string $type, ?string $description = null, $reference = null): void
    {
        $this->increment('sport_points', $points);

        $this->pointTransactions()->create([
            'type' => $type,
            'points' => $points,
            'description' => $description,
            'reference_type' => $reference ? get_class($reference) : null,
            'reference_id' => $reference?->id,
        ]);
    }

    /**
     * Deduct sport points from user
     */
    public function deductPoints(int $points, string $type, ?string $description = null, $reference = null): bool
    {
        if ($this->sport_points < $points) {
            return false;
        }

        $this->decrement('sport_points', $points);

        $this->pointTransactions()->create([
            'type' => $type,
            'points' => -$points,
            'description' => $description,
            'reference_type' => $reference ? get_class($reference) : null,
            'reference_id' => $reference?->id,
        ]);

        return true;
    }

    /**
     * Check if user can claim daily bonus
     */
    public function canClaimDailyBonus(): bool
    {
        if (!$this->last_daily_bonus_at) {
            return true;
        }

        return $this->last_daily_bonus_at->isYesterday() || $this->last_daily_bonus_at->lt(now()->subDay());
    }

    /**
     * Claim daily login bonus
     */
    public function claimDailyBonus(): int
    {
        if (!$this->canClaimDailyBonus()) {
            return 0;
        }

        // Calculate streak bonus
        $streak = 1;
        if ($this->last_daily_bonus_at && $this->last_daily_bonus_at->isYesterday()) {
            $streak = min($this->prediction_streak + 1, 30);
        }

        $points = 10 + ($streak - 1) * 2; // 10 base + 2 per streak day, max 68 (at 30 days)

        $this->update([
            'last_daily_bonus_at' => now(),
            'prediction_streak' => $streak,
        ]);

        $this->addPoints($points, 'daily_bonus', "Daily login bonus (Day {$streak})");

        return $points;
    }
}
