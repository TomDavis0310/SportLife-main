<?php

namespace Database\Seeders;

use App\Models\Competition;
use App\Models\Season;
use App\Models\Round;
use App\Models\Team;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Models\MatchStatistic;
use App\Models\Player;
use App\Models\User;
use App\Enums\MatchStatus;
use Illuminate\Database\Seeder;
use Carbon\Carbon;
use Illuminate\Support\Str;

class ProLeague16TeamsSeeder extends Seeder
{
    public function run(): void
    {
        $sponsor = User::where('email', 'sponsor@nike.com')->first();
        if (!$sponsor) {
            $this->command->info('Sponsor user not found. Please run UserSeeder first.');
            return;
        }

        // Xóa dữ liệu cũ của giải này
        $this->cleanOldData();

        // 1. Create Competition
        $competition = Competition::updateOrCreate(
            ['short_name' => 'PL16'],
            [
                'name' => 'Pro League 16',
                'type' => 'cup', // Thay đổi thành cup vì có vòng bảng + knockout
                'country' => 'Vietnam',
                'logo' => 'competitions/pro-league-16.png',
                'description' => 'Giải bóng đá chuyên nghiệp 16 đội - Vòng bảng + Knock-out - Mùa giải 2025',
                'is_active' => true,
            ]
        );

        $this->command->info('Created competition: Pro League 16 (Vòng bảng)');

        // 2. Create 16 Teams - chia thành 4 bảng
        $proTeams = [
            // Bảng A - Các đội mạnh miền Bắc
            ['name' => 'Hà Nội United', 'short_name' => 'HNU', 'city' => 'Hà Nội', 'stadium' => 'Sân Mỹ Đình', 'primary_color' => '#800000', 'secondary_color' => '#FFD700', 'group' => 'A'],
            ['name' => 'Hải Phòng Red', 'short_name' => 'HPR', 'city' => 'Hải Phòng', 'stadium' => 'Sân Lạch Tray', 'primary_color' => '#DC143C', 'secondary_color' => '#000000', 'group' => 'A'],
            ['name' => 'Quảng Ninh Coal', 'short_name' => 'QNC', 'city' => 'Quảng Ninh', 'stadium' => 'Sân Cẩm Phả', 'primary_color' => '#000000', 'secondary_color' => '#FFD700', 'group' => 'A'],
            ['name' => 'Bắc Ninh Phoenix', 'short_name' => 'BNP', 'city' => 'Bắc Ninh', 'stadium' => 'Sân Bắc Ninh', 'primary_color' => '#FF4500', 'secondary_color' => '#000000', 'group' => 'A'],
            
            // Bảng B - Các đội miền Trung
            ['name' => 'Đà Nẵng Stars', 'short_name' => 'DNS', 'city' => 'Đà Nẵng', 'stadium' => 'Sân Hòa Xuân', 'primary_color' => '#FF8C00', 'secondary_color' => '#FFFFFF', 'group' => 'B'],
            ['name' => 'Nghệ An Warriors', 'short_name' => 'NAW', 'city' => 'Vinh', 'stadium' => 'Sân Vinh', 'primary_color' => '#FFD700', 'secondary_color' => '#000000', 'group' => 'B'],
            ['name' => 'Thanh Hóa Blues', 'short_name' => 'THB', 'city' => 'Thanh Hóa', 'stadium' => 'Sân Thanh Hóa', 'primary_color' => '#4169E1', 'secondary_color' => '#FFFFFF', 'group' => 'B'],
            ['name' => 'Huế Royal', 'short_name' => 'HUR', 'city' => 'Huế', 'stadium' => 'Sân Tự Do', 'primary_color' => '#800080', 'secondary_color' => '#FFD700', 'group' => 'B'],
            
            // Bảng C - Các đội Tây Nguyên & Nam Trung Bộ  
            ['name' => 'Khánh Hòa Ocean', 'short_name' => 'KHO', 'city' => 'Nha Trang', 'stadium' => 'Sân 19-8', 'primary_color' => '#00CED1', 'secondary_color' => '#FFFFFF', 'group' => 'C'],
            ['name' => 'Pleiku Highland', 'short_name' => 'PLH', 'city' => 'Pleiku', 'stadium' => 'Sân Pleiku', 'primary_color' => '#006400', 'secondary_color' => '#FFFFFF', 'group' => 'C'],
            ['name' => 'Quy Nhơn Beach', 'short_name' => 'QNB', 'city' => 'Quy Nhơn', 'stadium' => 'Sân Quy Nhơn', 'primary_color' => '#F0E68C', 'secondary_color' => '#8B4513', 'group' => 'C'],
            ['name' => 'Vũng Tàu Port', 'short_name' => 'VTP', 'city' => 'Vũng Tàu', 'stadium' => 'Sân Vũng Tàu', 'primary_color' => '#4682B4', 'secondary_color' => '#FFFFFF', 'group' => 'C'],
            
            // Bảng D - Các đội miền Nam
            ['name' => 'FC Sài Gòn', 'short_name' => 'SGN', 'city' => 'TP.HCM', 'stadium' => 'Sân Thống Nhất', 'primary_color' => '#FF0000', 'secondary_color' => '#FFFFFF', 'group' => 'D'],
            ['name' => 'Bình Dương Lions', 'short_name' => 'BDL', 'city' => 'Bình Dương', 'stadium' => 'Sân Gò Đậu', 'primary_color' => '#0000FF', 'secondary_color' => '#FFFFFF', 'group' => 'D'],
            ['name' => 'Long An Delta', 'short_name' => 'LAD', 'city' => 'Long An', 'stadium' => 'Sân Long An', 'primary_color' => '#32CD32', 'secondary_color' => '#FFFFFF', 'group' => 'D'],
            ['name' => 'Cần Thơ FC', 'short_name' => 'CTF', 'city' => 'Cần Thơ', 'stadium' => 'Sân Cần Thơ', 'primary_color' => '#228B22', 'secondary_color' => '#FFFFFF', 'group' => 'D'],
        ];

        $teams = [];
        $teamsByGroup = ['A' => [], 'B' => [], 'C' => [], 'D' => []];
        
        foreach ($proTeams as $teamData) {
            $group = $teamData['group'];
            unset($teamData['group']);
            
            $teamData['country'] = 'Vietnam';
            $teamData['founded_year'] = rand(1995, 2015);
            $teamData['logo'] = 'teams/' . Str::slug($teamData['name']) . '.png';
            $teamData['secondary_color'] = $teamData['secondary_color'] ?? '#FFFFFF';
            
            $team = Team::updateOrCreate(
                ['short_name' => $teamData['short_name']],
                $teamData
            );
            $teams[] = $team;
            $teamsByGroup[$group][] = $team;
            
            // Create players for each team (18 players)
            $this->createPlayersForTeam($team);
        }

        $this->command->info('Created 16 teams with players (4 groups x 4 teams)');

        // 3. Create Season
        $season = Season::updateOrCreate(
            [
                'competition_id' => $competition->id,
                'name' => '2025',
            ],
            [
                'start_date' => '2025-08-01',
                'end_date' => '2025-12-15',
                'is_current' => true,
                'sponsor_user_id' => $sponsor->id,
                'registration_locked' => true,
                'max_teams' => 16,
            ]
        );

        $this->command->info('Created season 2025');

        // 4. Register all teams to season with group info
        foreach ($proTeams as $index => $teamData) {
            $team = $teams[$index];
            $group = ['A', 'A', 'A', 'A', 'B', 'B', 'B', 'B', 'C', 'C', 'C', 'C', 'D', 'D', 'D', 'D'][$index];
            $season->teams()->syncWithoutDetaching([
                $team->id => [
                    'status' => 'approved', 
                    'group_name' => $group,
                    'created_at' => now(), 
                    'updated_at' => now()
                ]
            ]);
        }

        $this->command->info('Registered all 16 teams to season with groups');

        /*
         * THỂ THỨC GIẢI ĐẤU:
         * - Vòng bảng: 4 bảng x 4 đội, đá vòng tròn 2 lượt (6 vòng) = 24 trận/bảng x 4 = 48 trận (ĐÃ HOÀN THÀNH)
         * - Tứ kết: 4 trận (ĐÃ HOÀN THÀNH) 
         * - Bán kết: 2 trận (CHƯA ĐÁ)
         * - Chung kết: 1 trận (CHƯA ĐÁ)
         * 
         * Tiến độ: Vòng bảng + Tứ kết hoàn thành = 52/55 trận ≈ 95%, nhưng để 50% thì chỉ hoàn thành vòng bảng
         */

        $roundStartDate = Carbon::parse('2025-08-01');
        $rounds = [];
        
        // ========== VÒNG BẢNG (6 vòng) ==========
        // Mỗi bảng 4 đội đá vòng tròn 2 lượt = 6 trận/đội, 12 trận/bảng
        // Vòng 1-3: Lượt đi, Vòng 4-6: Lượt về
        
        for ($i = 1; $i <= 6; $i++) {
            $round = Round::updateOrCreate(
                [
                    'season_id' => $season->id,
                    'round_number' => $i,
                ],
                [
                    'name' => "Vòng bảng - Lượt " . ($i <= 3 ? "đi" : "về") . " - Vòng " . (($i - 1) % 3 + 1),
                    'start_date' => $roundStartDate->copy(),
                    'end_date' => $roundStartDate->copy()->addDays(2),
                ]
            );
            $rounds[] = $round;
            $roundStartDate->addWeeks(1);
        }
        
        $this->command->info('Created 6 group stage rounds');

        // Tạo lịch thi đấu vòng bảng cho từng bảng
        $groupStageMatches = 0;
        $completedGroupMatches = 0;
        $completedRounds = 3; // CHỈ HOÀN THÀNH 3 VÒNG ĐẦU (Lượt đi) = 50%
        
        foreach (['A', 'B', 'C', 'D'] as $groupName) {
            $groupTeams = $teamsByGroup[$groupName];
            $schedule = $this->generateGroupSchedule($groupTeams);
            
            foreach ($schedule as $roundIndex => $matchPairs) {
                $round = $rounds[$roundIndex];
                $matchDate = Carbon::parse($round->start_date)->addHours(17);
                
                // Xác định trạng thái: 3 vòng đầu hoàn thành, 3 vòng sau chưa đá
                $isCompleted = ($roundIndex < $completedRounds);
                
                foreach ($matchPairs as $pairIndex => $pair) {
                    if ($isCompleted) {
                        $result = $this->generateRealisticScore();
                        $match = FootballMatch::create([
                            'round_id' => $round->id,
                            'home_team_id' => $pair[0]->id,
                            'away_team_id' => $pair[1]->id,
                            'match_date' => $matchDate->copy(),
                            'venue' => $pair[0]->stadium,
                            'status' => MatchStatus::FINISHED,
                            'home_score' => $result['home'],
                            'away_score' => $result['away'],
                        ]);
                        
                        $this->createMatchEvents($match, $result['home'], $result['away']);
                        $this->createMatchStatistics($match);
                        $completedGroupMatches++;
                    } else {
                        FootballMatch::create([
                            'round_id' => $round->id,
                            'home_team_id' => $pair[0]->id,
                            'away_team_id' => $pair[1]->id,
                            'match_date' => $matchDate->copy(),
                            'venue' => $pair[0]->stadium,
                            'status' => MatchStatus::SCHEDULED,
                            'home_score' => null,
                            'away_score' => null,
                        ]);
                    }
                    
                    $groupStageMatches++;
                    $matchDate->addHours(2);
                }
            }
        }
        
        $this->command->info("Created {$groupStageMatches} group stage matches ({$completedGroupMatches} completed, " . ($groupStageMatches - $completedGroupMatches) . " scheduled)");

        // ========== TỨ KẾT (Quarter Finals) ==========
        // Tạo 4 trận tứ kết với thời gian xác định, nhưng đội thi đấu chưa xác định (TBD)
        $roundStartDate->addWeeks(1);
        $quarterFinalRound = Round::updateOrCreate(
            [
                'season_id' => $season->id,
                'round_number' => 7,
            ],
            [
                'name' => 'Tứ kết',
                'start_date' => $roundStartDate->copy(),
                'end_date' => $roundStartDate->copy()->addDays(2),
            ]
        );
        $rounds[] = $quarterFinalRound;

        // Tạo 4 trận tứ kết (đội TBD)
        $qfMatchDate = Carbon::parse($quarterFinalRound->start_date)->addHours(17);
        $qfLabels = ['QF1: Nhất A vs Nhì B', 'QF2: Nhất B vs Nhì A', 'QF3: Nhất C vs Nhì D', 'QF4: Nhất D vs Nhì C'];
        
        for ($i = 0; $i < 4; $i++) {
            FootballMatch::create([
                'round_id' => $quarterFinalRound->id,
                'home_team_id' => null, // TBD - chờ vòng bảng kết thúc
                'away_team_id' => null, // TBD
                'match_date' => $qfMatchDate->copy(),
                'venue' => 'Sân Mỹ Đình', // Sân trung lập
                'status' => MatchStatus::SCHEDULED,
                'home_score' => null,
                'away_score' => null,
            ]);
            $qfMatchDate->addHours(3);
        }
        
        $this->command->info('Created 4 quarter-final matches (teams TBD - waiting for group stage)');

        // ========== BÁN KẾT (Semi Finals) ==========
        $roundStartDate->addWeeks(1);
        $semiFinalRound = Round::updateOrCreate(
            [
                'season_id' => $season->id,
                'round_number' => 8,
            ],
            [
                'name' => 'Bán kết',
                'start_date' => $roundStartDate->copy(),
                'end_date' => $roundStartDate->copy()->addDays(1),
            ]
        );
        $rounds[] = $semiFinalRound;

        // Tạo 2 trận bán kết (đội TBD)
        $sfMatchDate = Carbon::parse($semiFinalRound->start_date)->addHours(18);
        
        for ($i = 0; $i < 2; $i++) {
            FootballMatch::create([
                'round_id' => $semiFinalRound->id,
                'home_team_id' => null, // TBD - chờ tứ kết
                'away_team_id' => null, // TBD
                'match_date' => $sfMatchDate->copy(),
                'venue' => 'Sân Mỹ Đình',
                'status' => MatchStatus::SCHEDULED,
                'home_score' => null,
                'away_score' => null,
            ]);
            $sfMatchDate->addDays(1);
        }
        
        $this->command->info('Created 2 semi-final matches (teams TBD)');

        // ========== CHUNG KẾT (Final) ==========
        $roundStartDate->addWeeks(1);
        $finalRound = Round::updateOrCreate(
            [
                'season_id' => $season->id,
                'round_number' => 9,
            ],
            [
                'name' => 'Chung kết',
                'start_date' => $roundStartDate->copy(),
                'end_date' => $roundStartDate->copy(),
            ]
        );
        $rounds[] = $finalRound;

        // Tạo 1 trận chung kết (đội TBD)
        FootballMatch::create([
            'round_id' => $finalRound->id,
            'home_team_id' => null, // TBD - chờ bán kết
            'away_team_id' => null, // TBD
            'match_date' => Carbon::parse($finalRound->start_date)->addHours(19),
            'venue' => 'Sân Mỹ Đình',
            'status' => MatchStatus::SCHEDULED,
            'home_score' => null,
            'away_score' => null,
        ]);
        
        $this->command->info('Created 1 final match (teams TBD)');

        // ========== SUMMARY ==========
        $totalGroupMatches = $groupStageMatches; // 48 trận vòng bảng
        $totalKnockoutMatches = 7; // 4 tứ kết + 2 bán kết + 1 chung kết
        $totalMatches = $totalGroupMatches + $totalKnockoutMatches; // 55 trận
        $completedMatches = $completedGroupMatches;
        $scheduledMatches = $totalMatches - $completedMatches;
        
        $this->command->info('');
        $this->command->info('╔══════════════════════════════════════════════════════════╗');
        $this->command->info('║     GIẢI ĐẤU PRO LEAGUE 16 - VÒNG BẢNG ĐÃ TẠO          ║');
        $this->command->info('╠══════════════════════════════════════════════════════════╣');
        $this->command->info("║  Competition: {$competition->name}");
        $this->command->info("║  Season: {$season->name}");
        $this->command->info("║  Teams: 16 (4 bảng x 4 đội)");
        $this->command->info('╠══════════════════════════════════════════════════════════╣');
        $this->command->info('║  THỂ THỨC:');
        $this->command->info('║  • Vòng bảng lượt đi: 3 vòng (24 trận) - ĐÃ HOÀN THÀNH ✓');
        $this->command->info('║  • Vòng bảng lượt về: 3 vòng (24 trận) - CHƯA ĐÁ');
        $this->command->info('║  • Tứ kết: 4 trận - ĐỘI CHƯA XÁC ĐỊNH (có lịch)');
        $this->command->info('║  • Bán kết: 2 trận - ĐỘI CHƯA XÁC ĐỊNH (có lịch)');
        $this->command->info('║  • Chung kết: 1 trận - ĐỘI CHƯA XÁC ĐỊNH (có lịch)');
        $this->command->info('╠══════════════════════════════════════════════════════════╣');
        $this->command->info("║  Tổng số trận: {$totalMatches}");
        $this->command->info("║  Đã hoàn thành: {$completedMatches} trận");
        $this->command->info("║  Chưa đá: {$scheduledMatches} trận (trong đó 7 trận knockout đội TBD)");
        $this->command->info("║  Tiến độ: " . round($completedMatches / $totalMatches * 100) . "%");
        $this->command->info('╚══════════════════════════════════════════════════════════╝');
        
        // In bảng xếp hạng từng bảng
        $this->command->info('');
        $this->command->info('=== BẢNG XẾP HẠNG VÒNG BẢNG ===');
        foreach (['A', 'B', 'C', 'D'] as $groupName) {
            $standings = $this->calculateGroupStandings($season->id, $teamsByGroup[$groupName]);
            $this->command->info('');
            $this->command->info("--- Bảng {$groupName} ---");
            $rank = 1;
            foreach ($standings as $team) {
                $qualified = $rank <= 2 ? '✓' : '';
                $this->command->info("{$rank}. {$team['team']->short_name} | {$team['played']}đ | {$team['wins']}T {$team['draws']}H {$team['losses']}B | {$team['gf']}-{$team['ga']} | {$team['points']}đ {$qualified}");
                $rank++;
            }
        }
    }
    
