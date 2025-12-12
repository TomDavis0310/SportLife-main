<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // User management
            'users.view', 'users.create', 'users.update', 'users.delete',
            // Team management
            'teams.view', 'teams.create', 'teams.update', 'teams.delete',
            // Player management
            'players.view', 'players.create', 'players.update', 'players.delete',
            // Competition management
            'competitions.view', 'competitions.create', 'competitions.update', 'competitions.delete',
            // Match management
            'matches.view', 'matches.create', 'matches.update', 'matches.delete', 'matches.live_update',
            // News management
            'news.view', 'news.create', 'news.update', 'news.delete', 'news.publish',
            'news.manage_own', 'news.scrape', 'news.auto_fetch',
            // Reward management
            'rewards.view', 'rewards.create', 'rewards.update', 'rewards.delete',
            'redemptions.view', 'redemptions.process',
            // Sponsor management
            'sponsors.view', 'sponsors.create', 'sponsors.update', 'sponsors.delete',
            'campaigns.view', 'campaigns.create', 'campaigns.update', 'campaigns.delete',
            // Badge management
            'badges.view', 'badges.create', 'badges.update', 'badges.delete',
            // Mission management
            'missions.view', 'missions.create', 'missions.update', 'missions.delete',
            // Reports
            'reports.view', 'reports.export',
            // Settings
            'settings.view', 'settings.update',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(
                ['name' => $permission, 'guard_name' => 'web'],
                ['name' => $permission, 'guard_name' => 'web']
            );
        }

        $allPermissions = Permission::all();

        // Create roles and assign permissions
        $adminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);
        $adminRole->syncPermissions($allPermissions);

        $clubManagerRole = Role::firstOrCreate(['name' => 'club_manager', 'guard_name' => 'web']);
        $clubManagerRole->syncPermissions([
            'teams.view', 'teams.update',
            'players.view', 'players.create', 'players.update',
            'matches.view',
            'news.view', 'news.create', 'news.update',
        ]);

        $userRole = Role::firstOrCreate(['name' => 'user', 'guard_name' => 'web']);
        // Users have no special permissions, just basic app access

        $sponsorRole = Role::firstOrCreate(['name' => 'sponsor', 'guard_name' => 'web']);
        $sponsorRole->syncPermissions([
            'campaigns.view', 'campaigns.create', 'campaigns.update',
            'reports.view',
        ]);

        // Create Journalist role - for news management
        $journalistRole = Role::firstOrCreate(['name' => 'journalist', 'guard_name' => 'web']);
        $journalistRole->syncPermissions([
            'news.view', 'news.create', 'news.update', 'news.delete', 'news.publish',
            'news.manage_own', 'news.scrape', 'news.auto_fetch',
        ]);

        Role::firstOrCreate(['name' => 'guest', 'guard_name' => 'web']);
    }
}
