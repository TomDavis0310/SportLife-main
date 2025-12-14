<?php

/**
 * Script to initialize standings for seasons that have locked registrations
 * but don't have standings yet.
 * 
 * Run with: php scripts/init_standings.php
 */

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Season;
use App\Models\Standing;

echo "=== Initializing Standings for Locked Seasons ===\n\n";

// Get all seasons that have registration_locked = true
$lockedSeasons = Season::where('registration_locked', true)
    ->with(['teams' => function($q) {
        $q->wherePivot('status', 'approved');
    }])
    ->get();

echo "Found " . $lockedSeasons->count() . " locked seasons.\n\n";

foreach ($lockedSeasons as $season) {
    echo "Processing Season: {$season->name} (ID: {$season->id})\n";
    
    $approvedTeams = $season->teams;
    echo "  - Approved teams: " . $approvedTeams->count() . "\n";
    
    $existingStandings = Standing::where('season_id', $season->id)->count();
    echo "  - Existing standings: {$existingStandings}\n";
    
    if ($existingStandings === 0 && $approvedTeams->count() > 0) {
        $position = 1;
        foreach ($approvedTeams as $team) {
            Standing::firstOrCreate(
                [
                    'season_id' => $season->id,
                    'team_id' => $team->id,
                ],
                [
                    'position' => $position++,
                    'played' => 0,
                    'won' => 0,
                    'drawn' => 0,
                    'lost' => 0,
                    'goals_for' => 0,
                    'goals_against' => 0,
                    'goal_difference' => 0,
                    'points' => 0,
                    'form' => '',
                ]
            );
        }
        echo "  - Created {$approvedTeams->count()} standings\n";
    } else {
        echo "  - Skipped (standings already exist or no approved teams)\n";
    }
    echo "\n";
}

echo "=== Done ===\n";
