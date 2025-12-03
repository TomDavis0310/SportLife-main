<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Team;
use App\Models\Player;

// Get all team IDs
$teamIds = Team::pluck('id')->toArray();

echo "Total teams: " . count($teamIds) . "\n";
echo "Assigning players to teams...\n";

// Assign each player to a random team
Player::chunk(20, function($players) use ($teamIds) {
    foreach ($players as $player) {
        $randomTeamId = $teamIds[array_rand($teamIds)];
        $player->update(['team_id' => $randomTeamId]);
    }
});

echo "Players assigned successfully!\n";

// Verify
foreach (Team::limit(5)->get() as $team) {
    $count = $team->activePlayers()->count();
    echo "Team {$team->name}: {$count} players\n";
}
