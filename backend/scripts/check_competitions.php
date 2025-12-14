<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Competition;
use App\Models\Season;

echo "=== Competitions and Seasons ===\n\n";

$competitions = Competition::with(['seasons' => function($q) {
    $q->with('standings');
}])->where('is_active', true)->get();

foreach ($competitions as $comp) {
    echo "Competition: {$comp->name} (ID: {$comp->id})\n";
    foreach ($comp->seasons as $season) {
        $totalGoals = $season->standings->sum('goals_for');
        echo "  - Season: {$season->name} (ID: {$season->id}) - Standings: {$season->standings->count()}, Total Goals: {$totalGoals}\n";
    }
    echo "\n";
}
