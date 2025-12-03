<?php

namespace Database\Seeders;

use App\Models\Competition;
use Illuminate\Database\Seeder;

class CompetitionSeeder extends Seeder
{
    public function run(): void
    {
        $competitions = [
            [
                'name' => 'Premier League',
                'short_name' => 'EPL',
                'country' => 'England',
                'type' => 'league',
                'logo' => 'competitions/premier-league.png',
                'is_active' => true,
            ],
            [
                'name' => 'V.League 1',
                'short_name' => 'VL1',
                'country' => 'Vietnam',
                'type' => 'league',
                'logo' => 'competitions/vleague.png',
                'is_active' => true,
            ],
            [
                'name' => 'UEFA Champions League',
                'short_name' => 'UCL',
                'country' => 'Europe',
                'type' => 'cup',
                'logo' => 'competitions/champions-league.png',
                'is_active' => true,
            ],
            [
                'name' => 'La Liga',
                'short_name' => 'LaLiga',
                'country' => 'Spain',
                'type' => 'league',
                'logo' => 'competitions/laliga.png',
                'is_active' => true,
            ],
            [
                'name' => 'Serie A',
                'short_name' => 'SerieA',
                'country' => 'Italy',
                'type' => 'league',
                'logo' => 'competitions/seriea.png',
                'is_active' => true,
            ],
        ];

        foreach ($competitions as $competition) {
            Competition::create($competition);
        }
    }
}
