<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CampaignResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'type' => $this->type,
            'banner' => $this->banner_url,
            'target_url' => $this->target_url,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'is_active' => $this->is_active,
            'points' => [
                'view' => $this->view_points ?? 1,
                'click' => $this->click_points ?? 2,
                'participate' => $this->participate_points ?? 10,
                'share' => $this->share_points ?? 5,
            ],
            'sponsor' => $this->when(
                $this->relationLoaded('sponsor'),
                new SponsorResource($this->sponsor)
            ),
        ];
    }
}
