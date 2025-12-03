<?php

namespace Database\Seeders;

use App\Models\Competition;
use App\Models\Season;
use App\Models\Round;
use App\Models\Team;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class SeasonSeeder extends Seeder
{
    public function run(): void
    {
        // Premier League 2025-26
        $premierLeague = Competition::where('short_name', 'EPL')->first();
        if ($premierLeague) {
            $eplSeason = Season::create([
                'competition_id' => $premierLeague->id,
                'name' => '2025-26',
                'start_date' => '2025-08-09',
                'end_date' => '2026-05-24',
                'is_current' => true,
            ]);

            // Create 38 rounds for Premier League
            for ($i = 1; $i <= 38; $i++) {
                Round::create([
                    'season_id' => $eplSeason->id,
                    'name' => "Matchweek $i",
                    'round_number' => $i,
                    'start_date' => Carbon::parse('2025-08-09')->addWeeks($i - 1),
                    'end_date' => Carbon::parse('2025-08-09')->addWeeks($i - 1)->addDays(2),
                ]);
            }
        }

        // V.League 2025-2026 (Shifted to align with demo date Dec 2025)
        $vleague = Competition::where('short_name', 'VL1')->first();
        if ($vleague) {
            $vleagueSeason = Season::create([
                'competition_id' => $vleague->id,
                'name' => '2025-2026',
                'start_date' => '2025-09-15',
                'end_date' => '2026-06-15',
                'is_current' => true,
            ]);

            // Create 26 rounds for V.League
            for ($i = 1; $i <= 26; $i++) {
                Round::create([
                    'season_id' => $vleagueSeason->id,
                    'name' => "Vòng $i",
                    'round_number' => $i,
                    'start_date' => Carbon::parse('2025-09-15')->addWeeks($i - 1),
                    'end_date' => Carbon::parse('2025-09-15')->addWeeks($i - 1)->addDays(2),
                ]);
            }
        }
    }
}
