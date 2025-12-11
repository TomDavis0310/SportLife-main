<?php

namespace App\Console;

use App\Jobs\FetchSportsNews;
use App\Jobs\CleanOldNews;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Fetch tin tức thể thao mỗi 2 giờ
        $schedule->job(new FetchSportsNews())
            ->everyTwoHours()
            ->withoutOverlapping()
            ->runInBackground()
            ->onFailure(function () {
                \Log::error('Scheduled FetchSportsNews job failed');
            });

        // Dọn dẹp tin cũ hàng ngày lúc 3:00 AM
        $schedule->job(new CleanOldNews(30))
            ->dailyAt('03:00')
            ->withoutOverlapping()
            ->runInBackground();
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
