<?php

namespace App\Filament\Widgets;

use App\Models\RewardRedemption;
use Filament\Widgets\ChartWidget;
use Carbon\Carbon;

class RedemptionStatusChart extends ChartWidget
{
    protected static ?string $heading = '📊 Phân bố trạng thái đổi thưởng';

    protected static ?int $sort = 6;

    protected int | string | array $columnSpan = [
        'default' => 'full',
        'md' => 1,
        'xl' => 1,
    ];

    protected function getData(): array
    {
        $data = RewardRedemption::selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->get()
            ->mapWithKeys(fn ($item) => [$item->status => $item->count]);

        $statusLabels = [
            'pending' => 'Chờ xử lý',
            'approved' => 'Đã duyệt',
            'rejected' => 'Từ chối',
            'shipped' => 'Đang giao',
            'delivered' => 'Đã giao',
            'cancelled' => 'Đã hủy',
        ];

        $statusColors = [
            'pending' => 'rgb(245, 158, 11)',
            'approved' => 'rgb(59, 130, 246)',
            'rejected' => 'rgb(239, 68, 68)',
            'shipped' => 'rgb(99, 102, 241)',
            'delivered' => 'rgb(16, 185, 129)',
            'cancelled' => 'rgb(107, 114, 128)',
        ];

        $labels = [];
        $values = [];
        $colors = [];

        foreach ($statusLabels as $status => $label) {
            if (isset($data[$status]) && $data[$status] > 0) {
                $labels[] = $label;
                $values[] = $data[$status];
                $colors[] = $statusColors[$status];
            }
        }

        return [
            'datasets' => [
                [
                    'data' => $values,
                    'backgroundColor' => $colors,
                    'borderWidth' => 0,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'position' => 'bottom',
                ],
            ],
            'cutout' => '60%',
        ];
    }
}
