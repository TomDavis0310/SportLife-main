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

class StudentWinterCupSeeder extends Seeder
{
    public function run(): void
    {
        // Get sponsor user
        $sponsor = User::where('email', 'sponsor@nike.com')->first();
        if (!$sponsor) {
            $this->command->info('Sponsor user not found. Please run UserSeeder first.');
            return;
        }

        // 1. Create Competition
        $competition = Competition::updateOrCreate(
            ['short_name' => 'SVMD'],
            [
                'name' => 'Sinh Viên Mùa Đông',
                'type' => 'league',
                'country' => 'Vietnam',
                'logo' => 'competitions/sinh-vien-mua-dong.png',
                'description' => 'Giải bóng đá Sinh Viên Mùa Đông - Sân chơi dành cho các đội bóng sinh viên trên toàn quốc',
                'is_active' => true,
            ]
        );

        $this->command->info('Created competition: Sinh Viên Mùa Đông');

        // 2. Create 8 Student Teams
        $studentTeams = [
            [
                'name' => 'ĐH Bách Khoa HN',
                'short_name' => 'BKHN',
                'country' => 'Vietnam',
                'city' => 'Hà Nội',
                'stadium' => 'Sân ĐH Bách Khoa',
                'founded_year' => 2010,
                'primary_color' => '#003366',
                'secondary_color' => '#FFFFFF',
            ],
            [
                'name' => 'ĐH Kinh Tế Quốc Dân',
                'short_name' => 'NEU',
                'country' => 'Vietnam',
                'city' => 'Hà Nội',
                'stadium' => 'Sân ĐH Kinh Tế',
                'founded_year' => 2008,
                'primary_color' => '#8B0000',
                'secondary_color' => '#FFD700',
            ],
            [
                'name' => 'ĐH FPT Hà Nội',
                'short_name' => 'FPT',
                'country' => 'Vietnam',
                'city' => 'Hà Nội',
                'stadium' => 'Sân ĐH FPT',
                'founded_year' => 2012,
                'primary_color' => '#FF6600',
                'secondary_color' => '#FFFFFF',
            ],
            [
                'name' => 'ĐH Ngoại Thương',
                'short_name' => 'FTU',
                'country' => 'Vietnam',
                'city' => 'Hà Nội',
                'stadium' => 'Sân ĐH Ngoại Thương',
                'founded_year' => 2009,
                'primary_color' => '#006400',
                'secondary_color' => '#FFFFFF',
            ],
            [
                'name' => 'ĐH Công Nghệ TPHCM',
                'short_name' => 'HUT',
                'country' => 'Vietnam',
                'city' => 'TP.HCM',
                'stadium' => 'Sân HUTECH',
                'founded_year' => 2011,
                'primary_color' => '#1E90FF',
                'secondary_color' => '#FFFFFF',
            ],
            [
                'name' => 'ĐH Tôn Đức Thắng',
                'short_name' => 'TDT',
                'country' => 'Vietnam',
                'city' => 'TP.HCM',
                'stadium' => 'Sân Tôn Đức Thắng',
                'founded_year' => 2010,
                'primary_color' => '#800080',
                'secondary_color' => '#FFFFFF',
            ],
            [
                'name' => 'ĐH Đà Nẵng',
                'short_name' => 'UDN',
                'country' => 'Vietnam',
                'city' => 'Đà Nẵng',
                'stadium' => 'Sân ĐH Đà Nẵng',
                'founded_year' => 2013,
                'primary_color' => '#FFD700',
                'secondary_color' => '#000080',
            ],
            [
                'name' => 'ĐH Cần Thơ',
                'short_name' => 'CTU',
                'country' => 'Vietnam',
                'city' => 'Cần Thơ',
                'stadium' => 'Sân ĐH Cần Thơ',
                'founded_year' => 2014,
                'primary_color' => '#228B22',
                'secondary_color' => '#FFFFFF',
            ],
        ];

        $teams = [];
        foreach ($studentTeams as $teamData) {
            $teamData['logo'] = 'teams/' . Str::slug($teamData['name']) . '.png';
            $team = Team::updateOrCreate(
                ['short_name' => $teamData['short_name']],
                $teamData
            );
            $teams[] = $team;
            
            // Create players for each team
            $this->createPlayersForTeam($team);
        }

        $this->command->info('Created 8 student teams with players');

        // 3. Create Season
        $season = Season::updateOrCreate(
            [
                'competition_id' => $competition->id,
                'name' => '2025',
            ],
            [
                'start_date' => '2025-11-01',
                'end_date' => '2025-12-31',
                'is_current' => true,
                'sponsor_user_id' => $sponsor->id,
                'registration_locked' => true,
                'max_teams' => 8,
            ]
        );

        $this->command->info('Created season 2025');

        // 4. Register all teams to season (approved)
        foreach ($teams as $team) {
            $season->teams()->syncWithoutDetaching([
                $team->id => ['status' => 'approved', 'created_at' => now(), 'updated_at' => now()]
            ]);
        }

        $this->command->info('Registered all teams to season');

        // 5. Create Rounds (Round Robin - mỗi đội đấu với mỗi đội 1 lần = 7 vòng)
        $rounds = [];
        $roundStartDate = Carbon::parse('2025-11-01');
        
        for ($i = 1; $i <= 7; $i++) {
            $round = Round::updateOrCreate(
                [
                    'season_id' => $season->id,
                    'round_number' => $i,
                ],
                [
                    'name' => "Vòng $i",
                    'start_date' => $roundStartDate->copy(),
                    'end_date' => $roundStartDate->copy()->addDays(2),
                ]
            );
            $rounds[] = $round;
            $roundStartDate->addWeeks(1);
        }

        $this->command->info('Created 7 rounds');

        // 6. Generate Round Robin Schedule & Create Matches with Results
        $teamIds = collect($teams)->pluck('id')->toArray();
        $schedule = $this->generateRoundRobinSchedule($teamIds);

        $matchResults = $this->generateMatchResults();
        $matchIndex = 0;

        foreach ($rounds as $roundIndex => $round) {
            $matchDate = Carbon::parse($round->start_date)->addHours(15);
            
            // 4 matches per round
            $roundMatches = $schedule[$roundIndex] ?? [];
            
            foreach ($roundMatches as $pair) {
                if ($matchIndex >= count($matchResults)) break;
                
                $result = $matchResults[$matchIndex];
                $homeTeamId = $pair[0];
                $awayTeamId = $pair[1];

                $match = FootballMatch::updateOrCreate(
                    [
                        'round_id' => $round->id,
                        'home_team_id' => $homeTeamId,
                        'away_team_id' => $awayTeamId,
                    ],
                    [
                        'match_date' => $matchDate->copy(),
                        'venue' => Team::find($homeTeamId)->stadium,
                        'status' => MatchStatus::FINISHED,
                        'home_score' => $result['home'],
                        'away_score' => $result['away'],
                    ]
                );

                // Create match events (goals)
                $this->createMatchEvents($match, $result);
                
                // Create match statistics
                $this->createMatchStatistics($match);

                $matchDate->addHours(3);
                $matchIndex++;
            }
        }

        $this->command->info('Created all matches with results, events and statistics');

        // 7. Summary
        $this->command->info('');
        $this->command->info('=== Giải đấu Sinh Viên Mùa Đông đã được tạo ===');
        $this->command->info("Competition: {$competition->name}");
        $this->command->info("Season: {$season->name}");
        $this->command->info("Teams: " . count($teams));
        $this->command->info("Rounds: " . count($rounds));
        $this->command->info("Matches: $matchIndex");
    }

