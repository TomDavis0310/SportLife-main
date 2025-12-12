<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$season = App\Models\Season::whereHas('competition', fn($q) => $q->where('short_name', 'PL16'))->first();

echo "=== LỊCH THI ĐẤU GIẢI PRO LEAGUE 16 ===" . PHP_EOL;
echo "Tất cả các vòng đấu (bao gồm knockout với đội TBD)" . PHP_EOL . PHP_EOL;

$rounds = App\Models\Round::where('season_id', $season->id)->orderBy('round_number')->get();

foreach ($rounds as $round) {
    $matches = App\Models\FootballMatch::where('round_id', $round->id)
        ->with(['homeTeam', 'awayTeam'])
        ->orderBy('match_date')
        ->get();
    
    if ($matches->isEmpty()) continue;
    
    echo "📅 " . $round->name . PHP_EOL;
    echo "   Ngày: " . \Carbon\Carbon::parse($round->start_date)->format('d/m/Y') . PHP_EOL;
    echo str_repeat("-", 60) . PHP_EOL;
    
    foreach ($matches as $match) {
        $home = $match->homeTeam ? $match->homeTeam->short_name : '⏳ TBD';
        $away = $match->awayTeam ? $match->awayTeam->short_name : '⏳ TBD';
        
        $dateTime = \Carbon\Carbon::parse($match->match_date)->format('d/m H:i');
        $status = $match->status;
        
        if ($match->status == 'finished') {
            $score = $match->home_score . '-' . $match->away_score;
            echo "  ✅ {$home} {$score} {$away} | {$dateTime}" . PHP_EOL;
        } else {
            echo "  📋 {$home} vs {$away} | {$dateTime} | {$match->venue}" . PHP_EOL;
        }
    }
    echo PHP_EOL;
}

// Tổng kết
$totalMatches = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->count();
$finishedMatches = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->where('status', 'finished')->count();
$tbdMatches = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->whereNull('home_team_id')->count();
$scheduledWithTeams = App\Models\FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $season->id))->where('status', 'scheduled')->whereNotNull('home_team_id')->count();

echo "=== TỔNG KẾT ===" . PHP_EOL;
echo "Tổng số trận: {$totalMatches}" . PHP_EOL;
echo "  - Đã hoàn thành: {$finishedMatches}" . PHP_EOL;
echo "  - Chưa đá (có đội): {$scheduledWithTeams}" . PHP_EOL;
echo "  - Chưa đá (đội TBD): {$tbdMatches}" . PHP_EOL;
echo "Tiến độ: " . round($finishedMatches / $totalMatches * 100) . "%" . PHP_EOL;
