<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SeasonResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'is_current' => $this->is_current,
            'format' => $this->format,
            'round_type' => $this->round_type,
            'round_type_label' => $this->getRoundTypeLabel(),
            'max_teams' => $this->max_teams,
            'min_teams' => $this->min_teams,
            'registration_start_date' => $this->registration_start_date?->toDateString(),
            'registration_end_date' => $this->registration_end_date?->toDateString(),
            'registration_locked' => $this->registration_locked,
            'description' => $this->description,
            'location' => $this->location,
            'prize' => $this->prize,
            'rules' => $this->rules,
            'contact' => $this->contact,
            'teams_count' => $this->when($this->teams_count !== null, $this->teams_count),
            'approved_teams_count' => $this->when($this->approved_teams_count !== null, $this->approved_teams_count),
            'competition' => $this->when(
                $this->relationLoaded('competition'),
                new CompetitionResource($this->competition)
            ),
            'teams' => $this->when(
                $this->relationLoaded('teams'),
                fn() => $this->teams->map(fn($team) => [
                    'id' => $team->id,
                    'name' => $team->name,
                    'short_name' => $team->short_name,
                    'logo' => $team->logo_url ?? $team->logo,
                ])
            ),
        ];
    }

    /**
     * Get human-readable label for round type
     */
    private function getRoundTypeLabel(): string
    {
        return match ($this->round_type) {
            'round_robin' => 'Vòng tròn',
            'group_stage' => 'Vòng bảng',
            'knockout' => 'Loại trực tiếp',
            'league' => 'Giải vô địch',
            'mixed' => 'Kết hợp (Bảng + Loại)',
            default => 'Vòng tròn',
        };
    }
}
