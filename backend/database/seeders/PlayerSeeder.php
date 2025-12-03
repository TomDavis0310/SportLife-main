<?php

namespace Database\Seeders;

use App\Models\Player;
use App\Models\FootballMatch;
use App\Enums\PlayerPosition;
use Illuminate\Database\Seeder;
use Faker\Factory as Faker;

class PlayerSeeder extends Seeder
{
    public function run(): void
    {
        $faker = Faker::create('vi_VN');
        
        // Get all teams
        $teamIds = \App\Models\Team::pluck('id')->toArray();
        
        $this->command->info("Creating players for " . count($teamIds) . " teams...");
        
        // Delete existing players  
        Player::query()->delete();
        
        $positions = [
            'goalkeeper', 
            'defender', 'defender', 'defender', 'defender',
            'midfielder', 'midfielder', 'midfielder',
            'forward', 'forward', 'forward'
        ];
        $vietnameseFirstNames = [
            'Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương'
        ];
        $vietnameseLastNames = [
            'Văn Quyết', 'Công Phượng', 'Quang Hải', 'Văn Toàn', 'Tiến Linh', 'Xuân Trường', 'Văn Hậu', 
            'Đức Chinh', 'Trọng Hoàng', 'Văn Lâm', 'Duy Mạnh', 'Bùi Tiến Dũng', 'Hùng Dũng', 'Tuấn Anh'
        ];
        
        // Create 15 players for each team (11 starting + 4 subs)
        foreach ($teamIds as $teamId) {
            for ($i = 0; $i < 15; $i++) {
                $firstName = $vietnameseFirstNames[array_rand($vietnameseFirstNames)];
                $lastName = $vietnameseLastNames[array_rand($vietnameseLastNames)];
                
                Player::create([
                    'name' => "{$firstName} {$lastName}",
                    'team_id' => $teamId,
                    'position' => $positions[$i % 11],
                    'jersey_number' => $i + 1,
                    'birth_date' => $faker->dateTimeBetween('-35 years', '-18 years'),
                    'nationality' => 'Vietnam',
                    'height' => rand(165, 190),
                    'weight' => rand(60, 85),
                    'is_active' => true,
                ]);
            }
        }
        
        $totalPlayers = Player::count();
        $this->command->info("Created {$totalPlayers} players for " . count($teamIds) . " teams");
    }
}
