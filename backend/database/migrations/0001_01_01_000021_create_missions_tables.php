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
        Schema::create('daily_missions', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('name_en')->nullable();
            $table->text('description')->nullable();
            $table->text('description_en')->nullable();
            $table->enum('type', ['make_predictions', 'login_streak', 'view_ads', 'invite_friends', 'comment', 'like']);
            $table->unsignedInteger('target_value')->default(1);
            $table->unsignedInteger('points_reward');
            $table->boolean('is_weekly')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('user_missions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('mission_id')->constrained('daily_missions')->cascadeOnDelete();
            $table->unsignedInteger('current_value')->default(0);
            $table->boolean('is_completed')->default(false);
            $table->dateTime('completed_at')->nullable();
            $table->date('period_start_date'); // For weekly missions
            $table->timestamps();

            $table->unique(['user_id', 'mission_id', 'period_start_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_missions');
        Schema::dropIfExists('daily_missions');
    }
};
