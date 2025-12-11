<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin user
        $admin = User::updateOrCreate([
            'email' => 'admin@sportlife.vn',
        ], [
            'name' => 'Admin SportLife',
            'password' => Hash::make('password123'),
            'sport_points' => 10000,
            'email_verified_at' => now(),
            'referral_code' => strtoupper(substr(md5('admin'), 0, 8)),
        ]);
        $admin->assignRole('admin');

        // Club Manager
        $clubManager = User::updateOrCreate([
            'email' => 'manager@hagl.vn',
        ], [
            'name' => 'HAGL Manager',
            'password' => Hash::make('password123'),
            'sport_points' => 5000,
            'email_verified_at' => now(),
            'referral_code' => strtoupper(substr(md5('hagl_manager'), 0, 8)),
        ]);
        $clubManager->assignRole('club_manager');

        // Sponsor user
        $sponsor = User::updateOrCreate([
            'email' => 'sponsor@nike.com',
        ], [
            'name' => 'Nike Sponsor',
            'password' => Hash::make('password123'),
            'sport_points' => 0,
            'email_verified_at' => now(),
            'referral_code' => strtoupper(substr(md5('nike_sponsor'), 0, 8)),
        ]);
        $sponsor->assignRole('sponsor');

        // Journalist user
        $journalist = User::updateOrCreate([
            'email' => 'journalist@sportlife.vn',
        ], [
            'name' => 'Nhà báo SportLife',
            'password' => Hash::make('password123'),
            'sport_points' => 500,
            'email_verified_at' => now(),
            'referral_code' => strtoupper(substr(md5('journalist'), 0, 8)),
        ]);
        $journalist->assignRole('journalist');

        // Sample regular users
        $users = [
            ['name' => 'Nguyen Van A', 'email' => 'vana@gmail.com', 'sport_points' => 1500],
            ['name' => 'Tran Thi B', 'email' => 'thib@gmail.com', 'sport_points' => 2300],
            ['name' => 'Le Van C', 'email' => 'vanc@gmail.com', 'sport_points' => 800],
            ['name' => 'Pham Thi D', 'email' => 'thid@gmail.com', 'sport_points' => 5200],
            ['name' => 'Hoang Van E', 'email' => 'vane@gmail.com', 'sport_points' => 3100],
            ['name' => 'Vo Thi F', 'email' => 'thif@gmail.com', 'sport_points' => 1200],
            ['name' => 'Dang Van G', 'email' => 'vang@gmail.com', 'sport_points' => 4500],
            ['name' => 'Bui Thi H', 'email' => 'thih@gmail.com', 'sport_points' => 950],
            ['name' => 'Do Van I', 'email' => 'vani@gmail.com', 'sport_points' => 2800],
            ['name' => 'Ngo Thi K', 'email' => 'thik@gmail.com', 'sport_points' => 6100],
        ];

        foreach ($users as $index => $userData) {
            $user = User::updateOrCreate([
                'email' => $userData['email'],
            ], [
                'name' => $userData['name'],
                'password' => Hash::make('password123'),
                'sport_points' => $userData['sport_points'],
                'email_verified_at' => now(),
                'referral_code' => strtoupper(substr(md5($userData['email']), 0, 8)),
            ]);
            $user->assignRole('user');
        }

        // Demo user for testing
        $demo = User::updateOrCreate([
            'email' => 'demo@sportlife.vn',
        ], [
            'name' => 'Demo User',
            'password' => Hash::make('demo123'),
            'sport_points' => 1000,
            'email_verified_at' => now(),
            'referral_code' => strtoupper(substr(md5('demo'), 0, 8)),
        ]);
        $demo->assignRole('user');
    }
}
