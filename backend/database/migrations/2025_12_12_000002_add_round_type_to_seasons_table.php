<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * round_type options:
     * - round_robin: Vòng tròn (đấu vòng tròn, mỗi đội gặp nhau 1 hoặc 2 lần)
     * - group_stage: Vòng bảng (chia thành nhiều bảng, mỗi bảng đấu vòng tròn)
     * - knockout: Loại trực tiếp (thua là bị loại)
     * - league: Giải vô địch (đấu vòng tròn 2 lượt)
     * - mixed: Kết hợp (vòng bảng + loại trực tiếp)
     */
    public function up(): void
    {
        Schema::table('seasons', function (Blueprint $table) {
            // Add format column if not exists
            if (!Schema::hasColumn('seasons', 'format')) {
                $table->string('format')->nullable()->after('is_current');
            }
        });
        
        Schema::table('seasons', function (Blueprint $table) {
            $table->enum('round_type', [
                'round_robin',  // Vòng tròn
                'group_stage',  // Vòng bảng
                'knockout',     // Loại trực tiếp
                'league',       // Giải vô địch
                'mixed'         // Kết hợp
            ])->default('round_robin')->after('format');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('seasons', function (Blueprint $table) {
            $table->dropColumn(['round_type', 'format']);
        });
    }
};
