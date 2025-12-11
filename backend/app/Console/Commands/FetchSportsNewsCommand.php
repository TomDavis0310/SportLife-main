<?php

namespace App\Console\Commands;

use App\Services\NewsScraperService;
use Illuminate\Console\Command;

class FetchSportsNewsCommand extends Command
{
    protected $signature = 'news:fetch {--source= : Tên nguồn cụ thể (vnexpress, thanhnien, tuoitre, bongdaplus, bongda24h)}';

    protected $description = 'Fetch tin tức thể thao từ các nguồn chính thống';

    public function handle(NewsScraperService $scraperService): int
    {
        $source = $this->option('source');

        $this->info('🏈 Bắt đầu fetch tin tức thể thao...');

        try {
            if ($source) {
                $this->info("📰 Đang fetch từ nguồn: {$source}");
                $results = $scraperService->fetchFromSourceByName($source);
            } else {
                $this->info('📰 Đang fetch từ tất cả các nguồn...');
                $results = $scraperService->fetchAllNews();
            }

            $this->newLine();
            $this->info('✅ Kết quả:');
            $this->line("   - Bài viết mới: {$results['success']}");
            $this->line("   - Bỏ qua (đã tồn tại): {$results['skipped']}");

            if (!empty($results['errors'])) {
                $this->newLine();
                $this->warn('⚠️ Một số nguồn gặp lỗi:');
                foreach ($results['errors'] as $error) {
                    $this->line("   - {$error}");
                }
            }

            $this->newLine();
            $this->info('🎉 Hoàn thành!');

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("❌ Lỗi: {$e->getMessage()}");
            return Command::FAILURE;
        }
    }
}
