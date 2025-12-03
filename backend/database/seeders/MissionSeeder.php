<?php

namespace Database\Seeders;

use App\Models\DailyMission;
use Illuminate\Database\Seeder;

class MissionSeeder extends Seeder
{
    public function run(): void
    {
        $missions = [
            [
                'name' => 'Daily Check-in',
                'description' => 'Log in to the app today',
                'type' => 'login_streak',
                'target_value' => 1,
                'points_reward' => 10,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Make a Prediction',
                'description' => 'Make 1 match prediction',
                'type' => 'make_predictions',
                'target_value' => 1,
                'points_reward' => 15,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Prediction Streak',
                'description' => 'Make 3 match predictions',
                'type' => 'make_predictions',
                'target_value' => 3,
                'points_reward' => 30,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Social Engagement',
                'description' => 'Comment on a news article',
                'type' => 'comment',
                'target_value' => 1,
                'points_reward' => 15,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Campaign Viewer',
                'description' => 'View a sponsor campaign',
                'type' => 'view_ads',
                'target_value' => 1,
                'points_reward' => 5,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Share the Love',
                'description' => 'Like 3 news articles',
                'type' => 'like',
                'target_value' => 3,
                'points_reward' => 10,
                'is_weekly' => false,
                'is_active' => true,
            ],
            [
                'name' => 'Weekly Predictor',
                'description' => 'Make 10 predictions this week',
                'type' => 'make_predictions',
                'target_value' => 10,
                'points_reward' => 100,
                'is_weekly' => true,
                'is_active' => true,
            ],
            [
                'name' => 'Weekly Social',
                'description' => 'Invite a friend this week',
                'type' => 'invite_friends',
                'target_value' => 1,
                'points_reward' => 50,
                'is_weekly' => true,
                'is_active' => true,
            ],
        ];

        foreach ($missions as $mission) {
            DailyMission::create($mission);
        }
    }
}
