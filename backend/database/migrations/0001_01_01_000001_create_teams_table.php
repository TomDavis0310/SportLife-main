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
        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('name_en')->nullable();
            $table->string('short_name', 5);
            $table->string('logo')->nullable();
            $table->string('stadium')->nullable();
            $table->string('city')->nullable();
            $table->string('country', 100)->nullable();
            $table->unsignedSmallInteger('founded_year')->nullable();
            $table->foreignId('manager_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->text('description')->nullable();
            $table->text('description_en')->nullable();
            $table->string('primary_color', 7)->default('#00FF00');
            $table->string('secondary_color', 7)->default('#000000');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Add foreign key for favorite_team_id in users
        Schema::table('users', function (Blueprint $table) {
            $table->foreign('favorite_team_id')->references('id')->on('teams')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['favorite_team_id']);
        });
        Schema::dropIfExists('teams');
    }
};
