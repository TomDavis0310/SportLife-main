<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SeasonChampionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'season_id' => $this->season_id,
            'champion_team_id' => $this->champion_team_id,
            'season' => $this->when(
                $this->relationLoaded('season'),
                fn () => new SeasonResource($this->season)
            ),
            'champion_team' => $this->when(
                $this->relationLoaded('championTeam'),
                fn () => new TeamResource($this->championTeam)
            ),
            'confirmed_at' => $this->confirmed_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
