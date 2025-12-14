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
        // Sử dụng raw SQL để thêm giá trị mặc định cho các cột score (tránh vấn đề Doctrine DBAL với enum)
        \DB::statement("ALTER TABLE predictions MODIFY COLUMN home_score TINYINT UNSIGNED NULL DEFAULT NULL");
        \DB::statement("ALTER TABLE predictions MODIFY COLUMN away_score TINYINT UNSIGNED NULL DEFAULT NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        \DB::statement("ALTER TABLE predictions MODIFY COLUMN home_score TINYINT UNSIGNED NOT NULL");
        \DB::statement("ALTER TABLE predictions MODIFY COLUMN away_score TINYINT UNSIGNED NOT NULL");
    }
};
