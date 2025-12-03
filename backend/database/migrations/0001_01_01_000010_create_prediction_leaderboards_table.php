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
        Schema::create('prediction_leaderboards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('season_id')->nullable()->constrained('seasons')->cascadeOnDelete();
            $table->foreignId('round_id')->nullable()->constrained('rounds')->cascadeOnDelete();
            $table->unsignedBigInteger('total_points')->default(0);
            $table->unsignedInteger('total_predictions')->default(0);
            $table->unsignedInteger('correct_scores')->default(0);
            $table->unsignedInteger('correct_differences')->default(0);
            $table->unsignedInteger('correct_winners')->default(0);
            $table->unsignedInteger('rank')->default(0);
            $table->timestamps();

            $table->unique(['user_id', 'season_id', 'round_id']);
            $table->index(['season_id', 'total_points']);
            $table->index(['round_id', 'total_points']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('prediction_leaderboards');
    }
};
