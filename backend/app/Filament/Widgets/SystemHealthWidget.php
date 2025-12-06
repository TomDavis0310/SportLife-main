<?php

namespace App\Filament\Widgets;

use Filament\Widgets\Widget;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SystemHealthWidget extends Widget
{
    protected static string $view = 'filament.widgets.system-health-widget';

    protected int | string | array $columnSpan = [
        'default' => 'full',
        'md' => 1,
        'xl' => 1,
    ];

    protected static ?int $sort = 4;

    public function getHealthData(): array
    {
        return [
            [
                'name' => 'Database',
                'status' => $this->checkDatabase(),
                'icon' => 'heroicon-o-circle-stack',
            ],
            [
                'name' => 'Cache',
                'status' => $this->checkCache(),
                'icon' => 'heroicon-o-bolt',
            ],
            [
                'name' => 'Storage',
                'status' => $this->checkStorage(),
                'icon' => 'heroicon-o-folder',
            ],
            [
                'name' => 'Queue',
                'status' => $this->checkQueue(),
                'icon' => 'heroicon-o-queue-list',
            ],
        ];
    }

    protected function checkDatabase(): string
    {
        try {
            DB::connection()->getPdo();
            return 'healthy';
        } catch (\Exception $e) {
            return 'unhealthy';
        }
    }

    protected function checkCache(): string
    {
        try {
            Cache::put('health_check', true, 10);
            return Cache::get('health_check') ? 'healthy' : 'unhealthy';
        } catch (\Exception $e) {
            return 'unhealthy';
        }
    }

    protected function checkStorage(): string
    {
        try {
            $path = storage_path('app');
            return is_writable($path) ? 'healthy' : 'unhealthy';
        } catch (\Exception $e) {
            return 'unhealthy';
        }
    }

    protected function checkQueue(): string
    {
        // Simplified check - in production, you might want to check actual queue health
        return 'healthy';
    }
}
