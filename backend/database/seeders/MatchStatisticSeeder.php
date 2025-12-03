<?php

namespace Database\Seeders;

use App\Enums\MatchStatus;
use App\Models\FootballMatch;
use App\Models\MatchStatistic;
use Illuminate\Database\Seeder;

class MatchStatisticSeeder extends Seeder
{
    public function run(): void
    {
        $matches = FootballMatch::with('statistics')
            ->where('status', MatchStatus::FINISHED->value)
            ->get();

        foreach ($matches as $match) {
            if ($match->statistics->count() === 2) {
                continue;
            }

            $homeStats = $this->generateTeamStats($match->home_score ?? 0);
            $awayStats = $this->generateTeamStats($match->away_score ?? 0, false, $homeStats['possession']);

            MatchStatistic::updateOrCreate(
                ['match_id' => $match->id, 'side' => 'home'],
                $homeStats + ['match_id' => $match->id, 'side' => 'home']
            );

            MatchStatistic::updateOrCreate(
                ['match_id' => $match->id, 'side' => 'away'],
                $awayStats + ['match_id' => $match->id, 'side' => 'away']
            );
        }
    }

    protected function generateTeamStats(int $goals, bool $isHome = true, ?int $opponentPossession = null): array
    {
        $possession = $opponentPossession !== null
            ? max(0, min(100, 100 - $opponentPossession))
            : ($isHome ? rand(48, 62) : rand(38, 52));

        $shotsOnTarget = max($goals, $goals + rand(0, 4));
        $shots = $shotsOnTarget + rand(3, 8);

        return [
            'shots' => $shots,
            'shots_on_target' => $shotsOnTarget,
            'possession' => $possession,
            'passes' => rand(320, 580),
            'pass_accuracy' => rand(72, 90),
            'fouls' => rand(6, 15),
            'yellow_cards' => rand(0, 3),
            'red_cards' => rand(0, 1),
            'offsides' => rand(0, 4),
            'corners' => rand(2, 9),
        ];
    }
}
