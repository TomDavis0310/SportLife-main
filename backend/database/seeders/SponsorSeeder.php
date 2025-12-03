<?php

namespace Database\Seeders;

use App\Models\Sponsor;
use App\Models\SponsorCampaign;
use App\Models\User;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class SponsorSeeder extends Seeder
{
    public function run(): void
    {
        // Create sponsor users first
        $sponsorUsers = [
            [
                'name' => 'SportLife Premium',
                'email' => 'sponsor@sportlife.vn',
                'password' => bcrypt('password'),
            ],
            [
                'name' => 'Nike Vietnam',
                'email' => 'sponsor@nike.vn',
                'password' => bcrypt('password'),
            ],
            [
                'name' => 'Pepsi Vietnam',
                'email' => 'sponsor@pepsi.vn',
                'password' => bcrypt('password'),
            ],
        ];

        $sponsorData = [
            [
                'company_name' => 'SportLife Premium',
                'company_logo' => 'sponsors/sportlife.png',
                'contact_email' => 'sponsor@sportlife.vn',
                'balance' => 10000,
                'is_approved' => true,
                'campaigns' => [
                    [
                        'name' => 'Welcome Bonus',
                        'type' => 'prediction_bonus',
                        'banner_image' => 'campaigns/welcome-bonus.png',
                        'click_url' => 'https://sportlife.vn/welcome',
                        'start_date' => Carbon::now(),
                        'end_date' => Carbon::now()->addMonths(3),
                        'points_per_view' => 5,
                        'bonus_points_correct_prediction' => 10,
                        'budget' => 5000,
                        'is_active' => true,
                    ],
                ],
            ],
            [
                'company_name' => 'Nike Vietnam',
                'company_logo' => 'sponsors/nike.png',
                'contact_email' => 'sponsor@nike.vn',
                'balance' => 20000,
                'is_approved' => true,
                'campaigns' => [
                    [
                        'name' => 'Match Day Kit',
                        'type' => 'banner',
                        'banner_image' => 'campaigns/nike-matchday.png',
                        'click_url' => 'https://nike.com.vn/sportlife',
                        'start_date' => Carbon::now(),
                        'end_date' => Carbon::now()->addMonths(2),
                        'points_per_view' => 10,
                        'bonus_points_correct_prediction' => 0,
                        'budget' => 10000,
                        'is_active' => true,
                    ],
                ],
            ],
            [
                'company_name' => 'Pepsi Vietnam',
                'company_logo' => 'sponsors/pepsi.png',
                'contact_email' => 'sponsor@pepsi.vn',
                'balance' => 15000,
                'is_approved' => true,
                'campaigns' => [
                    [
                        'name' => 'Pepsi Football Fever',
                        'type' => 'video_ad',
                        'banner_image' => 'campaigns/pepsi-fever.png',
                        'video_url' => 'https://pepsi.vn/video/football.mp4',
                        'click_url' => 'https://pepsi.vn/football',
                        'start_date' => Carbon::now(),
                        'end_date' => Carbon::now()->addMonths(1),
                        'points_per_view' => 5,
                        'bonus_points_correct_prediction' => 0,
                        'budget' => 5000,
                        'is_active' => true,
                    ],
                ],
            ],
        ];

        foreach ($sponsorUsers as $index => $userData) {
            $user = User::updateOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => $userData['password'],
                ]
            );
            $sponsorRole = \Spatie\Permission\Models\Role::where('name', 'sponsor')->first();
            if ($sponsorRole) {
                $user->assignRole($sponsorRole);
            }
            
            $sponsorInfo = $sponsorData[$index];
            $campaigns = $sponsorInfo['campaigns'];
            unset($sponsorInfo['campaigns']);
            
            $sponsor = Sponsor::updateOrCreate(
                ['contact_email' => $sponsorInfo['contact_email']],
                array_merge($sponsorInfo, ['user_id' => $user->id])
            );

            foreach ($campaigns as $campaignData) {
                $campaignData['sponsor_id'] = $sponsor->id;
                SponsorCampaign::updateOrCreate(
                    [
                        'sponsor_id' => $sponsor->id,
                        'name' => $campaignData['name'],
                    ],
                    $campaignData
                );
            }
        }
    }
}
