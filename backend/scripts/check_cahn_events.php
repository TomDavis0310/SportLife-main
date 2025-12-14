<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\MatchEvent;
use App\Models\FootballMatch;
use App\Models\Team;

echo "=== Checking CAHN Match Events ===\n\n";

// Find CAHN team
$cahn = Team::where('short_name', 'CAHN')
    ->orWhere('name', 'like', '%CAHN%')
    ->orWhere('name', 'like', '%Công An%')
    ->first();

if ($cahn) {
    echo "Found CAHN team: ID={$cahn->id}, Name={$cahn->name}\n\n";
    
    // Find matches with CAHN
    $matches = FootballMatch::where('home_team_id', $cahn->id)
        ->orWhere('away_team_id', $cahn->id)
        ->with(['homeTeam', 'awayTeam', 'events'])
        ->take(5)
        ->get();
    
    foreach ($matches as $match) {
        echo "Match ID: {$match->id}\n";
        echo "  Home: {$match->homeTeam->name} (ID: {$match->home_team_id})\n";
        echo "  Away: {$match->awayTeam->name} (ID: {$match->away_team_id})\n";
        echo "  Score: {$match->home_score} - {$match->away_score}\n";
        echo "  Events count: " . count($match->events) . "\n";
        
        foreach ($match->events as $event) {
            $side = $event->team_side ?? 'NULL';
            $teamId = $event->team_id ?? 'NULL';
            echo "    - {$event->minute}' {$event->type}: team_side={$side}, team_id={$teamId}\n";
        }
        echo "\n";
    }
} else {
    echo "CAHN team not found!\n";
    
    // List some teams
    $teams = Team::take(10)->get();
    echo "\nSample teams:\n";
    foreach ($teams as $t) {
        echo "  ID: {$t->id}, Name: {$t->name}, Short: {$t->short_name}\n";
    }
}
