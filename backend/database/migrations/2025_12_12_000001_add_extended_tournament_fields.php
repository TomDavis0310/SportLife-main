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
        Schema::table('seasons', function (Blueprint $table) {
            $table->unsignedInteger('min_teams')->default(2)->after('max_teams');
            $table->date('registration_start_date')->nullable()->after('min_teams');
            $table->date('registration_end_date')->nullable()->after('registration_start_date');
            $table->text('description')->nullable()->after('registration_end_date');
            $table->string('location')->nullable()->after('description');
            $table->string('prize')->nullable()->after('location');
            $table->text('rules')->nullable()->after('prize');
            $table->string('contact')->nullable()->after('rules');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('seasons', function (Blueprint $table) {
            $table->dropColumn([
                'min_teams',
                'registration_start_date',
                'registration_end_date',
                'description',
                'location',
                'prize',
                'rules',
                'contact',
            ]);
        });
    }
};
