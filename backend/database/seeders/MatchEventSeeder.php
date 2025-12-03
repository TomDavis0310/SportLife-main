<?php

namespace Database\Seeders;

use App\Enums\MatchStatus;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;

class MatchEventSeeder extends Seeder
{
    public function run(): void
    {
        $matches = FootballMatch::with([
            'events',
            'homeTeam.players',
            'awayTeam.players',
        ])->where('status', MatchStatus::FINISHED->value)->get();

        foreach ($matches as $match) {
            if ($match->events->isNotEmpty()) {
                continue;
            }

            $events = collect();

            $events = $events
                ->merge($this->generateGoalEvents($match, 'home', $match->home_score ?? 0, $match->homeTeam?->players ?? collect()))
                ->merge($this->generateGoalEvents($match, 'away', $match->away_score ?? 0, $match->awayTeam?->players ?? collect()))
                ->merge($this->generateCardEvents($match, 'home', $match->homeTeam?->players ?? collect()))
                ->merge($this->generateCardEvents($match, 'away', $match->awayTeam?->players ?? collect()))
                ->merge($this->generateSubstitutionEvents($match, 'home', $match->homeTeam?->players ?? collect()))
                ->merge($this->generateSubstitutionEvents($match, 'away', $match->awayTeam?->players ?? collect()));

            $events = $events->sortBy([
                ['minute', 'asc'],
                ['extra_minute', 'asc'],
            ]);

            foreach ($events as $event) {
                MatchEvent::create($event);
            }
        }
    }

    protected function generateGoalEvents(FootballMatch $match, string $side, int $goals, Collection $players): Collection
    {
        if ($goals <= 0 || $players->isEmpty()) {
            return collect();
        }

        $teamId = $side === 'home' ? $match->home_team_id : $match->away_team_id;
        $events = collect();

        for ($i = 0; $i < $goals; $i++) {
            $scorer = $players->random();
            $assistPool = $players->where('id', '!=', $scorer->id);
            $assist = ($assistPool->isNotEmpty() && rand(0, 1)) ? $assistPool->random() : null;
            $minute = rand(5, 90);
            $extra = $minute > 45 && rand(0, 1) ? rand(1, 4) : null;

            $events->push([
                'match_id' => $match->id,
                'type' => 'goal',
                'team_side' => $side,
                'team_id' => $teamId,
                'minute' => $minute,
                'extra_minute' => $extra,
                'player_id' => $scorer->id,
                'assist_player_id' => $assist?->id,
                'description' => $assist
                    ? sprintf('%s kiến tạo cho %s', $assist->name, $scorer->name)
                    : sprintf('Bàn thắng của %s', $scorer->name),
            ]);
        }

        return $events;
    }

    protected function generateCardEvents(FootballMatch $match, string $side, Collection $players): Collection
    {
        if ($players->isEmpty()) {
            return collect();
        }

        $teamId = $side === 'home' ? $match->home_team_id : $match->away_team_id;
        $count = rand(0, 2);
        $events = collect();

        for ($i = 0; $i < $count; $i++) {
            $player = $players->random();
            $minute = rand(10, 85);
            $type = rand(0, 4) ? 'yellow_card' : 'red_card';

            $events->push([
                'match_id' => $match->id,
                'type' => $type,
                'team_side' => $side,
                'team_id' => $teamId,
                'minute' => $minute,
                'extra_minute' => null,
                'player_id' => $player->id,
                'description' => sprintf('%s nhận %s', $player->name, $type === 'yellow_card' ? 'thẻ vàng' : 'thẻ đỏ'),
            ]);
        }

        return $events;
    }

    protected function generateSubstitutionEvents(FootballMatch $match, string $side, Collection $players): Collection
    {
        if ($players->count() < 2) {
            return collect();
        }

        $teamId = $side === 'home' ? $match->home_team_id : $match->away_team_id;
        $count = rand(0, 2);
        $events = collect();

        for ($i = 0; $i < $count; $i++) {
            $playerOut = $players->random();
            $candidates = $players->where('id', '!=', $playerOut->id);
            if ($candidates->isEmpty()) {
                continue;
            }
            $playerIn = $candidates->random();
            $minute = rand(55, 85);

            $events->push([
                'match_id' => $match->id,
                'type' => 'substitution',
                'team_side' => $side,
                'team_id' => $teamId,
                'minute' => $minute,
                'extra_minute' => null,
                'player_id' => $playerOut->id,
                'substitute_player_id' => $playerIn->id,
                'description' => sprintf('%s rời sân, %s vào sân', $playerOut->name, $playerIn->name),
            ]);
        }

        return $events;
    }
}
