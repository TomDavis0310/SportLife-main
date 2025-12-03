<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchHighlight extends Model
{
    use HasFactory;

    protected $fillable = [
        'match_id',
        'title',
        'description',
        'provider',
        'video_url',
        'thumbnail_url',
        'duration_seconds',
        'published_at',
        'is_featured',
        'view_count',
        'meta',
    ];

    protected $casts = [
        'published_at' => 'datetime',
        'is_featured' => 'boolean',
        'meta' => 'array',
        'duration_seconds' => 'integer',
        'view_count' => 'integer',
    ];

    public function match(): BelongsTo
    {
        return $this->belongsTo(FootballMatch::class, 'match_id');
    }
}
