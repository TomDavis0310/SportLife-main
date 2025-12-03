<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserMission extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'mission_id',
        'current_value',
        'is_completed',
        'completed_at',
        'period_start_date',
    ];

    protected $casts = [
        'current_value' => 'integer',
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
        'period_start_date' => 'date',
    ];

    /**
     * User
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Mission
     */
    public function mission(): BelongsTo
    {
        return $this->belongsTo(DailyMission::class, 'mission_id');
    }

    /**
     * Get progress percentage
     */
    public function getProgressAttribute(): float
    {
        $target = $this->mission->target_value;
        if ($target === 0) {
            return 100;
        }

        return min(100, round(($this->current_value / $target) * 100, 1));
    }

    /**
     * Increment progress
     */
    public function incrementProgress(int $value = 1): void
    {
        if ($this->is_completed) {
            return;
        }

        $this->current_value += $value;

        if ($this->current_value >= $this->mission->target_value) {
            $this->is_completed = true;
            $this->completed_at = now();

            // Award points
            $this->user->addPoints(
                $this->mission->points_reward,
                'mission',
                "Completed mission: {$this->mission->name}",
                $this->mission
            );
        }

        $this->save();
    }
}
