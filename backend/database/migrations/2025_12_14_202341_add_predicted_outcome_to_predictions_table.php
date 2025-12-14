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
        // Kiểm tra cột predicted_outcome đã tồn tại chưa
        if (!Schema::hasColumn('predictions', 'predicted_outcome')) {
            // Thêm cột predicted_outcome dùng raw SQL để tránh vấn đề với Doctrine DBAL
            \DB::statement("ALTER TABLE predictions ADD COLUMN predicted_outcome ENUM('home', 'draw', 'away') NULL AFTER match_id");
        }

        // Thêm cột is_correct_outcome nếu chưa có
        if (!Schema::hasColumn('predictions', 'is_correct_outcome')) {
            Schema::table('predictions', function (Blueprint $table) {
                $table->boolean('is_correct_outcome')->default(false)->after('points_earned');
            });
        }

        // Cập nhật các bản ghi hiện có: tính predicted_outcome từ home_score và away_score (nếu các cột này tồn tại)
        if (Schema::hasColumn('predictions', 'home_score') && Schema::hasColumn('predictions', 'away_score')) {
            \DB::statement("
                UPDATE predictions 
                SET predicted_outcome = CASE 
                    WHEN home_score > away_score THEN 'home'
                    WHEN home_score < away_score THEN 'away'
                    ELSE 'draw'
                END
                WHERE predicted_outcome IS NULL
            ");
        }

        // Đặt cột là NOT NULL sau khi đã cập nhật dữ liệu
        \DB::statement("ALTER TABLE predictions MODIFY COLUMN predicted_outcome ENUM('home', 'draw', 'away') NOT NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Không xóa cột để bảo toàn dữ liệu
    }
};