    private function createPlayersForTeam(Team $team): void
    {
        $positions = ['goalkeeper', 'defender', 'defender', 'defender', 'defender', 'midfielder', 'midfielder', 'midfielder', 'midfielder', 'forward', 'forward'];
        $firstNames = ['Minh', 'Hoàng', 'Văn', 'Đức', 'Quang', 'Tuấn', 'Hùng', 'Thành', 'Công', 'Tiến', 'Phúc'];
        $lastNames = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi'];

        for ($i = 0; $i < 11; $i++) {
            $firstName = $firstNames[array_rand($firstNames)];
            $lastName = $lastNames[array_rand($lastNames)];
            $jerseyNumber = $i == 0 ? 1 : rand(2, 99);

            Player::updateOrCreate(
                [
                    'team_id' => $team->id,
                    'jersey_number' => $jerseyNumber,
                ],
                [
                    'name' => "$lastName $firstName",
                    'position' => $positions[$i],
                    'nationality' => 'Vietnam',
                    'birth_date' => Carbon::now()->subYears(rand(19, 23))->subDays(rand(1, 365)),
                    'height' => rand(165, 185),
                    'weight' => rand(60, 80),
                ]
            );
        }
    }

    private function generateRoundRobinSchedule(array $teamIds): array
    {
        $n = count($teamIds);
        $schedule = [];
        
        // Round Robin algorithm
        $teams = $teamIds;
        
        for ($round = 0; $round < $n - 1; $round++) {
            $roundMatches = [];
            for ($match = 0; $match < $n / 2; $match++) {
                $home = $teams[$match];
                $away = $teams[$n - 1 - $match];
                $roundMatches[] = [$home, $away];
            }
            $schedule[] = $roundMatches;
            
            // Rotate teams (keep first team fixed)
            $last = array_pop($teams);
            array_splice($teams, 1, 0, [$last]);
        }
        
        return $schedule;
    }

