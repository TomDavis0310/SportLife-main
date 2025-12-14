<?php

/**
 * Script to check and create standings for current seasons
 * that have finished matches but no standings yet.
 */

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\FootballMatch;
use App\Models\Standing;
use App\Models\Season;

echo "=== Creating Standings for Current Seasons ===\n\n";

// Get all current seasons that don't have standings yet
$currentSeasons = Season::where('is_current', true)
    ->whereDoesntHave('standings')
    ->get();

echo "Found {$currentSeasons->count()} current seasons without standings\n\n";

foreach ($currentSeasons as $season) {
    echo "Processing Season: {$season->name} (ID: {$season->id}, Competition ID: {$season->competition_id})\n";
    
    // Get all finished matches for this season
    $finishedMatches = FootballMatch::whereHas('round', function($q) use ($season) {
        $q->where('season_id', $season->id);
    })
    ->where('status', 'finished')
    ->get();
    
    echo "  - Found {$finishedMatches->count()} finished matches\n";
    
    if ($finishedMatches->count() === 0) {
        echo "  - Skipping (no finished matches)\n\n";
        continue;
    }
    
    // Get unique team IDs from matches
    $teamIds = $finishedMatches->pluck('home_team_id')
        ->merge($finishedMatches->pluck('away_team_id'))
        ->unique();
    
    echo "  - Found {$teamIds->count()} unique teams in matches\n";
    
    // Initialize standings for all teams
    $standingsMap = [];
    $position = 1;
    foreach ($teamIds as $teamId) {
        $standing = Standing::firstOrCreate(
            [
                'season_id' => $season->id,
                'team_id' => $teamId,
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
        $standingsMap[$teamId] = $standing;
    }
    
    echo "  - Initialized {$teamIds->count()} standings\n";
    
    // Process each match
    foreach ($finishedMatches as $match) {
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
    
    // Save all standings
    foreach ($standingsMap as $standing) {
        $standing->save();
    }
    
    // Recalculate positions
    Standing::recalculatePositions($season->id);
    echo "  - Standings saved and positions recalculated\n\n";
}

echo "=== Done ===\n";
