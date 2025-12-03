<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RewardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description ?? '',
            'type' => $this->type,
            'image' => $this->image_url ?? 'rewards/default.png',
            'image_url' => $this->image_url ?? 'rewards/default.png',
            'points_required' => $this->points_required ?? 0,
            'points_cost' => $this->points_required ?? 0,
            'stock' => $this->stock ?? 0,
            'quantity' => $this->stock ?? 0,
            'is_available' => $this->is_available ?? true,
            'is_active' => $this->is_active ?? true,
            'is_physical' => $this->is_physical ?? false,
            'sponsor_id' => $this->sponsor_id,
            'sponsor' => $this->when(
                $this->relationLoaded('sponsor') && $this->sponsor,
                fn() => [
                    'id' => $this->sponsor->id,
                    'name' => $this->sponsor->company_name,
                    'logo' => $this->sponsor->company_logo ?? 'sponsors/default.png',
                ]
            ),
            'expiry_date' => $this->expiry_date?->toDateString(),
            'expires_at' => $this->expiry_date?->toDateString(),
            'valid_until' => $this->expiry_date?->toDateString(),
            'terms' => null,
        ];
    }
}
