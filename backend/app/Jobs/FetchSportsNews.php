<?php

namespace App\Jobs;

use App\Services\NewsScraperService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class FetchSportsNews implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $timeout = 300; // 5 minutes

    protected ?string $source;

    /**
     * Create a new job instance.
     */
    public function __construct(?string $source = null)
    {
        $this->source = $source;
    }

    /**
     * Execute the job.
     */
    public function handle(NewsScraperService $scraperService): void
    {
        Log::info('Starting FetchSportsNews job', ['source' => $this->source ?? 'all']);

        try {
            if ($this->source) {
                $results = $scraperService->fetchFromSourceByName($this->source);
                Log::info("Fetched news from {$this->source}", $results);
            } else {
                $results = $scraperService->fetchAllNews();
                Log::info('Fetched news from all sources', $results);
            }

        } catch (\Exception $e) {
            Log::error('FetchSportsNews job failed', [
                'source' => $this->source ?? 'all',
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw $e;
        }
    }

    /**
     * Handle job failure.
     */
    public function failed(\Throwable $exception): void
    {
        Log::error('FetchSportsNews job permanently failed', [
            'source' => $this->source ?? 'all',
            'error' => $exception->getMessage(),
        ]);
    }
}
