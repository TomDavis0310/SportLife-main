<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('match_events', 'team_side')) {
            Schema::table('match_events', function (Blueprint $table) {
                $table->enum('team_side', ['home', 'away'])->nullable()->after('type');
            });
        }

        if (! Schema::hasColumn('match_events', 'team_id')) {
            Schema::table('match_events', function (Blueprint $table) {
                $table->foreignId('team_id')->nullable()->after('team_side')->constrained('teams')->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('match_events', 'team_id')) {
            Schema::table('match_events', function (Blueprint $table) {
                $table->dropForeign(['team_id']);
                $table->dropColumn('team_id');
            });
        }

        if (Schema::hasColumn('match_events', 'team_side')) {
            Schema::table('match_events', function (Blueprint $table) {
                $table->dropColumn('team_side');
            });
        }
    }
};
