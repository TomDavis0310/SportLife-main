<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LeaderboardResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'rank' => $this->rank,
            'total_points' => $this->total_points,
            'total_predictions' => $this->total_predictions,
            'correct_scores' => $this->correct_scores,
            'correct_differences' => $this->correct_differences,
            'correct_winners' => $this->correct_winners,
            'accuracy' => $this->accuracy ?? 0,
            'season_id' => $this->season_id,
            'round_id' => $this->round_id,
            'user' => $this->when(
                $this->relationLoaded('user'),
                fn () => new UserResource($this->user)
            ),
        ];
    }
}
