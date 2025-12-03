<?php

namespace App\Filament\Widgets;

use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\User;
use App\Models\RewardRedemption;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Tổng người dùng', User::count())
                ->description('Người dùng đã đăng ký')
                ->descriptionIcon('heroicon-m-users')
                ->chart([7, 3, 4, 5, 6, 3, 5, 8])
                ->color('success'),

            Stat::make('Dự đoán hôm nay', Prediction::whereDate('created_at', today())->count())
                ->description('Dự đoán được tạo hôm nay')
                ->descriptionIcon('heroicon-m-chart-bar')
                ->color('primary'),

            Stat::make('Trận đấu trực tiếp', FootballMatch::live()->count())
                ->description('Đang diễn ra')
                ->descriptionIcon('heroicon-m-play')
                ->color('danger'),

            Stat::make('Đổi thưởng chờ xử lý', RewardRedemption::where('status', 'pending')->count())
                ->description('Đang chờ xử lý')
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->color('warning'),
        ];
    }
}
