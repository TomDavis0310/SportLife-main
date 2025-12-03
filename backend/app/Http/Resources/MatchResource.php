<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MatchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'home_team_id' => $this->home_team_id,
            'away_team_id' => $this->away_team_id,
            'home_team' => new TeamResource($this->whenLoaded('homeTeam')),
            'away_team' => new TeamResource($this->whenLoaded('awayTeam')),
            'home_score' => $this->home_score,
            'away_score' => $this->away_score,
            'home_score_ht' => $this->home_score_ht,
            'away_score_ht' => $this->away_score_ht,
            'match_time' => $this->match_date?->toISOString(),
            'match_date' => $this->match_date?->toISOString(),
            'status' => $this->status,
            'status_text' => $this->status_text,
            'minute' => $this->minute,
            'venue' => $this->venue,
            'home_form' => $this->getForm($this->home_team_id),
            'away_form' => $this->getForm($this->away_team_id),
            'round_id' => $this->round_id,
            'round' => $this->when(
                $this->relationLoaded('round'),
                fn() => [
                    'id' => $this->round->id,
                    'name' => $this->round->name,
                    'number' => $this->round->round_number,
                ]
            ),
            'competition_id' => $this->round?->season?->competition?->id,
            'competition_name' => $this->round?->season?->competition?->name,
            'round_name' => $this->round?->name,
            'competition' => $this->when(
                $this->relationLoaded('round') && $this->round?->relationLoaded('season'),
                fn() => [
                    'id' => $this->round->season->competition->id ?? null,
                    'name' => $this->round->season->competition->name ?? null,
                    'logo' => $this->round->season->competition->logo_url ?? null,
                ]
            ),
            'is_live' => $this->is_live,
            'can_predict' => $this->can_predict,
            'user_prediction' => $this->when(
                isset($this->user_prediction),
                $this->user_prediction
            ),
            'home_lineup' => $this->when(
                $this->relationLoaded('homeTeam') && $this->homeTeam?->relationLoaded('activePlayers'),
                fn() => $this->homeTeam->activePlayers->take(11)->map(fn($p) => [
                    'id' => $p->id,
                    'name' => $p->name,
                    'number' => $p->jersey_number ?? 0,
                    'position' => $p->position ?? 'forward',
                ]) ?? []
            ) ?? [],
            'away_lineup' => $this->when(
                $this->relationLoaded('awayTeam') && $this->awayTeam?->relationLoaded('activePlayers'),
                fn() => $this->awayTeam->activePlayers->take(11)->map(fn($p) => [
                    'id' => $p->id,
                    'name' => $p->name,
                    'number' => $p->jersey_number ?? 0,
                    'position' => $p->position ?? 'forward',
                ]) ?? []
            ) ?? [],
            'home_formation' => $this->home_formation ?? '4-3-3',
            'away_formation' => $this->away_formation ?? '4-3-3',
            'statistics' => $this->when(
                $this->relationLoaded('statistics') && $this->statistics?->isNotEmpty(),
                fn() => $this->formatStatistics()
            ),
            'events' => $this->when(
                $this->relationLoaded('events'),
                fn() => MatchEventResource::collection($this->events)
            ),
            'highlights' => $this->when(
                $this->relationLoaded('highlights'),
                fn() => HighlightResource::collection($this->highlights)
            ),
        ];
    }

        protected function formatStatistics(): array
    {
        $home = $this->statistics->firstWhere('side', 'home');
        $away = $this->statistics->firstWhere('side', 'away');

        return [
            'shots_home' => $home?->shots ?? 0,
            'shots_away' => $away?->shots ?? 0,
            'shots_on_target_home' => $home?->shots_on_target ?? 0,
            'shots_on_target_away' => $away?->shots_on_target ?? 0,
            'possession_home' => $home?->possession ?? 0,
            'possession_away' => $away?->possession ?? 0,
            'passes_home' => $home?->passes ?? 0,
            'passes_away' => $away?->passes ?? 0,
            'pass_accuracy_home' => $home?->pass_accuracy ?? 0,
            'pass_accuracy_away' => $away?->pass_accuracy ?? 0,
            'fouls_home' => $home?->fouls ?? 0,
            'fouls_away' => $away?->fouls ?? 0,
            'yellow_cards_home' => $home?->yellow_cards ?? 0,
            'yellow_cards_away' => $away?->yellow_cards ?? 0,
            'red_cards_home' => $home?->red_cards ?? 0,
            'red_cards_away' => $away?->red_cards ?? 0,
            'offsides_home' => $home?->offsides ?? 0,
            'offsides_away' => $away?->offsides ?? 0,
            'corners_home' => $home?->corners ?? 0,
            'corners_away' => $away?->corners ?? 0,
        ];
    }

    private function getForm(int $teamId): array
    {
        $matches = \App\Models\FootballMatch::where(function ($query) use ($teamId) {
                $query->where('home_team_id', $teamId)
                      ->orWhere('away_team_id', $teamId);
            })
            ->where('status', 'finished')
            ->where('match_date', '<', $this->match_date)
            ->orderByDesc('match_date')
            ->limit(5)
            ->get();

        return $matches->map(function ($match) use ($teamId) {
            if ($match->home_team_id == $teamId) {
                if ($match->home_score > $match->away_score) return 'W';
                if ($match->home_score < $match->away_score) return 'L';
                return 'D';
            } else {
                if ($match->away_score > $match->home_score) return 'W';
                if ($match->away_score < $match->home_score) return 'L';
                return 'D';
            }
        })->values()->toArray();
    }
}
