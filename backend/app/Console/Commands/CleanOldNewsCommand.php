<?php

namespace App\Console\Commands;

use App\Services\NewsScraperService;
use Illuminate\Console\Command;

class CleanOldNewsCommand extends Command
{
    protected $signature = 'news:clean {--days=30 : Số ngày để giữ lại tin}';

    protected $description = 'Dọn dẹp tin tức tự động cũ';

    public function handle(NewsScraperService $scraperService): int
    {
        $days = (int) $this->option('days');

        $this->info("🧹 Đang dọn dẹp tin tức cũ hơn {$days} ngày...");

        try {
            $count = $scraperService->cleanOldAutoFetchedNews($days);

            $this->info("✅ Đã xóa {$count} bài viết cũ.");

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("❌ Lỗi: {$e->getMessage()}");
            return Command::FAILURE;
        }
    }
}