    private function cleanOldData(): void
    {
        $competition = Competition::where('short_name', 'PL16')->first();
        if ($competition) {
            $season = Season::where('competition_id', $competition->id)->first();
            if ($season) {
                $roundIds = Round::where('season_id', $season->id)->pluck('id');
                $matchIds = FootballMatch::whereIn('round_id', $roundIds)->pluck('id');
                
                MatchEvent::whereIn('match_id', $matchIds)->delete();
                MatchStatistic::whereIn('match_id', $matchIds)->delete();
                FootballMatch::whereIn('round_id', $roundIds)->delete();
                Round::where('season_id', $season->id)->delete();
                
                $season->teams()->detach();
            }
        }
        
        $this->command->info('Cleaned old Pro League 16 data');
    }

    private function generateGroupSchedule(array $teams): array
    {
        // 4 đội đá vòng tròn 2 lượt = 6 vòng
        // Lượt đi (3 vòng) + Lượt về (3 vòng)
        $schedule = [];
        
        // Lượt đi
        $schedule[0] = [[$teams[0], $teams[1]], [$teams[2], $teams[3]]]; // V1
        $schedule[1] = [[$teams[0], $teams[2]], [$teams[1], $teams[3]]]; // V2  
        $schedule[2] = [[$teams[0], $teams[3]], [$teams[1], $teams[2]]]; // V3
        
        // Lượt về (đổi sân)
        $schedule[3] = [[$teams[1], $teams[0]], [$teams[3], $teams[2]]]; // V4
        $schedule[4] = [[$teams[2], $teams[0]], [$teams[3], $teams[1]]]; // V5
        $schedule[5] = [[$teams[3], $teams[0]], [$teams[2], $teams[1]]]; // V6
        
        return $schedule;
    }
    
