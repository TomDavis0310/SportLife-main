<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\FootballMatch;
use App\Models\Standing;
use App\Enums\MatchStatus;

echo "=== Checking Finished Matches and Updating Standings ===\n\n";

// Get finished matches for season 55 and 56
$finishedMatches = FootballMatch::whereHas('round', function($q) {
    $q->whereIn('season_id', [55, 56]);
})
->where('status', 'finished')
->with(['homeTeam', 'awayTeam', 'round'])
->get();

echo "Found " . count($finishedMatches) . " finished matches\n\n";

foreach ($finishedMatches as $match) {
    echo "Match: {$match->homeTeam->name} {$match->home_score} - {$match->away_score} {$match->awayTeam->name}\n";
    echo "  Season ID: {$match->round->season_id}\n";
    
    // Check if we should update standings
    Standing::updateAfterMatch($match);
    echo "  Standings updated!\n\n";
}

// Recalculate positions
foreach ([55, 56] as $seasonId) {
    Standing::recalculatePositions($seasonId);
    echo "Positions recalculated for season $seasonId\n";
}

echo "\n=== Updated Standings ===\n";
foreach ([55, 56] as $seasonId) {
    echo "\nSeason $seasonId:\n";
    $standings = Standing::with('team')->where('season_id', $seasonId)->orderBy('position')->get();
    foreach ($standings as $s) {
        echo "  {$s->position}. {$s->team->name} - P:{$s->played} W:{$s->won} D:{$s->drawn} L:{$s->lost} GF:{$s->goals_for} GA:{$s->goals_against} Pts:{$s->points}\n";
    }
}

echo "\n=== Done ===\n";
