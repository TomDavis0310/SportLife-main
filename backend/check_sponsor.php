<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$user = \App\Models\User::where('email', 'sponsor@nike.com')->first();
echo "User ID: " . $user->id . "\n";

$seasons = \App\Models\Season::where('sponsor_user_id', $user->id)->get();
echo "Seasons count: " . $seasons->count() . "\n";

foreach($seasons as $s) {
    echo "- Season: " . $s->name . " (Competition: " . $s->competition->name . ")\n";
}

// Check all seasons
echo "\n--- All Seasons ---\n";
$allSeasons = \App\Models\Season::with('competition')->get();
foreach($allSeasons as $s) {
    echo "- {$s->name} | sponsor_user_id: " . ($s->sponsor_user_id ?? 'NULL') . " | max_teams: " . ($s->max_teams ?? 'NULL') . "\n";
}
