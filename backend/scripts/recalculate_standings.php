<?php

/**
 * Script to recalculate all standings from scratch based on finished matches.
 * This script resets all standings and recalculates them from finished matches.
 * 
 * Run with: php scripts/recalculate_standings.php
 */

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\FootballMatch;
use App\Models\Standing;
use App\Models\Season;

echo "=== Recalculating All Standings From Scratch ===\n\n";

// Get all seasons with locked registration
$seasons = Season::where('registration_locked', true)
    ->with(['teams' => function($q) {
        $q->wherePivot('status', 'approved');
    }])
    ->get();

foreach ($seasons as $season) {
    echo "Processing Season: {$season->name} (ID: {$season->id})\n";
    
    // Reset all standings for this season
    Standing::where('season_id', $season->id)->delete();
    echo "  - Reset existing standings\n";
    
    // Initialize standings for all approved teams with 0 values
    $approvedTeams = $season->teams;
    $standingsMap = [];
    
    foreach ($approvedTeams as $team) {
        $standing = Standing::create([
            'season_id' => $season->id,
            'team_id' => $team->id,
            'position' => 1,
            'played' => 0,
            'won' => 0,
            'drawn' => 0,
            'lost' => 0,
            'goals_for' => 0,
            'goals_against' => 0,
            'goal_difference' => 0,
            'points' => 0,
            'form' => '',
        ]);
        $standingsMap[$team->id] = $standing;
    }
    echo "  - Initialized {$approvedTeams->count()} team standings\n";
    
    // Get all finished matches for this season
    $finishedMatches = FootballMatch::whereHas('round', function($q) use ($season) {
        $q->where('season_id', $season->id);
    })
    ->where('status', 'finished')
    ->orderBy('match_date')
    ->get();
    
    echo "  - Found {$finishedMatches->count()} finished matches\n";
    
    foreach ($finishedMatches as $match) {
        // Get standings for both teams
        $homeStanding = $standingsMap[$match->home_team_id] ?? null;
        $awayStanding = $standingsMap[$match->away_team_id] ?? null;
        
        if (!$homeStanding || !$awayStanding) {
            continue;
        }
        
        $homeWin = $match->home_score > $match->away_score;
        $awayWin = $match->away_score > $match->home_score;
        $draw = $match->home_score == $match->away_score;
        
        // Update home team
        $homeStanding->played++;
        $homeStanding->goals_for += $match->home_score;
        $homeStanding->goals_against += $match->away_score;
        $homeStanding->goal_difference = $homeStanding->goals_for - $homeStanding->goals_against;
        
        if ($homeWin) {
            $homeStanding->won++;
            $homeStanding->points += 3;
            $homeStanding->form = substr(($homeStanding->form ?? '') . 'W', -5);
        } elseif ($draw) {
            $homeStanding->drawn++;
            $homeStanding->points += 1;
            $homeStanding->form = substr(($homeStanding->form ?? '') . 'D', -5);
        } else {
            $homeStanding->lost++;
            $homeStanding->form = substr(($homeStanding->form ?? '') . 'L', -5);
        }
        
        // Update away team
        $awayStanding->played++;
        $awayStanding->goals_for += $match->away_score;
        $awayStanding->goals_against += $match->home_score;
        $awayStanding->goal_difference = $awayStanding->goals_for - $awayStanding->goals_against;
        
        if ($awayWin) {
            $awayStanding->won++;
            $awayStanding->points += 3;
            $awayStanding->form = substr(($awayStanding->form ?? '') . 'W', -5);
        } elseif ($draw) {
            $awayStanding->drawn++;
            $awayStanding->points += 1;
            $awayStanding->form = substr(($awayStanding->form ?? '') . 'D', -5);
        } else {
            $awayStanding->lost++;
            $awayStanding->form = substr(($awayStanding->form ?? '') . 'L', -5);
        }
    }
    
    // Save all standings and recalculate positions
    foreach ($standingsMap as $standing) {
        $standing->save();
    }
    
    Standing::recalculatePositions($season->id);
    echo "  - Standings calculated and positions updated\n\n";
}

// Print final standings
echo "=== Final Standings ===\n";
foreach ($seasons as $season) {
    echo "\n{$season->name} (Season ID: {$season->id}):\n";
    $standings = Standing::with('team')->where('season_id', $season->id)->orderBy('position')->get();
    $totalGoals = 0;
    foreach ($standings as $s) {
        echo "  {$s->position}. {$s->team->name} - P:{$s->played} W:{$s->won} D:{$s->drawn} L:{$s->lost} GF:{$s->goals_for} GA:{$s->goals_against} GD:{$s->goal_difference} Pts:{$s->points} Form:{$s->form}\n";
        $totalGoals += $s->goals_for;
    }
    echo "  Total Goals: {$totalGoals}\n";
}

echo "\n=== Done ===\n";
