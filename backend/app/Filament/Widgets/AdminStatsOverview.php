<?php

namespace App\Filament\Widgets;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\User;
use App\Models\RewardRedemption;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Carbon\Carbon;

class AdminStatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;
    
    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        $now = Carbon::now();
        $lastMonth = Carbon::now()->subMonth();
        
        // Tính toán tăng trưởng người dùng
        $totalUsers = User::count();
        $newUsersThisMonth = User::where('created_at', '>=', $now->startOfMonth())->count();
        $newUsersLastMonth = User::whereBetween('created_at', [$lastMonth->startOfMonth(), $lastMonth->endOfMonth()])->count();
        $userGrowth = $newUsersLastMonth > 0 
            ? round((($newUsersThisMonth - $newUsersLastMonth) / $newUsersLastMonth) * 100, 1) 
            : 100;

        // Dự đoán hôm nay
        $predictionsToday = Prediction::whereDate('created_at', today())->count();
        $predictionsYesterday = Prediction::whereDate('created_at', today()->subDay())->count();
        
        // Đổi thưởng chờ xử lý
        $pendingRedemptions = RewardRedemption::where('status', 'pending')->count();
        
        // Trận đấu đang diễn ra
        $liveMatches = FootballMatch::live()->count();

        return [
            Stat::make('Tổng người dùng', number_format($totalUsers))
                ->description("+" . $newUsersThisMonth . " người dùng tháng này")
                ->descriptionIcon($userGrowth >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->chart([7, 12, 8, 15, 10, 18, $newUsersThisMonth])
                ->color($userGrowth >= 0 ? 'success' : 'danger')
                ->extraAttributes([
                    'class' => 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition',
                ]),

            Stat::make('Dự đoán hôm nay', number_format($predictionsToday))
                ->description($predictionsToday > $predictionsYesterday ? "Tăng so với hôm qua" : "Giảm so với hôm qua")
                ->descriptionIcon($predictionsToday >= $predictionsYesterday ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->chart([5, 8, 6, 12, 9, 15, $predictionsToday])
                ->color('info')
                ->extraAttributes([
                    'class' => 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition',
                ]),

            Stat::make('Đổi thưởng chờ duyệt', $pendingRedemptions)
                ->description($pendingRedemptions > 0 ? "Cần xử lý ngay" : "Không có yêu cầu")
                ->descriptionIcon($pendingRedemptions > 0 ? 'heroicon-m-exclamation-circle' : 'heroicon-m-check-circle')
                ->color($pendingRedemptions > 5 ? 'danger' : ($pendingRedemptions > 0 ? 'warning' : 'success'))
                ->extraAttributes([
                    'class' => 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition',
                ]),

            Stat::make('Trận đấu trực tiếp', $liveMatches)
                ->description($liveMatches > 0 ? "Đang diễn ra" : "Không có trận nào")
                ->descriptionIcon($liveMatches > 0 ? 'heroicon-m-play-circle' : 'heroicon-m-pause-circle')
                ->color($liveMatches > 0 ? 'danger' : 'gray')
                ->extraAttributes([
                    'class' => 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700/50 transition',
                ]),
        ];
    }
}
