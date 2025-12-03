<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CampaignInteraction extends Model
{
    use HasFactory;

    protected $fillable = [
        'campaign_id',
        'user_id',
        'type',
        'points_earned',
    ];

    protected $casts = [
        'points_earned' => 'integer',
    ];

    /**
     * Campaign
     */
    public function campaign(): BelongsTo
    {
        return $this->belongsTo(SponsorCampaign::class, 'campaign_id');
    }

    /**
     * User
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
