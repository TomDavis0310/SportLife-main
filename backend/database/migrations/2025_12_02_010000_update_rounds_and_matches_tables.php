<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('matches', 'home_score_ht')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->unsignedTinyInteger('home_score_ht')->nullable()->after('away_score');
            });
        }

        if (! Schema::hasColumn('matches', 'away_score_ht')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->unsignedTinyInteger('away_score_ht')->nullable()->after('home_score_ht');
            });
        }

        if (! Schema::hasColumn('matches', 'minute')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->unsignedTinyInteger('minute')->nullable()->after('status');
            });
        }

        if (Schema::hasColumn('matches', 'current_minute') && Schema::hasColumn('matches', 'minute')) {
            DB::statement('UPDATE matches SET minute = current_minute WHERE minute IS NULL AND current_minute IS NOT NULL');

            Schema::table('matches', function (Blueprint $table) {
                $table->dropColumn('current_minute');
            });
        }

        if (! Schema::hasColumn('rounds', 'round_number')) {
            Schema::table('rounds', function (Blueprint $table) {
                $table->unsignedSmallInteger('round_number')->after('name');
            });

            if (Schema::hasColumn('rounds', 'number')) {
                DB::statement('UPDATE rounds SET round_number = `number`');

                Schema::table('rounds', function (Blueprint $table) {
                    $table->dropColumn('number');
                });
            }
        }
    }

    public function down(): void
    {
        if (! Schema::hasColumn('matches', 'current_minute')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->unsignedTinyInteger('current_minute')->nullable()->after('status');
            });
        }

        if (Schema::hasColumn('matches', 'minute') && Schema::hasColumn('matches', 'current_minute')) {
            DB::statement('UPDATE matches SET current_minute = minute WHERE minute IS NOT NULL');

            Schema::table('matches', function (Blueprint $table) {
                $table->dropColumn('minute');
            });
        }

        if (Schema::hasColumn('matches', 'home_score_ht')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->dropColumn('home_score_ht');
            });
        }

        if (Schema::hasColumn('matches', 'away_score_ht')) {
            Schema::table('matches', function (Blueprint $table) {
                $table->dropColumn('away_score_ht');
            });
        }

        if (! Schema::hasColumn('rounds', 'number')) {
            Schema::table('rounds', function (Blueprint $table) {
                $table->unsignedSmallInteger('number')->after('name');
            });
        }

        if (Schema::hasColumn('rounds', 'round_number') && Schema::hasColumn('rounds', 'number')) {
            DB::statement('UPDATE rounds SET `number` = round_number');

            Schema::table('rounds', function (Blueprint $table) {
                $table->dropColumn('round_number');
            });
        }
    }
};