    private function generateMatchResults(): array
    {
        // Predefined exciting match results for 28 matches (7 rounds x 4 matches)
        return [
            // Vòng 1
            ['home' => 3, 'away' => 1],
            ['home' => 2, 'away' => 2],
            ['home' => 1, 'away' => 0],
            ['home' => 4, 'away' => 2],
            // Vòng 2
            ['home' => 2, 'away' => 1],
            ['home' => 0, 'away' => 0],
            ['home' => 3, 'away' => 3],
            ['home' => 1, 'away' => 2],
            // Vòng 3
            ['home' => 2, 'away' => 0],
            ['home' => 1, 'away' => 1],
            ['home' => 4, 'away' => 1],
            ['home' => 0, 'away' => 3],
            // Vòng 4
            ['home' => 3, 'away' => 2],
            ['home' => 2, 'away' => 1],
            ['home' => 1, 'away' => 4],
            ['home' => 2, 'away' => 2],
            // Vòng 5
            ['home' => 0, 'away' => 1],
            ['home' => 3, 'away' => 0],
            ['home' => 2, 'away' => 3],
            ['home' => 1, 'away' => 1],
            // Vòng 6
            ['home' => 4, 'away' => 0],
            ['home' => 2, 'away' => 2],
            ['home' => 1, 'away' => 3],
            ['home' => 3, 'away' => 1],
            // Vòng 7
            ['home' => 2, 'away' => 1],
            ['home' => 1, 'away' => 2],
            ['home' => 3, 'away' => 3],
            ['home' => 0, 'away' => 2],
        ];
    }

    private function createMatchEvents(FootballMatch $match, array $result): void
    {
        // Clear old events
        MatchEvent::where('match_id', $match->id)->delete();

        $homePlayers = Player::where('team_id', $match->home_team_id)->get();
        $awayPlayers = Player::where('team_id', $match->away_team_id)->get();

        if ($homePlayers->isEmpty() || $awayPlayers->isEmpty()) {
            return;
        }

        // Create goal events for home team
        for ($i = 0; $i < $result['home']; $i++) {
            $scorers = $homePlayers->where('position', '!=', 'goalkeeper');
            if ($scorers->isEmpty()) continue;
            $scorer = $scorers->random();
            
            MatchEvent::create([
                'match_id' => $match->id,
                'player_id' => $scorer->id,
                'type' => 'goal',
                'minute' => rand(1, 90),
                'description' => "Bàn thắng của {$scorer->name}",
            ]);
        }

        // Create goal events for away team
        for ($i = 0; $i < $result['away']; $i++) {
            $scorers = $awayPlayers->where('position', '!=', 'goalkeeper');
            if ($scorers->isEmpty()) continue;
            $scorer = $scorers->random();
            
            MatchEvent::create([
                'match_id' => $match->id,
                'player_id' => $scorer->id,
                'type' => 'goal',
                'minute' => rand(1, 90),
                'description' => "Bàn thắng của {$scorer->name}",
            ]);
        }

        // Add some yellow cards
        $yellowCards = rand(0, 4);
        for ($i = 0; $i < $yellowCards; $i++) {
            $isHome = rand(0, 1);
            $players = $isHome ? $homePlayers : $awayPlayers;
            if ($players->isEmpty()) continue;
            $player = $players->random();

            MatchEvent::create([
                'match_id' => $match->id,
                'player_id' => $player->id,
                'type' => 'yellow_card',
                'minute' => rand(1, 90),
                'description' => "Thẻ vàng cho {$player->name}",
            ]);
        }
    }

    private function createMatchStatistics(FootballMatch $match): void
    {
        // Clear old statistics
        MatchStatistic::where('match_id', $match->id)->delete();

        // Home team statistics
        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'home',
            'possession' => rand(40, 60),
            'shots' => rand(8, 18),
            'shots_on_target' => rand(3, 8),
            'corners' => rand(2, 8),
            'fouls' => rand(8, 16),
            'offsides' => rand(0, 5),
            'passes' => rand(300, 500),
            'pass_accuracy' => rand(75, 90),
            'yellow_cards' => rand(0, 3),
            'red_cards' => rand(0, 1) > 0.9 ? 1 : 0,
        ]);

        // Away team statistics  
        MatchStatistic::create([
            'match_id' => $match->id,
            'side' => 'away',
            'possession' => rand(40, 60),
            'shots' => rand(6, 16),
            'shots_on_target' => rand(2, 7),
            'corners' => rand(2, 7),
            'fouls' => rand(8, 16),
            'offsides' => rand(0, 5),
            'passes' => rand(280, 480),
            'pass_accuracy' => rand(72, 88),
            'yellow_cards' => rand(0, 3),
            'red_cards' => rand(0, 1) > 0.9 ? 1 : 0,
        ]);
    }
}
