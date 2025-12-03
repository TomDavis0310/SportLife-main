<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\FootballMatch;

$min = FootballMatch::min('match_date');
$max = FootballMatch::max('match_date');
$count = FootballMatch::count();

echo "Matches: {$count} from {$min} to {$max}\n";
