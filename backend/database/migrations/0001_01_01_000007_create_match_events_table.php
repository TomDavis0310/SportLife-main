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
        Schema::create('match_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('match_id')->constrained('matches')->cascadeOnDelete();
            $table->enum('type', ['goal', 'yellow_card', 'red_card', 'substitution', 'penalty', 'own_goal', 'penalty_miss', 'var']);
            $table->unsignedTinyInteger('minute');
            $table->unsignedTinyInteger('extra_minute')->nullable();
            $table->foreignId('player_id')->nullable()->constrained('players')->nullOnDelete();
            $table->foreignId('assist_player_id')->nullable()->constrained('players')->nullOnDelete();
            $table->foreignId('substitute_player_id')->nullable()->constrained('players')->nullOnDelete();
            $table->text('description')->nullable();
            $table->timestamps();

            $table->index(['match_id', 'type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('match_events');
    }
};
