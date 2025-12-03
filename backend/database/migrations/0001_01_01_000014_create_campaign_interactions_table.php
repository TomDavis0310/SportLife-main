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
        Schema::create('campaign_interactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained('sponsor_campaigns')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('type', ['view', 'click', 'complete'])->default('view');
            $table->unsignedInteger('points_earned')->default(0);
            $table->timestamps();

            $table->index(['campaign_id', 'user_id', 'type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('campaign_interactions');
    }
};
