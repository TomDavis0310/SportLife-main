<?php

use App\Models\User;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$manager = User::where('email', 'manager@hagl.vn')->first();
$sponsor = User::where('email', 'sponsor@nike.com')->first();

echo "Manager Roles: " . implode(', ', $manager->getRoleNames()->toArray()) . "\n";
echo "Sponsor Roles: " . implode(', ', $sponsor->getRoleNames()->toArray()) . "\n";
