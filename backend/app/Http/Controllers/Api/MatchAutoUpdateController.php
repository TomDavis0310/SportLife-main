<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Models\MatchStatistic;
use App\Models\Player;
use App\Enums\MatchStatus;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;

class MatchAutoUpdateController extends Controller
{
    /**
     * Lấy danh sách các trận đấu cần cập nhật
     */
    public function getPendingMatches(Request $request)
    {
        $hours = $request->get('hours', 2);
        $cutoffTime = Carbon::now()->subHours($hours);

        $matches = FootballMatch::whereIn('status', [MatchStatus::SCHEDULED, MatchStatus::LIVE])
            ->where('match_date', '<', $cutoffTime)
            ->with(['homeTeam:id,name,short_name,logo', 'awayTeam:id,name,short_name,logo', 'round.season.competition'])
            ->orderBy('match_date', 'desc')
            ->get()
            ->map(function ($match) {
                return [
                    'id' => $match->id,
                    'home_team' => $match->homeTeam,
                    'away_team' => $match->awayTeam,
                    'match_date' => $match->match_date,
                    'status' => $match->status,
                    'competition' => $match->round?->season?->competition?->name,
                    'round' => $match->round?->name,
                    'venue' => $match->venue,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'pending_count' => $matches->count(),
                'matches' => $matches,
                'cutoff_time' => $cutoffTime->format('Y-m-d H:i:s'),
            ]
        ]);
    }

    /**
     * Trigger cập nhật tự động (Admin only)
     */
    public function triggerAutoUpdate(Request $request)
    {
        // Kiểm tra quyền admin
        if (!$request->user()->hasRole('admin')) {
            return response()->json(['message' => 'Chỉ admin mới có quyền thực hiện'], 403);
        }

        $hours = $request->get('hours', 2);

        try {
            // Chạy command
            $exitCode = Artisan::call('matches:auto-update', [
                '--hours' => $hours
            ]);

            $output = Artisan::output();

            Log::info('Admin triggered auto update match results', [
                'user_id' => $request->user()->id,
                'hours' => $hours,
                'exit_code' => $exitCode
            ]);

            return response()->json([
                'success' => $exitCode === 0,
                'message' => $exitCode === 0 
                    ? 'Đã cập nhật kết quả trận đấu thành công' 
                    : 'Có lỗi khi cập nhật',
                'output' => $output,
            ]);

        } catch (\Exception $e) {
            Log::error('Auto update match results failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Lỗi: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cập nhật kết quả cho một trận đấu cụ thể (Admin/Sponsor)
     */
    public function updateSingleMatch(Request $request, $matchId)
    {
        $user = $request->user();
        
        // Kiểm tra quyền
        if (!$user->hasRole('admin') && !$user->hasRole('sponsor')) {
            return response()->json(['message' => 'Không có quyền thực hiện'], 403);
        }

        $match = FootballMatch::with(['homeTeam', 'awayTeam', 'round.season'])
            ->findOrFail($matchId);

        // Nếu là sponsor, kiểm tra xem có phải giải của họ không
        if ($user->hasRole('sponsor') && !$user->hasRole('admin')) {
            $season = $match->round?->season;
            if (!$season || $season->sponsor_user_id !== $user->id) {
                return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
            }
        }

        // Validate nếu người dùng muốn set kết quả cụ thể
        if ($request->has('home_score') || $request->has('away_score')) {
            $request->validate([
                'home_score' => 'required|integer|min:0|max:20',
                'away_score' => 'required|integer|min:0|max:20',
            ]);

            $homeScore = $request->home_score;
            $awayScore = $request->away_score;
        } else {
            // Tự động tạo kết quả ngẫu nhiên
            $homeScore = $this->generateScore();
            $awayScore = $this->generateScore();
        }

        // Cập nhật trận đấu
        $match->update([
            'status' => MatchStatus::FINISHED,
            'home_score' => $homeScore,
            'away_score' => $awayScore,
        ]);

        // Tạo events và statistics
        $this->createMatchEvents($match, $homeScore, $awayScore);
        $this->createMatchStatistics($match);

        return response()->json([
            'success' => true,
            'message' => 'Đã cập nhật kết quả trận đấu',
            'data' => [
                'match_id' => $match->id,
                'home_team' => $match->homeTeam->name,
                'away_team' => $match->awayTeam->name,
                'home_score' => $homeScore,
                'away_score' => $awayScore,
                'status' => 'finished',
            ]
        ]);
    }

    /**
     * Tạo điểm số ngẫu nhiên
     */
    private function generateScore(): int
    {
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
        MatchEvent::where('match_id', $match->id)->delete();

        $homePlayers = Player::where('team_id', $match->home_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();
        $awayPlayers = Player::where('team_id', $match->away_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();

        $usedMinutes = [];

        // Bàn thắng đội nhà
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

        // Bàn thắng đội khách
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

        // Thẻ vàng
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
        MatchStatistic::where('match_id', $match->id)->delete();

        $homePossession = rand(35, 65);

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
