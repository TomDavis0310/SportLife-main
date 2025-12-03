<?php

namespace Database\Seeders;

use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Seeder;

class AssignManagerSeeder extends Seeder
{
    public function run(): void
    {
        $manager = User::where('email', 'manager@hagl.vn')->first();
        $team = Team::where('short_name', 'HAGL')->first();

        if ($manager && $team) {
            $team->manager_user_id = $manager->id;
            $team->save();
            $this->command->info("Assigned manager {$manager->email} to team {$team->name}");
        } else {
            $this->command->error("Manager or Team not found");
        }
    }
}
