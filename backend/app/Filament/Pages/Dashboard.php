<?php

namespace App\Filament\Pages;

use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';
    
    protected static ?string $title = 'Tổng quan';
    
    protected static ?string $navigationLabel = 'Tổng quan';

    protected static ?int $navigationSort = -2;

    public function getColumns(): int | string | array
    {
        return [
            'default' => 1,
            'sm' => 2,
            'md' => 3,
            'lg' => 4,
            'xl' => 4,
            '2xl' => 4,
        ];
    }

    public function getWidgets(): array
    {
        return [
            \App\Filament\Widgets\AdminStatsOverview::class,
            \App\Filament\Widgets\PendingRedemptionsWidget::class,
            \App\Filament\Widgets\RecentUsersWidget::class,
            \App\Filament\Widgets\UserGrowthChart::class,
            \App\Filament\Widgets\RedemptionStatusChart::class,
            \App\Filament\Widgets\SystemHealthWidget::class,
        ];
    }
}
