<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'photo' => $this->photo_url,
            'position' => $this->position,
            'shirt_number' => $this->jersey_number,
            'nationality' => $this->nationality,
            'date_of_birth' => $this->date_of_birth?->toDateString(),
            'age' => $this->age,
            'height' => $this->height,
            'weight' => $this->weight,
            'market_value' => $this->market_value,
            'team' => $this->when($this->relationLoaded('team'), new TeamResource($this->team)),
        ];
    }
}
