<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'match_id',
        'type',
        'team_side',
        'team_id',
        'minute',
        'extra_minute',
        'player_id',
        'assist_player_id',
        'substitute_player_id',
        'description',
    ];

    protected $casts = [
        'minute' => 'integer',
        'extra_minute' => 'integer',
        'team_id' => 'integer',
    ];

    /**
     * Event's match
     */
    public function match(): BelongsTo
    {
        return $this->belongsTo(FootballMatch::class, 'match_id');
    }

    /**
     * Main player involved
     */
    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Assist player (for goals)
     */
    public function assistPlayer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'assist_player_id');
    }

    /**
     * Substitute player (for substitutions)
     */
    public function substitutePlayer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'substitute_player_id');
    }

    /**
     * Get display minute (e.g., "45+2")
     */
    public function getDisplayMinuteAttribute(): string
    {
        if ($this->extra_minute) {
            return "{$this->minute}+{$this->extra_minute}'";
        }
        return "{$this->minute}'";
    }

    /**
     * Get event icon based on type
     */
    public function getIconAttribute(): string
    {
        return match ($this->type) {
            'goal' => '⚽',
            'penalty' => '⚽(P)',
            'own_goal' => '⚽(OG)',
            'penalty_miss' => '❌(P)',
            'yellow_card' => '🟨',
            'red_card' => '🟥',
            'substitution' => '🔄',
            'var' => '📺',
            default => '📌',
        };
    }

    /**
     * Get event type label
     */
    public function getTypeLabelAttribute(): string
    {
        return match ($this->type) {
            'goal' => __('Bàn thắng'),
            'penalty' => __('Phạt đền'),
            'own_goal' => __('Phản lưới'),
            'penalty_miss' => __('Hỏng phạt đền'),
            'yellow_card' => __('Thẻ vàng'),
            'red_card' => __('Thẻ đỏ'),
            'substitution' => __('Thay người'),
            'var' => __('VAR'),
            default => $this->type,
        };
    }
}
