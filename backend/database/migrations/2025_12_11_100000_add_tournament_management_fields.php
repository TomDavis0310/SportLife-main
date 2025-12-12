<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add max_teams and registration_locked to seasons table
        Schema::table('seasons', function (Blueprint $table) {
            $table->unsignedInteger('max_teams')->default(20)->after('end_date');
            $table->boolean('registration_locked')->default(false)->after('max_teams');
            $table->foreignId('sponsor_user_id')->nullable()->after('registration_locked')
                ->constrained('users')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('seasons', function (Blueprint $table) {
            $table->dropForeign(['sponsor_user_id']);
            $table->dropColumn(['max_teams', 'registration_locked', 'sponsor_user_id']);
        });
    }
};
