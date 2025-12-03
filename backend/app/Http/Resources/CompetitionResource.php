<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CompetitionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'short_name' => $this->short_name,
            'logo' => $this->logo_url,
            'country' => $this->country,
            'type' => $this->type,
            'is_active' => $this->is_active,
            'teams_count' => $this->teams_count ?? 0,
            'current_season' => $this->when(
                $this->relationLoaded('currentSeason'),
                new SeasonResource($this->currentSeason)
            ),
        ];
    }
}
