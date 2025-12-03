<?php

use App\Enums\MatchStatus;
use App\Models\FootballMatch;
use App\Models\Player;
use App\Models\Round;
use App\Models\Team;
use Carbon\Carbon;

require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$today = Carbon::today();
$startDate = $today->copy()->subDays(7);
$endDate = $today->copy()->addDays(14);
$targetPerDay = 8;

$roundIds = Round::pluck('id')->toArray();
if (empty($roundIds)) {
    throw new RuntimeException('No rounds available');
}

$activeTeamIds = FootballMatch::whereDate('match_date', $today->toDateString())
    ->pluck('home_team_id')
    ->merge(FootballMatch::whereDate('match_date', $today->toDateString())->pluck('away_team_id'))
    ->unique()
    ->values();

if ($activeTeamIds->isEmpty()) {
    $activeTeamIds = Team::limit(20)->pluck('id');
}

$playerIdsByTeam = Player::whereIn('team_id', $activeTeamIds)->get()->groupBy('team_id');

for ($date = $startDate->copy(); $date->lte($endDate); $date->addDay()) {
    $currentCount = FootballMatch::whereDate('match_date', $date->toDateString())->count();
    if ($currentCount >= $targetPerDay) {
        continue;
    }

    $needed = $targetPerDay - $currentCount;
    $usedTeams = [];

    for ($i = 0; $i < $needed; $i++) {
        $teamPool = $activeTeamIds->shuffle()->values();
        $homeTeamId = $teamPool->first(fn($id) => !in_array($id, $usedTeams, true));
        $awayTeamId = $teamPool->first(fn($id) => $id !== $homeTeamId && !in_array($id, $usedTeams, true));

        if (!$homeTeamId || !$awayTeamId) {
            $homeTeamId = $teamPool->get(0);
            $awayTeamId = $teamPool->get(1);
        }

        $usedTeams[] = $homeTeamId;
        $usedTeams[] = $awayTeamId;

        $kickoff = $date->copy()->setTime(rand(12, 22), rand(0, 1) ? 0 : 30, 0);
        $status = MatchStatus::SCHEDULED->value;
        $homeScore = null;
        $awayScore = null;
        $minute = null;
        $firstScorerId = null;

        if ($kickoff->lt(Carbon::now()->subHours(2))) {
            $status = MatchStatus::FINISHED->value;
            $homeScore = rand(0, 4);
            $awayScore = rand(0, 4);
            $minute = 90;
            $scorerPool = $playerIdsByTeam->get($homeTeamId) ?: $playerIdsByTeam->get($awayTeamId);
            if ($scorerPool && $scorerPool->isNotEmpty()) {
                $firstScorerId = $scorerPool->random()->id;
            }
        } elseif ($kickoff->between(Carbon::now()->subHours(2), Carbon::now())) {
            $status = MatchStatus::LIVE->value;
            $homeScore = rand(0, 3);
            $awayScore = rand(0, 3);
            $minute = rand(1, 90);
        }

        FootballMatch::create([
            'round_id' => $roundIds[array_rand($roundIds)],
            'home_team_id' => $homeTeamId,
            'away_team_id' => $awayTeamId,
            'home_score' => $homeScore,
            'away_score' => $awayScore,
            'status' => $status,
            'minute' => $minute,
            'match_date' => $kickoff,
            'venue' => 'SportLife Stadium',
            'prediction_locked_at' => $kickoff->copy()->subMinutes(30),
            'first_scorer_id' => $firstScorerId,
        ]);
    }
}

echo "Filled matches for {$startDate->toDateString()} to {$endDate->toDateString()}\n";
