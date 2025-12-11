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
        Schema::create('predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('match_id')->constrained('matches')->cascadeOnDelete();
            $table->enum('predicted_outcome', ['home', 'draw', 'away']); // Dự đoán kết quả: đội nhà thắng, hòa, đội khách thắng
            $table->unsignedInteger('points_earned')->default(0);
            $table->boolean('is_correct_outcome')->default(false);
            $table->decimal('streak_multiplier', 3, 2)->default(1.00);
            $table->dateTime('calculated_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'match_id']);
            $table->index(['match_id', 'points_earned']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('predictions');
    }
};
