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
        Schema::create('champion_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('season_id')->constrained('seasons')->cascadeOnDelete();
            $table->foreignId('predicted_team_id')->constrained('teams')->cascadeOnDelete();
            $table->text('reason')->nullable(); // Lý do dự đoán
            $table->integer('confidence_level')->default(50); // Mức độ tự tin 1-100
            $table->integer('points_wagered')->default(0); // Điểm đặt cược
            $table->integer('points_earned')->default(0); // Điểm nhận được
            $table->enum('status', ['pending', 'won', 'lost'])->default('pending');
            $table->dateTime('calculated_at')->nullable();
            $table->timestamps();
            
            // Mỗi user chỉ được dự đoán 1 lần cho mỗi mùa giải
            $table->unique(['user_id', 'season_id']);
        });

        // Bảng lưu trữ thông tin đội vô địch thực tế
        Schema::create('season_champions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->unique()->constrained('seasons')->cascadeOnDelete();
            $table->foreignId('champion_team_id')->constrained('teams')->cascadeOnDelete();
            $table->dateTime('confirmed_at')->nullable(); // Thời điểm xác nhận vô địch
            $table->timestamps();
        });

        // Bảng bảng xếp hạng dự đoán vô địch
        Schema::create('champion_prediction_leaderboards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('season_id')->nullable()->constrained('seasons')->cascadeOnDelete();
            $table->integer('total_predictions')->default(0);
            $table->integer('correct_predictions')->default(0);
            $table->integer('total_points_wagered')->default(0);
            $table->integer('total_points_earned')->default(0);
            $table->integer('rank')->nullable();
            $table->timestamps();
            
            $table->unique(['user_id', 'season_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('champion_prediction_leaderboards');
        Schema::dropIfExists('season_champions');
        Schema::dropIfExists('champion_predictions');
    }
};
