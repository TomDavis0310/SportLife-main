<?php

namespace Database\Seeders;

use App\Models\Badge;
use Illuminate\Database\Seeder;

class BadgeSeeder extends Seeder
{
    public function run(): void
    {
        $badges = [
            // Prediction badges
            [
                'name' => 'First Prediction',
                'description' => 'Made your first prediction',
                'icon' => 'badges/first-prediction.png',
                'type' => 'prediction',
                'requirement_type' => 'predictions_count',
                'requirement_value' => 1,
                'points_reward' => 10,
            ],
            [
                'name' => 'Prediction Novice',
                'description' => 'Made 10 predictions',
                'icon' => 'badges/prediction-novice.png',
                'type' => 'prediction',
                'requirement_type' => 'predictions_count',
                'requirement_value' => 10,
                'points_reward' => 50,
            ],
            [
                'name' => 'Prediction Pro',
                'description' => 'Made 50 predictions',
                'icon' => 'badges/prediction-pro.png',
                'type' => 'prediction',
                'requirement_type' => 'predictions_count',
                'requirement_value' => 50,
                'points_reward' => 200,
            ],
            [
                'name' => 'Prediction Master',
                'description' => 'Made 100 predictions',
                'icon' => 'badges/prediction-master.png',
                'type' => 'prediction',
                'requirement_type' => 'predictions_count',
                'requirement_value' => 100,
                'points_reward' => 500,
            ],

            // Accuracy badges
            [
                'name' => 'Lucky Guess',
                'description' => 'Got your first correct prediction',
                'icon' => 'badges/lucky-guess.png',
                'type' => 'achievement',
                'requirement_type' => 'correct_predictions',
                'requirement_value' => 1,
                'points_reward' => 20,
            ],
            [
                'name' => 'Sharp Eye',
                'description' => 'Got 10 correct predictions',
                'icon' => 'badges/sharp-eye.png',
                'type' => 'achievement',
                'requirement_type' => 'correct_predictions',
                'requirement_value' => 10,
                'points_reward' => 100,
            ],
            [
                'name' => 'Psychic',
                'description' => 'Got 5 perfect score predictions',
                'icon' => 'badges/psychic.png',
                'type' => 'achievement',
                'requirement_type' => 'perfect_predictions',
                'requirement_value' => 5,
                'points_reward' => 250,
            ],
            [
                'name' => 'Oracle',
                'description' => 'Got 20 perfect score predictions',
                'icon' => 'badges/oracle.png',
                'type' => 'achievement',
                'requirement_type' => 'perfect_predictions',
                'requirement_value' => 20,
                'points_reward' => 1000,
            ],

            // Points badges
            [
                'name' => 'Point Collector',
                'description' => 'Earned 1,000 SportPoints',
                'icon' => 'badges/point-collector.png',
                'type' => 'achievement',
                'requirement_type' => 'total_points',
                'requirement_value' => 1000,
                'points_reward' => 50,
            ],
            [
                'name' => 'Point Hunter',
                'description' => 'Earned 5,000 SportPoints',
                'icon' => 'badges/point-hunter.png',
                'type' => 'achievement',
                'requirement_type' => 'total_points',
                'requirement_value' => 5000,
                'points_reward' => 200,
            ],
            [
                'name' => 'Point King',
                'description' => 'Earned 20,000 SportPoints',
                'icon' => 'badges/point-king.png',
                'type' => 'achievement',
                'requirement_type' => 'total_points',
                'requirement_value' => 20000,
                'points_reward' => 1000,
            ],

            // Social badges
            [
                'name' => 'Social Butterfly',
                'description' => 'Made 5 friends',
                'icon' => 'badges/social-butterfly.png',
                'type' => 'social',
                'requirement_type' => 'friends_count',
                'requirement_value' => 5,
                'points_reward' => 50,
            ],
            [
                'name' => 'Influencer',
                'description' => 'Referred 3 friends',
                'icon' => 'badges/influencer.png',
                'type' => 'social',
                'requirement_type' => 'referrals',
                'requirement_value' => 3,
                'points_reward' => 150,
            ],

            // Loyalty badges
            [
                'name' => 'Dedicated Fan',
                'description' => 'Logged in 7 days in a row',
                'icon' => 'badges/dedicated-fan.png',
                'type' => 'loyalty',
                'requirement_type' => 'login_streak',
                'requirement_value' => 7,
                'points_reward' => 30,
            ],
            [
                'name' => 'Super Fan',
                'description' => 'Logged in 30 days in a row',
                'icon' => 'badges/super-fan.png',
                'type' => 'loyalty',
                'requirement_type' => 'login_streak',
                'requirement_value' => 30,
                'points_reward' => 150,
            ],
        ];

        foreach ($badges as $badge) {
            Badge::create($badge);
        }
    }
}
