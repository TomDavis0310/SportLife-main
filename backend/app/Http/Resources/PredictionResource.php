<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PredictionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'match_id' => $this->match_id,
            'match' => new MatchResource($this->whenLoaded('match')),
            'user' => $this->when(
                $this->relationLoaded('user'),
                fn () => new UserResource($this->user)
            ),
            'predicted_outcome' => $this->predicted_outcome,
            'predicted_outcome_label' => $this->predicted_outcome_label,
            'points_earned' => $this->calculated_at ? $this->points_earned : null,
            'points' => $this->calculated_at ? $this->points_earned : null,
            'is_correct_outcome' => $this->is_correct_outcome ?? false,
            'is_correct' => $this->is_correct_outcome ?? false,
            'streak_multiplier' => (float) ($this->streak_multiplier ?? 1.0),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
