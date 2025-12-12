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
        Schema::table('news', function (Blueprint $table) {
            $table->string('source_name')->nullable()->after('is_published');
            $table->string('source_url')->nullable()->after('source_name');
            $table->string('original_url')->nullable()->after('source_url');
            $table->boolean('is_auto_fetched')->default(false)->after('original_url');
            $table->timestamp('fetched_at')->nullable()->after('is_auto_fetched');
            $table->json('tags')->nullable()->after('fetched_at');
            
            $table->index('is_auto_fetched');
            $table->index('source_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('news', function (Blueprint $table) {
            $table->dropIndex(['is_auto_fetched']);
            $table->dropIndex(['source_name']);
            $table->dropColumn([
                'source_name',
                'source_url', 
                'original_url',
                'is_auto_fetched',
                'fetched_at',
                'tags'
            ]);
        });
    }
};
