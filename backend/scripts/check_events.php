<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\MatchEvent;
use App\Models\FootballMatch;

echo "=== Checking Match Events Data ===\n\n";

// Get sample events
$events = MatchEvent::with(['match'])->take(20)->get();

echo "Sample events:\n";
foreach ($events as $event) {
    $match = $event->match;
    echo "Event ID: {$event->id}\n";
    echo "  - Type: {$event->type}\n";
    echo "  - Minute: {$event->minute}\n";
    echo "  - Team Side: " . ($event->team_side ?? 'NULL') . "\n";
    echo "  - Team ID: " . ($event->team_id ?? 'NULL') . "\n";
    if ($match) {
        echo "  - Match Home Team ID: {$match->home_team_id}\n";
        echo "  - Match Away Team ID: {$match->away_team_id}\n";
    }
    echo "\n";
}

// Count by team_side
$homeSideCount = MatchEvent::where('team_side', 'home')->count();
$awaySideCount = MatchEvent::where('team_side', 'away')->count();
$nullSideCount = MatchEvent::whereNull('team_side')->count();

echo "=== Statistics ===\n";
echo "Events with team_side = 'home': $homeSideCount\n";
echo "Events with team_side = 'away': $awaySideCount\n";
echo "Events with team_side = NULL: $nullSideCount\n";
