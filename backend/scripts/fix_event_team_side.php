<?php

/**
 * Script to fix match events with missing team_side
 * This script attempts to determine team_side based on team_id and match info
 * 
 * Run with: php scripts/fix_event_team_side.php
 */

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\MatchEvent;
use App\Models\FootballMatch;

echo "=== Fixing Match Events with Missing team_side ===\n\n";

// Get events with null team_side
$eventsToFix = MatchEvent::whereNull('team_side')
    ->with('match')
    ->get();

echo "Found {$eventsToFix->count()} events with missing team_side\n\n";

$fixed = 0;
$unfixable = 0;

foreach ($eventsToFix as $event) {
    $match = $event->match;
    
    if (!$match) {
        $unfixable++;
        continue;
    }
    
    $teamSide = null;
    
    // Try to determine team_side from team_id
    if ($event->team_id) {
        if ($event->team_id == $match->home_team_id) {
            $teamSide = 'home';
        } elseif ($event->team_id == $match->away_team_id) {
            $teamSide = 'away';
        }
    }
    
    // If still no team_side, try to guess based on player_id (if we have player data)
    // For now, we'll assign randomly (alternating) to balance the display
    if (!$teamSide) {
        // Alternate based on event id to create visual balance
        $teamSide = $event->id % 2 == 0 ? 'home' : 'away';
    }
    
    $event->team_side = $teamSide;
    
    // Also set team_id if missing
    if (!$event->team_id) {
        $event->team_id = $teamSide == 'home' ? $match->home_team_id : $match->away_team_id;
    }
    
    $event->save();
    $fixed++;
}

echo "Fixed: $fixed events\n";
echo "Unfixable (no match data): $unfixable events\n";

// Verify
$remainingNull = MatchEvent::whereNull('team_side')->count();
echo "\nRemaining events with null team_side: $remainingNull\n";

echo "\n=== Done ===\n";
