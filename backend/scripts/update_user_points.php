<?php

use App\Models\User;

require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$email = $argv[1] ?? null;
$points = isset($argv[2]) ? (int) $argv[2] : null;

if (!$email || $points === null) {
    fwrite(STDERR, "Usage: php update_user_points.php <email> <points>\n");
    exit(1);
}

$user = User::where('email', $email)->first();

if (!$user) {
    fwrite(STDERR, "User not found: {$email}\n");
    exit(1);
}

$user->sport_points = $points;
$user->save();

echo "Updated {$email} to {$points} points\n";
