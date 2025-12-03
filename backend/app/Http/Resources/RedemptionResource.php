<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RedemptionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reward' => new RewardResource($this->whenLoaded('reward')),
            'voucher_code' => $this->voucher_code,
            'points_spent' => $this->points_spent,
            'status' => $this->status,
            'shipping_name' => $this->shipping_name,
            'shipping_phone' => $this->shipping_phone,
            'shipping_address' => $this->shipping_address,
            'notes' => $this->notes,
            'created_at' => $this->created_at?->toISOString(),
            'processed_at' => $this->processed_at?->toISOString(),
        ];
    }
}
