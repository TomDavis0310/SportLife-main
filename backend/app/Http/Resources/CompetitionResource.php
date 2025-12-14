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
            'name_en' => $this->name_en,
            'short_name' => $this->short_name,
            'logo' => $this->logo_url,
            'banner' => $this->banner_url ?? null,
            'country' => $this->country,
            'type' => $this->type,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'teams_count' => $this->getTeamsCount(),
            'matches_count' => $this->when(
                $this->relationLoaded('seasons'),
                fn() => $this->getMatchesCount(),
                0
            ),
            'goals_count' => $this->when(
                $this->relationLoaded('seasons'),
                fn() => $this->getGoalsCount(),
                0
            ),
            'seasons' => $this->when(
                $this->relationLoaded('seasons'),
                fn() => SeasonResource::collection($this->seasons)
            ),
            'current_season' => $this->when(
                $this->relationLoaded('seasons'),
                fn() => $this->getCurrentSeason()
            ),
            'teams' => $this->when(
                $this->relationLoaded('seasons'),
                fn() => $this->getAllTeams()
            ),
            // Sponsor can be added later when relation is established
            'sponsor' => null,
        ];
    }

    /**
     * Get teams count from current season or latest season
     */
    private function getTeamsCount(): int
    {
        if (!$this->relationLoaded('seasons') || $this->seasons->isEmpty()) {
            return 0;
        }
        
        // Try to get current season first
        $currentSeason = $this->seasons->firstWhere('is_current', true);
        if ($currentSeason && $currentSeason->relationLoaded('teams')) {
            return $currentSeason->teams->count();
        }
        
        // Fallback to latest season
        $latestSeason = $this->seasons->first();
        if ($latestSeason && $latestSeason->relationLoaded('teams')) {
            return $latestSeason->teams->count();
        }
        
        return 0;
    }

    /**
     * Get current season resource
     */
    private function getCurrentSeason()
    {
        if (!$this->relationLoaded('seasons') || $this->seasons->isEmpty()) {
            return null;
        }
        
        $currentSeason = $this->seasons->firstWhere('is_current', true);
        if ($currentSeason) {
            return new SeasonResource($currentSeason);
        }
        
        // Fallback to latest season
        return new SeasonResource($this->seasons->first());
    }

    /**
     * Get all teams from current season
     */
    private function getAllTeams()
    {
        if (!$this->relationLoaded('seasons') || $this->seasons->isEmpty()) {
            return [];
        }
        
        $currentSeason = $this->seasons->firstWhere('is_current', true);
        if (!$currentSeason) {
            $currentSeason = $this->seasons->first();
        }
        
        if ($currentSeason && $currentSeason->relationLoaded('teams')) {
            return TeamResource::collection($currentSeason->teams);
        }
        
        return [];
    }

    /**
     * Get total matches count for this competition
     */
    private function getMatchesCount(): int
    {
        $count = 0;
        if (!$this->relationLoaded('seasons')) {
            return $count;
        }
        
        foreach ($this->seasons as $season) {
            if ($season->relationLoaded('rounds')) {
                foreach ($season->rounds as $round) {
                    $count += $round->matches_count ?? 0;
                }
            }
        }
        return $count;
    }

    /**
     * Get total goals count for this competition from standings
     */
    private function getGoalsCount(): int
    {
        if (!$this->relationLoaded('seasons')) {
            return 0;
        }
        
        $totalGoals = 0;
        
        // Get current season or latest season
        $currentSeason = $this->seasons->firstWhere('is_current', true);
        if (!$currentSeason) {
            $currentSeason = $this->seasons->first();
        }
        
        if ($currentSeason && $currentSeason->relationLoaded('standings')) {
            // Sum goals_for from all standings (each team's scored goals)
            foreach ($currentSeason->standings as $standing) {
                $totalGoals += $standing->goals_for ?? 0;
            }
        }
        
        return $totalGoals;
    }
}
