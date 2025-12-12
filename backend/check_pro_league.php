<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$competition = App\Models\Competition::where('short_name', 'PL16')->first();
$season = App\Models\Season::where('competition_id', $competition->id)->first();
$teams = $season->teams;

echo "=== Pro League 16 - Thông tin giải đấu ===" . PHP_EOL . PHP_EOL;
echo "Giải đấu: " . $competition->name . PHP_EOL;
echo "Mùa giải: " . $season->name . PHP_EOL;
echo "Số đội: " . $teams->count() . PHP_EOL . PHP_EOL;

echo "=== Danh sách 16 đội ===" . PHP_EOL;
foreach ($teams as $team) {
    echo $team->short_name . " - " . $team->name . " (" . $team->city . ")" . PHP_EOL;
}

$finished = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->where('status', 'finished')->count();
$scheduled = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->where('status', 'scheduled')->count();

echo PHP_EOL . "=== Tiến độ giải đấu ===" . PHP_EOL;
echo "Trận đã hoàn thành: " . $finished . PHP_EOL;
echo "Trận chưa đá: " . $scheduled . PHP_EOL;
echo "Tiến độ: " . round($finished / ($finished + $scheduled) * 100) . "%" . PHP_EOL;

// Top 5 teams by points
echo PHP_EOL . "=== Bảng xếp hạng (Top 5) ===" . PHP_EOL;

$standings = [];
foreach ($teams as $team) {
    $wins = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))
        ->where('status', 'finished')
        ->where(function($q) use ($team) {
            $q->where(function($q) use ($team) {
                $q->where('home_team_id', $team->id)->whereColumn('home_score', '>', 'away_score');
            })->orWhere(function($q) use ($team) {
                $q->where('away_team_id', $team->id)->whereColumn('away_score', '>', 'home_score');
            });
        })->count();
    
    $draws = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))
        ->where('status', 'finished')
        ->where(function($q) use ($team) {
            $q->where('home_team_id', $team->id)->orWhere('away_team_id', $team->id);
        })
        ->whereColumn('home_score', '=', 'away_score')->count();
    
    $losses = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))
        ->where('status', 'finished')
        ->where(function($q) use ($team) {
            $q->where(function($q) use ($team) {
                $q->where('home_team_id', $team->id)->whereColumn('home_score', '<', 'away_score');
            })->orWhere(function($q) use ($team) {
                $q->where('away_team_id', $team->id)->whereColumn('away_score', '<', 'home_score');
            });
        })->count();
    
    $points = $wins * 3 + $draws;
    
    $standings[] = [
        'team' => $team->short_name,
        'name' => $team->name,
        'played' => $wins + $draws + $losses,
        'wins' => $wins,
        'draws' => $draws,
        'losses' => $losses,
        'points' => $points,
    ];
}

usort($standings, function($a, $b) {
    return $b['points'] - $a['points'];
});

$rank = 1;
foreach (array_slice($standings, 0, 5) as $team) {
    echo $rank . ". " . $team['team'] . " | " . $team['played'] . " trận | " . 
         $team['wins'] . "T " . $team['draws'] . "H " . $team['losses'] . "B | " . 
         $team['points'] . " điểm" . PHP_EOL;
    $rank++;
}
