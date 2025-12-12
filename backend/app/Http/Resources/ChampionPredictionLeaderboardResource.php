<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChampionPredictionLeaderboardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'season_id' => $this->season_id,
            'user' => $this->when(
                $this->relationLoaded('user'),
                fn () => new UserResource($this->user)
            ),
            'season' => $this->when(
                $this->relationLoaded('season'),
                fn () => new SeasonResource($this->season)
            ),
            'total_predictions' => $this->total_predictions,
            'correct_predictions' => $this->correct_predictions,
            'total_points_wagered' => $this->total_points_wagered,
            'total_points_earned' => $this->total_points_earned,
            'profit' => $this->profit,
            'win_rate' => $this->win_rate,
            'rank' => $this->rank,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
