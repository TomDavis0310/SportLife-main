<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('matches')) {
            return;
        }

        DB::statement("ALTER TABLE matches MODIFY COLUMN status VARCHAR(32) NOT NULL DEFAULT 'scheduled'");
    }

    public function down(): void
    {
        if (! Schema::hasTable('matches')) {
            return;
        }

        DB::table('matches')
            ->whereIn('status', ['first_half', 'second_half', 'extra_time', 'penalties'])
            ->update(['status' => 'scheduled']);

        DB::statement("ALTER TABLE matches MODIFY COLUMN status ENUM('scheduled','live','halftime','finished','postponed','cancelled') NOT NULL DEFAULT 'scheduled'");
    }
};
