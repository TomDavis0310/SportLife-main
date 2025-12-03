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
        Schema::create('point_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('type', [
                'prediction',
                'referral',
                'daily_bonus',
                'ad_view',
                'mission',
                'redemption',
                'badge_reward',
                'admin_adjustment',
                'sponsor_bonus'
            ]);
            $table->integer('points'); // Can be negative for redemption
            $table->text('description')->nullable();
            $table->nullableMorphs('reference'); // reference_type, reference_id
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
            $table->index(['type', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('point_transactions');
    }
};
