<?php

require_once __DIR__ . '/../vendor/autoload.php';

$app = require_once __DIR__ . '/../bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Standing;

$standings = Standing::with('team')->where('season_id', 55)->get();

echo "Season 55 standings: " . count($standings) . "\n";

foreach($standings as $s) {
    echo $s->position . '. ' . ($s->team->name ?? 'N/A') . ' - Points: ' . $s->points . ' - Goals: ' . $s->goals_for . "\n";
}
