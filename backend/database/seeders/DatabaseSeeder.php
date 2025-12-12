<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RolePermissionSeeder::class,
            UserSeeder::class,
            CompetitionSeeder::class,
            TeamSeeder::class,
            PlayerSeeder::class,
            SeasonSeeder::class,
            MatchSeeder::class,
            MatchStatisticSeeder::class,
            MatchEventSeeder::class,
            MatchHighlightSeeder::class,
            NewsSeeder::class,
            BadgeSeeder::class,
            MissionSeeder::class,
            SponsorSeeder::class,
            RewardSeeder::class,
            PredictionLeaderboardSeeder::class,
            StudentWinterCupSeeder::class, // Giải Sinh Viên Mùa Đông
        ]);
    }
}
