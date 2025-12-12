<?php

namespace App\Filament\Widgets;

use App\Enums\RedemptionStatus;
use App\Models\RewardRedemption;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Actions\Action;
use Filament\Widgets\TableWidget as BaseWidget;
use Filament\Notifications\Notification;

class PendingRedemptionsWidget extends BaseWidget
{
    protected int | string | array $columnSpan = [
        'default' => 'full',
        'md' => 2,
        'xl' => 2,
    ];

    protected static ?int $sort = 2;

    protected static ?string $heading = '🎁 Đổi thưởng chờ duyệt';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                RewardRedemption::query()
                    ->with(['user', 'reward'])
                    ->where('status', 'pending')
                    ->latest()
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Người dùng')
                    ->searchable()
                    ->weight('bold')
                    ->icon('heroicon-m-user'),
                Tables\Columns\TextColumn::make('reward.name')
                    ->label('Phần thưởng')
                    ->limit(30)
                    ->tooltip(fn ($record) => $record->reward?->name),
                Tables\Columns\TextColumn::make('points_spent')
                    ->label('Điểm')
                    ->badge()
                    ->color('warning')
                    ->icon('heroicon-m-star'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Thời gian')
                    ->since()
                    ->tooltip(fn ($record) => $record->created_at->format('d/m/Y H:i')),
            ])
            ->actions([
                Action::make('approve')
                    ->label('Duyệt')
                    ->icon('heroicon-m-check')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Xác nhận duyệt đổi thưởng')
                    ->modalDescription('Bạn có chắc chắn muốn duyệt yêu cầu đổi thưởng này?')
                    ->action(function (RewardRedemption $record) {
                        $record->update([
                            'status' => 'approved',
                            'processed_at' => now(),
                        ]);
                        Notification::make()
                            ->title('Đã duyệt đổi thưởng')
                            ->success()
                            ->send();
                    }),
                Action::make('reject')
                    ->label('Từ chối')
                    ->icon('heroicon-m-x-mark')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Xác nhận từ chối đổi thưởng')
                    ->modalDescription('Bạn có chắc chắn muốn từ chối yêu cầu này? Điểm sẽ được hoàn lại cho người dùng.')
                    ->action(function (RewardRedemption $record) {
                        // Hoàn điểm cho user
                        $record->user->increment('sport_points', $record->points_spent);
                        $record->update([
                            'status' => 'rejected',
                            'processed_at' => now(),
                        ]);
                        Notification::make()
                            ->title('Đã từ chối và hoàn điểm')
                            ->warning()
                            ->send();
                    }),
            ])
            ->emptyStateHeading('Không có yêu cầu nào')
            ->emptyStateDescription('Tất cả yêu cầu đổi thưởng đã được xử lý.')
            ->emptyStateIcon('heroicon-o-check-circle')
            ->striped()
            ->paginated(false);
    }
}
