<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChampionPrediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'season_id',
        'predicted_team_id',
        'reason',
        'confidence_level',
        'points_wagered',
        'points_earned',
        'status',
        'calculated_at',
    ];

    protected $casts = [
        'confidence_level' => 'integer',
        'points_wagered' => 'integer',
        'points_earned' => 'integer',
        'calculated_at' => 'datetime',
    ];

    /**
     * Status constants
     */
    public const STATUS_PENDING = 'pending';
    public const STATUS_WON = 'won';
    public const STATUS_LOST = 'lost';

    /**
     * Points multiplier based on confidence level
     */
    public function getMultiplierAttribute(): float
    {
        // Higher confidence = higher risk but higher reward
        if ($this->confidence_level >= 90) {
            return 3.0;
        } elseif ($this->confidence_level >= 70) {
            return 2.0;
        } elseif ($this->confidence_level >= 50) {
            return 1.5;
        }
        return 1.0;
    }

    /**
     * Get potential winnings
     */
    public function getPotentialWinningsAttribute(): int
    {
        return (int) ($this->points_wagered * $this->multiplier);
    }

    /**
     * Prediction's user
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Prediction's season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Predicted team
     */
    public function predictedTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'predicted_team_id');
    }

    /**
     * Check if season has ended
     */
    public function getSeasonEndedAttribute(): bool
    {
        return $this->season?->end_date?->isPast() ?? false;
    }

    /**
     * Get status label
     */
    public function getStatusLabelAttribute(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'Đang chờ',
            self::STATUS_WON => 'Thắng',
            self::STATUS_LOST => 'Thua',
            default => 'Không xác định',
        };
    }

    /**
     * Calculate and update points when season ends
     */
    public function calculatePoints(): int
    {
        $champion = SeasonChampion::where('season_id', $this->season_id)->first();
        
        if (!$champion) {
            return 0;
        }

        if ($this->predicted_team_id === $champion->champion_team_id) {
            $points = $this->potential_winnings;
            $this->update([
                'points_earned' => $points,
                'status' => self::STATUS_WON,
                'calculated_at' => now(),
            ]);
            return $points;
        } else {
            $this->update([
                'points_earned' => 0,
                'status' => self::STATUS_LOST,
                'calculated_at' => now(),
            ]);
            return 0;
        }
    }
}
