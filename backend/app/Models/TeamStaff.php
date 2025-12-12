<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TeamStaff extends Model
{
    use HasFactory;

    protected $fillable = [
        'team_id',
        'name',
        'role',
        'avatar',
        'nationality',
    ];

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }
}
