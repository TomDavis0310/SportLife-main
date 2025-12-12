<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('players', function (Blueprint $table) {
            if (!Schema::hasColumn('players', 'avatar')) {
                $table->string('avatar')->nullable();
            }
            if (!Schema::hasColumn('players', 'market_value')) {
                $table->decimal('market_value', 15, 2)->nullable();
            }
            if (!Schema::hasColumn('players', 'contract_until')) {
                $table->date('contract_until')->nullable();
            }
            if (!Schema::hasColumn('players', 'nationality')) {
                $table->string('nationality')->nullable();
            }
            if (!Schema::hasColumn('players', 'height')) {
                $table->integer('height')->nullable();
            }
            if (!Schema::hasColumn('players', 'weight')) {
                $table->integer('weight')->nullable();
            }
            if (!Schema::hasColumn('players', 'dob')) {
                $table->date('dob')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('players', function (Blueprint $table) {
            $table->dropColumn(['avatar', 'market_value', 'contract_until', 'nationality', 'height', 'weight', 'dob']);
        });
    }
};
