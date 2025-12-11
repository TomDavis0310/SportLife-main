<?php

namespace App\Jobs;

use App\Services\NewsScraperService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class CleanOldNews implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $timeout = 120;

    protected int $daysOld;

    /**
     * Create a new job instance.
     */
    public function __construct(int $daysOld = 30)
    {
        $this->daysOld = $daysOld;
    }

    /**
     * Execute the job.
     */
    public function handle(NewsScraperService $scraperService): void
    {
        Log::info('Starting CleanOldNews job', ['days_old' => $this->daysOld]);

        try {
            $count = $scraperService->cleanOldAutoFetchedNews($this->daysOld);
            Log::info("Cleaned {$count} old news articles");

        } catch (\Exception $e) {
            Log::error('CleanOldNews job failed', [
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