    private function calculateGroupStandings(int $seasonId, array $teams): array
    {
        $standings = [];
        
        foreach ($teams as $team) {
            $matches = FootballMatch::whereHas('round', fn($q) => $q->where('season_id', $seasonId))
                ->where('status', 'finished')
                ->where(function($q) use ($team) {
                    $q->where('home_team_id', $team->id)->orWhere('away_team_id', $team->id);
                })->get();
            
            $wins = 0; $draws = 0; $losses = 0; $gf = 0; $ga = 0;
            
            foreach ($matches as $match) {
                if ($match->home_team_id == $team->id) {
                    $gf += $match->home_score;
                    $ga += $match->away_score;
                    if ($match->home_score > $match->away_score) $wins++;
                    elseif ($match->home_score == $match->away_score) $draws++;
                    else $losses++;
                } else {
                    $gf += $match->away_score;
                    $ga += $match->home_score;
                    if ($match->away_score > $match->home_score) $wins++;
                    elseif ($match->away_score == $match->home_score) $draws++;
                    else $losses++;
                }
            }
            
            $standings[] = [
                'team' => $team,
                'played' => $wins + $draws + $losses,
                'wins' => $wins,
                'draws' => $draws,
                'losses' => $losses,
                'gf' => $gf,
                'ga' => $ga,
                'gd' => $gf - $ga,
                'points' => $wins * 3 + $draws,
            ];
        }
        
        // Sắp xếp: điểm > hiệu số > bàn thắng
        usort($standings, function($a, $b) {
            if ($b['points'] != $a['points']) return $b['points'] - $a['points'];
            if ($b['gd'] != $a['gd']) return $b['gd'] - $a['gd'];
            return $b['gf'] - $a['gf'];
        });
        
        return $standings;
    }

