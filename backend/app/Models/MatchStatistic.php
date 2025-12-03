<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchStatistic extends Model
{
    use HasFactory;

    protected $fillable = [
        'match_id',
        'side',
        'shots',
        'shots_on_target',
        'possession',
        'passes',
        'pass_accuracy',
        'fouls',
        'yellow_cards',
        'red_cards',
        'offsides',
        'corners',
    ];

    protected $casts = [
        'shots' => 'integer',
        'shots_on_target' => 'integer',
        'possession' => 'integer',
        'passes' => 'integer',
        'pass_accuracy' => 'integer',
        'fouls' => 'integer',
        'yellow_cards' => 'integer',
        'red_cards' => 'integer',
        'offsides' => 'integer',
        'corners' => 'integer',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(FootballMatch::class, 'match_id');
    }
}
