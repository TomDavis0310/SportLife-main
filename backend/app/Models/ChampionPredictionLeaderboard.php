<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChampionPredictionLeaderboard extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'season_id',
        'total_predictions',
        'correct_predictions',
        'total_points_wagered',
        'total_points_earned',
        'rank',
    ];

    protected $casts = [
        'total_predictions' => 'integer',
        'correct_predictions' => 'integer',
        'total_points_wagered' => 'integer',
        'total_points_earned' => 'integer',
        'rank' => 'integer',
    ];

    /**
     * User
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Get win rate
     */
    public function getWinRateAttribute(): float
    {
        if ($this->total_predictions === 0) {
            return 0;
        }
        return round(($this->correct_predictions / $this->total_predictions) * 100, 1);
    }

    /**
     * Get profit
     */
    public function getProfitAttribute(): int
    {
        return $this->total_points_earned - $this->total_points_wagered;
    }
}
