<?php

namespace App\Filament\Pages;

use App\Services\NewsScraperService;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Support\Facades\Log;

class JournalistDashboard extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-newspaper';
    
    protected static ?string $title = 'Quản lý Tin tức';
    
    protected static ?string $navigationLabel = 'Dashboard Nhà báo';

    protected static ?string $navigationGroup = 'Nhà báo';

    protected static ?int $navigationSort = 1;

    protected static string $view = 'filament.pages.journalist-dashboard';

    public static function canAccess(): bool
    {
        $user = auth()->user();
        return $user && ($user->hasRole(['admin', 'journalist']) || $user->hasPermissionTo('news.manage_own'));
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('fetchAllNews')
                ->label('Fetch tất cả tin tức')
                ->icon('heroicon-o-arrow-path')
                ->color('primary')
                ->requiresConfirmation()
                ->modalHeading('Fetch tin tức tự động')
                ->modalDescription('Hệ thống sẽ tự động lấy tin tức thể thao mới nhất từ các nguồn chính thống.')
                ->action(function () {
                    $this->fetchNews();
                }),
            
            Action::make('fetchFromSource')
                ->label('Fetch từ nguồn')
                ->icon('heroicon-o-globe-alt')
                ->color('gray')
                ->form([
                    Select::make('source')
                        ->label('Chọn nguồn tin')
                        ->options([
                            'vnexpress' => 'VnExpress',
                            'thanhnien' => 'Thanh Niên',
                            'tuoitre' => 'Tuổi Trẻ',
                            'bongdaplus' => 'Bóng Đá Plus',
                            'bongda24h' => 'Bongda24h',
                        ])
                        ->required(),
                ])
                ->action(function (array $data) {
                    $this->fetchNewsFromSource($data['source']);
                }),
        ];
    }

    public function fetchNews(): void
    {
        try {
            $scraper = app(NewsScraperService::class);
            $results = $scraper->fetchAllNews();

            Notification::make()
                ->title('Fetch tin tức thành công')
                ->body("Đã tạo {$results['success']} bài viết mới, bỏ qua {$results['skipped']} bài đã tồn tại.")
                ->success()
                ->send();

            if (!empty($results['errors'])) {
                Notification::make()
                    ->title('Một số nguồn gặp lỗi')
                    ->body(implode("\n", $results['errors']))
                    ->warning()
                    ->send();
            }

        } catch (\Exception $e) {
            Log::error('Failed to fetch news', ['error' => $e->getMessage()]);
            
            Notification::make()
                ->title('Lỗi khi fetch tin tức')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function fetchNewsFromSource(string $source): void
    {
        try {
            $scraper = app(NewsScraperService::class);
            $results = $scraper->fetchFromSourceByName($source);

            Notification::make()
                ->title('Fetch tin tức thành công')
                ->body("Đã tạo {$results['success']} bài viết mới từ {$source}, bỏ qua {$results['skipped']} bài đã tồn tại.")
                ->success()
                ->send();

        } catch (\Exception $e) {
            Log::error("Failed to fetch news from {$source}", ['error' => $e->getMessage()]);
            
            Notification::make()
                ->title('Lỗi khi fetch tin tức')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }
}