    private function createPlayersForTeam(Team $team): void
    {
        // Xóa players cũ nếu có
        Player::where('team_id', $team->id)->delete();
        
        $positions = [
            'goalkeeper' => 2,
            'defender' => 5, 
            'midfielder' => 6,
            'forward' => 5,
        ];
        
        $firstNames = ['Minh', 'Hoàng', 'Văn', 'Đức', 'Quang', 'Tuấn', 'Hùng', 'Thành', 'Công', 'Tiến', 
                       'Phúc', 'Hải', 'Long', 'Nam', 'Bình', 'Khoa', 'Dũng', 'Tùng'];
        $lastNames = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 
                      'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý'];

        $jerseyNumber = 1;
        foreach ($positions as $position => $count) {
            for ($i = 0; $i < $count; $i++) {
                $firstName = $firstNames[array_rand($firstNames)];
                $lastName = $lastNames[array_rand($lastNames)];

                Player::create([
                    'team_id' => $team->id,
                    'jersey_number' => $jerseyNumber,
                    'name' => "$lastName $firstName",
                    'position' => $position,
                    'nationality' => 'Vietnam',
                    'birth_date' => Carbon::now()->subYears(rand(20, 32))->subDays(rand(1, 365)),
                    'height' => rand(168, 188),
                    'weight' => rand(62, 82),
                ]);
                
                $jerseyNumber++;
                if ($jerseyNumber == 13) $jerseyNumber = 14; // Skip số 13
            }
        }
    }

    private function generateRealisticScore(): array
    {
        // Phân phối tỷ số thực tế hơn
        $scores = [
            ['home' => 0, 'away' => 0, 'weight' => 8],
            ['home' => 1, 'away' => 0, 'weight' => 12],
            ['home' => 0, 'away' => 1, 'weight' => 10],
            ['home' => 1, 'away' => 1, 'weight' => 15],
            ['home' => 2, 'away' => 0, 'weight' => 8],
            ['home' => 0, 'away' => 2, 'weight' => 6],
            ['home' => 2, 'away' => 1, 'weight' => 12],
            ['home' => 1, 'away' => 2, 'weight' => 10],
            ['home' => 2, 'away' => 2, 'weight' => 6],
            ['home' => 3, 'away' => 0, 'weight' => 4],
            ['home' => 0, 'away' => 3, 'weight' => 2],
            ['home' => 3, 'away' => 1, 'weight' => 5],
            ['home' => 1, 'away' => 3, 'weight' => 3],
            ['home' => 3, 'away' => 2, 'weight' => 4],
            ['home' => 2, 'away' => 3, 'weight' => 3],
            ['home' => 4, 'away' => 0, 'weight' => 1],
            ['home' => 4, 'away' => 1, 'weight' => 2],
            ['home' => 4, 'away' => 2, 'weight' => 1],
        ];
        
        $totalWeight = array_sum(array_column($scores, 'weight'));
        $rand = rand(1, $totalWeight);
        
        $cumulative = 0;
        foreach ($scores as $score) {
            $cumulative += $score['weight'];
            if ($rand <= $cumulative) {
                return ['home' => $score['home'], 'away' => $score['away']];
            }
        }
        
        return ['home' => 1, 'away' => 1]; // Default
    }

    private function createMatchEvents(FootballMatch $match, int $homeScore, int $awayScore): void
    {
        MatchEvent::where('match_id', $match->id)->delete();

        $homePlayers = Player::where('team_id', $match->home_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();
        $awayPlayers = Player::where('team_id', $match->away_team_id)
            ->where('position', '!=', 'goalkeeper')
            ->get();

        if ($homePlayers->isEmpty() || $awayPlayers->isEmpty()) {
            return;
        }

        $usedMinutes = [];

        // Goals for home team
        for ($i = 0; $i < $homeScore; $i++) {
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

        // Goals for away team
        for ($i = 0; $i < $awayScore; $i++) {
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

        // Yellow cards (0-5)
        $yellowCards = rand(0, 5);
        $allPlayers = $homePlayers->merge($awayPlayers);
        
        for ($i = 0; $i < $yellowCards; $i++) {
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

        // Red card (rare - 5% chance)
        if (rand(1, 100) <= 5) {
            $minute = $this->getUniqueMinute($usedMinutes);
            MatchEvent::create([
                'match_id' => $match->id,
                'player_id' => $allPlayers->random()->id,
                'type' => 'red_card',
                'minute' => $minute,
                'description' => 'Thẻ đỏ',
            ]);
        }
    }

    private function getUniqueMinute(array $usedMinutes): int
    {
        do {
            $minute = rand(1, 90);
        } while (in_array($minute, $usedMinutes));
        return $minute;
    }

    private function createMatchStatistics(FootballMatch $match): void
    {
        MatchStatistic::where('match_id', $match->id)->delete();

        $homePossession = rand(38, 62);

        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'home',
            'possession' => $homePossession,
            'shots' => rand(8, 20),
            'shots_on_target' => rand(2, 10),
            'passes' => rand(350, 600),
            'pass_accuracy' => rand(72, 92),
            'fouls' => rand(8, 16),
            'yellow_cards' => rand(0, 4),
            'red_cards' => rand(0, 100) > 95 ? 1 : 0,
            'offsides' => rand(0, 5),
            'corners' => rand(3, 10),
        ]);

        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'away',
            'possession' => 100 - $homePossession,
            'shots' => rand(6, 18),
            'shots_on_target' => rand(1, 8),
            'passes' => rand(300, 550),
            'pass_accuracy' => rand(70, 90),
            'fouls' => rand(8, 16),
            'yellow_cards' => rand(0, 4),
            'red_cards' => rand(0, 100) > 95 ? 1 : 0,
            'offsides' => rand(0, 5),
            'corners' => rand(2, 8),
        ]);
    }
}
