<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MatchEventResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $teamId = $this->team_id;

        if (! $teamId && $this->relationLoaded('match')) {
            $teamId = match ($this->team_side) {
                'home' => $this->match?->home_team_id,
                'away' => $this->match?->away_team_id,
                default => null,
            };
        }

        return [
            'id' => $this->id,
            'match_id' => $this->match_id,
            'event_type' => $this->type,
            'minute' => $this->minute,
            'extra_minute' => $this->extra_minute,
            'team_side' => $this->team_side,
            'team_id' => $teamId,
            'team_name' => $this->whenLoaded('team', fn() => $this->team?->name),
            'player_id' => $this->player_id,
            'player_name' => $this->relationLoaded('player') ? $this->player?->name : null,
            'assist_player_id' => $this->assist_player_id,
            'assist_player_name' => $this->relationLoaded('assistPlayer') ? $this->assistPlayer?->name : null,
            'substitute_player_id' => $this->substitute_player_id,
            'substitute_player_name' => $this->relationLoaded('substitutePlayer') ? $this->substitutePlayer?->name : null,
            'description' => $this->description,
            'display_minute' => $this->display_minute,
            'icon' => $this->icon,
            'type_label' => $this->type_label,
        ];
    }
}
