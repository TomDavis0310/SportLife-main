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
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('round_id')->constrained('rounds')->cascadeOnDelete();
            $table->foreignId('home_team_id')->constrained('teams');
            $table->foreignId('away_team_id')->constrained('teams');
            $table->unsignedTinyInteger('home_score')->nullable();
            $table->unsignedTinyInteger('away_score')->nullable();
            $table->unsignedTinyInteger('home_score_ht')->nullable();
            $table->unsignedTinyInteger('away_score_ht')->nullable();
            $table->string('status', 32)->default('scheduled');
            $table->unsignedTinyInteger('minute')->nullable();
            $table->dateTime('match_date');
            $table->string('venue')->nullable();
            $table->dateTime('prediction_locked_at')->nullable();
            $table->foreignId('first_scorer_id')->nullable()->constrained('players')->nullOnDelete();
            $table->timestamps();

            $table->index(['match_date', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};
