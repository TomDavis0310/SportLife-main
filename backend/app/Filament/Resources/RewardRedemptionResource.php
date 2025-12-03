<?php

namespace App\Filament\Resources;

use App\Enums\RedemptionStatus;
use App\Filament\Resources\RewardRedemptionResource\Pages;
use App\Models\RewardRedemption;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class RewardRedemptionResource extends Resource
{
    protected static ?string $model = RewardRedemption::class;

    protected static ?string $navigationIcon = 'heroicon-o-shopping-bag';

    protected static ?string $navigationGroup = 'Tài trợ & Đổi thưởng';

    protected static ?string $modelLabel = 'Đổi thưởng';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết đổi thưởng')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Người dùng')
                            ->relationship('user', 'name')
                            ->disabled()
                            ->required(),
                        Forms\Components\Select::make('reward_id')
                            ->label('Phần thưởng')
                            ->relationship('reward', 'name')
                            ->disabled()
                            ->required(),
                        Forms\Components\TextInput::make('points_spent')
                            ->label('Điểm đã dùng')
                            ->disabled(),
                    ])->columns(3),

                Forms\Components\Section::make('Trạng thái')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Trạng thái')
                            ->options(RedemptionStatus::class)
                            ->required(),
                        Forms\Components\Textarea::make('notes')
                            ->label('Ghi chú')
                            ->maxLength(500),
                    ]),

                Forms\Components\Section::make('Giao hàng')
                    ->schema([
                        Forms\Components\Textarea::make('shipping_address')
                            ->label('Địa chỉ giao hàng')
                            ->maxLength(500),
                        Forms\Components\TextInput::make('tracking_number')
                            ->label('Mã vận đơn')
                            ->maxLength(100),
                    ])->columns(2),

                Forms\Components\Section::make('Thời gian')
                    ->schema([
                        Forms\Components\DateTimePicker::make('processed_at')
                            ->label('Ngày xử lý'),
                        Forms\Components\DateTimePicker::make('completed_at')
                            ->label('Ngày hoàn thành'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Người dùng')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('reward.name')
                    ->label('Phần thưởng')
                    ->searchable(),
                Tables\Columns\TextColumn::make('points_spent')
                    ->label('Điểm')
                    ->badge()
                    ->color('danger'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'processing' => 'info',
                        'shipped' => 'primary',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Trạng thái')
                    ->options(RedemptionStatus::class),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('approve')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'processing',
                            'processed_at' => now(),
                        ]);
                        Notification::make()
                            ->title('Redemption approved')
                            ->success()
                            ->send();
                    }),
                Tables\Actions\Action::make('complete')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => in_array($record->status, ['processing', 'shipped']))
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'completed',
                            'completed_at' => now(),
                        ]);
                        Notification::make()
                            ->title('Redemption completed')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRewardRedemptions::route('/'),
            'edit' => Pages\EditRewardRedemption::route('/{record}/edit'),
        ];
    }
}
