<?php

namespace App\Filament\Widgets;

use App\Models\User;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class RecentUsersWidget extends BaseWidget
{
    protected int | string | array $columnSpan = [
        'default' => 'full',
        'md' => 1,
        'xl' => 1,
    ];

    protected static ?int $sort = 3;

    protected static ?string $heading = '👥 Người dùng mới';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                User::query()
                    ->with('roles')
                    ->latest()
                    ->limit(8)
            )
            ->columns([
                Tables\Columns\ImageColumn::make('avatar')
                    ->label('')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=10b981&color=fff')
                    ->size(40),
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên')
                    ->searchable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->email),
                Tables\Columns\TextColumn::make('sport_points')
                    ->label('Điểm')
                    ->badge()
                    ->color('success')
                    ->icon('heroicon-m-star'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Tham gia')
                    ->since()
                    ->color('gray'),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('Xem')
                    ->icon('heroicon-m-eye')
                    ->url(fn ($record) => route('filament.admin.resources.users.edit', $record))
                    ->openUrlInNewTab(false)
                    ->color('primary'),
            ])
            ->emptyStateHeading('Chưa có người dùng')
            ->emptyStateIcon('heroicon-o-users')
            ->striped()
            ->paginated(false);
    }
}
