<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('match_statistics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('match_id')->constrained('matches')->cascadeOnDelete();
            $table->enum('side', ['home', 'away']);
            $table->unsignedSmallInteger('shots')->default(0);
            $table->unsignedSmallInteger('shots_on_target')->default(0);
            $table->unsignedTinyInteger('possession')->default(50);
            $table->unsignedSmallInteger('passes')->default(0);
            $table->unsignedTinyInteger('pass_accuracy')->default(0);
            $table->unsignedTinyInteger('fouls')->default(0);
            $table->unsignedTinyInteger('yellow_cards')->default(0);
            $table->unsignedTinyInteger('red_cards')->default(0);
            $table->unsignedTinyInteger('offsides')->default(0);
            $table->unsignedTinyInteger('corners')->default(0);
            $table->timestamps();

            $table->unique(['match_id', 'side']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('match_statistics');
    }
};
