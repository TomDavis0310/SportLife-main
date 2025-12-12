<?php

namespace App\Console\Commands;

use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Models\MatchStatistic;
use App\Models\Player;
use App\Enums\MatchStatus;
use Illuminate\Console\Command;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class AutoUpdateMatchResults extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'matches:auto-update 
                            {--hours=2 : Số giờ sau thời gian bắt đầu để coi như trận đấu đã kết thúc}
                            {--dry-run : Chỉ hiển thị các trận sẽ được cập nhật mà không thực sự cập nhật}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Tự động cập nhật kết quả mẫu cho các trận đấu đã qua thời gian thi đấu';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $hoursAfterStart = (int) $this->option('hours');
        $isDryRun = $this->option('dry-run');

        $this->info('🔄 Bắt đầu kiểm tra các trận đấu cần cập nhật...');
        $this->info("   Thời gian hiện tại: " . Carbon::now()->format('Y-m-d H:i:s'));
        $this->info("   Trận đấu được coi là kết thúc sau: {$hoursAfterStart} giờ từ thời gian bắt đầu");
        
        if ($isDryRun) {
            $this->warn('   🔍 CHẾ ĐỘ DRY-RUN: Chỉ hiển thị, không cập nhật thực sự');
        }

        // Tìm các trận đấu SCHEDULED hoặc LIVE mà đã qua thời gian thi đấu
        $cutoffTime = Carbon::now()->subHours($hoursAfterStart);
        
        $matches = FootballMatch::whereIn('status', [MatchStatus::SCHEDULED, MatchStatus::LIVE])
            ->where('match_date', '<', $cutoffTime)
            ->with(['homeTeam', 'awayTeam', 'round.season.competition'])
            ->get();

        if ($matches->isEmpty()) {
            $this->info('✅ Không có trận đấu nào cần cập nhật.');
            return 0;
        }

        $this->info("📋 Tìm thấy {$matches->count()} trận đấu cần cập nhật:");
        $this->newLine();

        $updatedCount = 0;
        $errorCount = 0;

        foreach ($matches as $match) {
            try {
                $competitionName = $match->round?->season?->competition?->name ?? 'N/A';
                $roundName = $match->round?->name ?? 'N/A';
                
                $this->line("  🏟️  {$match->homeTeam->name} vs {$match->awayTeam->name}");
                $this->line("     Giải: {$competitionName} - {$roundName}");
                $this->line("     Thời gian: {$match->match_date}");

                if (!$isDryRun) {
                    $this->updateMatchResult($match);
                    $this->info("     ✅ Đã cập nhật: {$match->home_score} - {$match->away_score}");
                } else {
                    $this->comment("     [DRY-RUN] Sẽ được cập nhật");
                }
                
                $this->newLine();
                $updatedCount++;

            } catch (\Exception $e) {
                $this->error("     ❌ Lỗi: {$e->getMessage()}");
                Log::error("Auto update match failed", [
                    'match_id' => $match->id,
                    'error' => $e->getMessage()
                ]);
                $errorCount++;
            }
        }

        $this->newLine();
        $this->info("📊 Kết quả:");
        $this->info("   - Trận đấu đã cập nhật: {$updatedCount}");
        if ($errorCount > 0) {
            $this->error("   - Lỗi: {$errorCount}");
        }

        // Log kết quả
        Log::info("Auto update match results completed", [
            'updated' => $updatedCount,
            'errors' => $errorCount,
            'dry_run' => $isDryRun
        ]);

        return $errorCount > 0 ? 1 : 0;
    }

    /**
     * Cập nhật kết quả trận đấu
     */
    private function updateMatchResult(FootballMatch $match): void
    {
        // Tạo kết quả ngẫu nhiên nhưng hợp lý
        $homeScore = $this->generateScore();
        $awayScore = $this->generateScore();

        // Cập nhật trận đấu
        $match->update([
            'status' => MatchStatus::FINISHED,
            'home_score' => $homeScore,
            'away_score' => $awayScore,
        ]);

        // Tạo events (bàn thắng, thẻ)
        $this->createMatchEvents($match, $homeScore, $awayScore);

        // Tạo thống kê
        $this->createMatchStatistics($match);
    }

    /**
     * Tạo điểm số ngẫu nhiên với phân phối hợp lý
     */
    private function generateScore(): int
    {
        // Phân phối điểm số hợp lý cho bóng đá
        // 0: 25%, 1: 30%, 2: 25%, 3: 12%, 4: 5%, 5+: 3%
        $rand = rand(1, 100);
        
        if ($rand <= 25) return 0;
        if ($rand <= 55) return 1;
        if ($rand <= 80) return 2;
        if ($rand <= 92) return 3;
        if ($rand <= 97) return 4;
        return rand(5, 6);
    }

    /**
     * Tạo các sự kiện trong trận đấu
     */
    private function createMatchEvents(FootballMatch $match, int $homeScore, int $awayScore): void
    {
        // Xóa events cũ (nếu có)
        MatchEvent::where('match_id', $match->id)->delete();

        // Lấy cầu thủ của 2 đội
        $homePlayers = Player::where('team_id', $match->home_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();
        $awayPlayers = Player::where('team_id', $match->away_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();

        // Tạo bàn thắng cho đội nhà
        $usedMinutes = [];
        for ($i = 0; $i < $homeScore; $i++) {
            if ($homePlayers->isNotEmpty()) {
                $minute = $this->getUniqueMinute($usedMinutes);
                $usedMinutes[] = $minute;
                
                MatchEvent::create([
                    'match_id' => $match->id,
                    'player_id' => $homePlayers->random()->id,
                    'type' => 'goal',
                    'minute' => $minute,
                    'description' => 'Bàn thắng',
                ]);
            }
        }

        // Tạo bàn thắng cho đội khách
        for ($i = 0; $i < $awayScore; $i++) {
            if ($awayPlayers->isNotEmpty()) {
                $minute = $this->getUniqueMinute($usedMinutes);
                $usedMinutes[] = $minute;
                
                MatchEvent::create([
                    'match_id' => $match->id,
                    'player_id' => $awayPlayers->random()->id,
                    'type' => 'goal',
                    'minute' => $minute,
                    'description' => 'Bàn thắng',
                ]);
            }
        }

        // Thêm một số thẻ vàng ngẫu nhiên (0-4 thẻ)
        $yellowCards = rand(0, 4);
        $allPlayers = $homePlayers->merge($awayPlayers);
        
        for ($i = 0; $i < $yellowCards; $i++) {
            if ($allPlayers->isNotEmpty()) {
                $minute = $this->getUniqueMinute($usedMinutes);
                $usedMinutes[] = $minute;
                
                MatchEvent::create([
                    'match_id' => $match->id,
                    'player_id' => $allPlayers->random()->id,
                    'type' => 'yellow_card',
                    'minute' => $minute,
                    'description' => 'Thẻ vàng',
                ]);
            }
        }
    }

    /**
     * Lấy phút duy nhất không trùng
     */
    private function getUniqueMinute(array $usedMinutes): int
    {
        do {
            $minute = rand(1, 90);
        } while (in_array($minute, $usedMinutes));
        
        return $minute;
    }

    /**
     * Tạo thống kê trận đấu
     */
    private function createMatchStatistics(FootballMatch $match): void
    {
        // Xóa thống kê cũ (nếu có)
        MatchStatistic::where('match_id', $match->id)->delete();

        $homePossession = rand(35, 65);

        // Thống kê đội nhà
        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'home',
            'possession' => $homePossession,
            'shots' => rand(8, 20),
            'shots_on_target' => rand(2, 10),
            'passes' => rand(300, 600),
            'pass_accuracy' => rand(70, 92),
            'fouls' => rand(8, 18),
            'yellow_cards' => rand(0, 4),
            'red_cards' => rand(0, 100) > 95 ? 1 : 0,
            'offsides' => rand(0, 6),
            'corners' => rand(2, 10),
        ]);

        // Thống kê đội khách (possession bổ sung)
        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'away',
            'possession' => 100 - $homePossession,
            'shots' => rand(6, 18),
            'shots_on_target' => rand(1, 8),
            'passes' => rand(280, 580),
            'pass_accuracy' => rand(68, 90),
            'fouls' => rand(8, 18),
            'yellow_cards' => rand(0, 4),
            'red_cards' => rand(0, 100) > 95 ? 1 : 0,
            'offsides' => rand(0, 6),
            'corners' => rand(2, 8),
        ]);
    }
}
