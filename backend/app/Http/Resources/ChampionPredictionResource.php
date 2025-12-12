<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ChampionPredictionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'season_id' => $this->season_id,
            'predicted_team_id' => $this->predicted_team_id,
            'user' => $this->when(
                $this->relationLoaded('user'),
                fn () => new UserResource($this->user)
            ),
            'season' => $this->when(
                $this->relationLoaded('season'),
                fn () => new SeasonResource($this->season)
            ),
            'predicted_team' => $this->when(
                $this->relationLoaded('predictedTeam'),
                fn () => new TeamResource($this->predictedTeam)
            ),
            'reason' => $this->reason,
            'confidence_level' => $this->confidence_level,
            'points_wagered' => $this->points_wagered,
            'points_earned' => $this->status !== 'pending' ? $this->points_earned : null,
            'potential_winnings' => $this->potential_winnings,
            'multiplier' => $this->multiplier,
            'status' => $this->status,
            'status_label' => $this->status_label,
            'is_pending' => $this->status === 'pending',
            'is_won' => $this->status === 'won',
            'is_lost' => $this->status === 'lost',
            'calculated_at' => $this->calculated_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
