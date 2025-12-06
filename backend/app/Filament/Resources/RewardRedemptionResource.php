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
use Filament\Support\Enums\FontWeight;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\Filter;
use Illuminate\Database\Eloquent\Builder;
use Filament\Infolists;
use Filament\Infolists\Infolist;

class RewardRedemptionResource extends Resource
{
    protected static ?string $model = RewardRedemption::class;

    protected static ?string $navigationIcon = 'heroicon-o-gift';

    protected static ?string $navigationGroup = 'Đổi thưởng';

    protected static ?string $modelLabel = 'Yêu cầu đổi thưởng';

    protected static ?string $pluralModelLabel = 'Yêu cầu đổi thưởng';

    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'pending')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        $count = static::getModel()::where('status', 'pending')->count();
        return $count > 5 ? 'danger' : ($count > 0 ? 'warning' : 'success');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Grid::make()
                    ->schema([
                        Forms\Components\Section::make('Thông tin yêu cầu')
                            ->description('Chi tiết về yêu cầu đổi thưởng')
                            ->icon('heroicon-o-information-circle')
                            ->schema([
                                Forms\Components\Placeholder::make('user_info')
                                    ->label('Người dùng')
                                    ->content(fn ($record) => $record?->user?->name . ' (' . $record?->user?->email . ')'),
                                Forms\Components\Placeholder::make('reward_info')
                                    ->label('Phần thưởng')
                                    ->content(fn ($record) => $record?->reward?->name),
                                Forms\Components\Placeholder::make('points_spent')
                                    ->label('Điểm đã dùng')
                                    ->content(fn ($record) => number_format($record?->points_spent ?? 0) . ' điểm'),
                                Forms\Components\Placeholder::make('created_at')
                                    ->label('Ngày yêu cầu')
                                    ->content(fn ($record) => $record?->created_at?->format('d/m/Y H:i')),
                            ])->columns(2),

                        Forms\Components\Section::make('Xử lý yêu cầu')
                            ->description('Cập nhật trạng thái và ghi chú')
                            ->icon('heroicon-o-cog')
                            ->schema([
                                Forms\Components\Select::make('status')
                                    ->label('Trạng thái')
                                    ->options([
                                        'pending' => '⏳ Chờ xử lý',
                                        'approved' => '✅ Đã duyệt',
                                        'rejected' => '❌ Từ chối',
                                        'shipped' => '🚚 Đang giao',
                                        'delivered' => '📦 Đã giao',
                                        'cancelled' => '🚫 Đã hủy',
                                    ])
                                    ->required()
                                    ->native(false),
                                Forms\Components\Textarea::make('notes')
                                    ->label('Ghi chú xử lý')
                                    ->maxLength(500)
                                    ->placeholder('Nhập ghi chú cho yêu cầu này...')
                                    ->rows(3),
                                Forms\Components\DateTimePicker::make('processed_at')
                                    ->label('Ngày xử lý')
                                    ->default(now()),
                            ]),
                    ])->columnSpan(['lg' => 2]),

                Forms\Components\Grid::make()
                    ->schema([
                        Forms\Components\Section::make('Thông tin giao hàng')
                            ->description('Điền khi phần thưởng là vật phẩm')
                            ->icon('heroicon-o-truck')
                            ->schema([
                                Forms\Components\TextInput::make('shipping_name')
                                    ->label('Tên người nhận')
                                    ->maxLength(255)
                                    ->placeholder('Nguyễn Văn A'),
                                Forms\Components\TextInput::make('shipping_phone')
                                    ->label('Số điện thoại')
                                    ->tel()
                                    ->maxLength(20)
                                    ->placeholder('0901234567'),
                                Forms\Components\Textarea::make('shipping_address')
                                    ->label('Địa chỉ giao hàng')
                                    ->maxLength(500)
                                    ->placeholder('Số nhà, đường, phường, quận, thành phố...')
                                    ->rows(3),
                            ]),

                        Forms\Components\Section::make('Lịch sử')
                            ->icon('heroicon-o-clock')
                            ->schema([
                                Forms\Components\Placeholder::make('processed_info')
                                    ->label('Thời gian xử lý')
                                    ->content(fn ($record) => $record?->processed_at?->format('d/m/Y H:i') ?? 'Chưa xử lý'),
                                Forms\Components\Placeholder::make('updated_info')
                                    ->label('Cập nhật lần cuối')
                                    ->content(fn ($record) => $record?->updated_at?->diffForHumans() ?? 'N/A'),
                            ]),
                    ])->columnSpan(['lg' => 1]),
            ])->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable()
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\ImageColumn::make('user.avatar')
                    ->label('')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->user?->name ?? 'U') . '&background=10b981&color=fff')
                    ->size(40),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Người dùng')
                    ->searchable()
                    ->sortable()
                    ->weight(FontWeight::Bold)
                    ->description(fn ($record) => $record->user?->email),
                Tables\Columns\TextColumn::make('reward.name')
                    ->label('Phần thưởng')
                    ->searchable()
                    ->limit(30)
                    ->tooltip(fn ($record) => $record->reward?->name)
                    ->description(fn ($record) => $record->reward?->type ?? ''),
                Tables\Columns\TextColumn::make('points_spent')
                    ->label('Điểm')
                    ->badge()
                    ->color('warning')
                    ->icon('heroicon-m-star')
                    ->alignCenter()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Chờ xử lý',
                        'approved' => 'Đã duyệt',
                        'rejected' => 'Từ chối',
                        'shipped' => 'Đang giao',
                        'delivered' => 'Đã giao',
                        'cancelled' => 'Đã hủy',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'info',
                        'rejected' => 'danger',
                        'shipped' => 'primary',
                        'delivered' => 'success',
                        'cancelled' => 'gray',
                        default => 'gray',
                    })
                    ->icon(fn (string $state): string => match ($state) {
                        'pending' => 'heroicon-m-clock',
                        'approved' => 'heroicon-m-check',
                        'rejected' => 'heroicon-m-x-mark',
                        'shipped' => 'heroicon-m-truck',
                        'delivered' => 'heroicon-m-check-circle',
                        'cancelled' => 'heroicon-m-x-circle',
                        default => 'heroicon-m-question-mark-circle',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày yêu cầu')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->description(fn ($record) => $record->created_at->diffForHumans()),
                Tables\Columns\TextColumn::make('processed_at')
                    ->label('Ngày xử lý')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->placeholder('Chưa xử lý')
                    ->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->label('Trạng thái')
                    ->options([
                        'pending' => 'Chờ xử lý',
                        'approved' => 'Đã duyệt',
                        'rejected' => 'Từ chối',
                        'shipped' => 'Đang giao',
                        'delivered' => 'Đã giao',
                        'cancelled' => 'Đã hủy',
                    ])
                    ->multiple()
                    ->preload(),
                Filter::make('pending_only')
                    ->label('Chỉ chờ xử lý')
                    ->query(fn (Builder $query): Builder => $query->where('status', 'pending'))
                    ->toggle(),
                Filter::make('created_at')
                    ->form([
                        Forms\Components\DatePicker::make('from')->label('Từ ngày'),
                        Forms\Components\DatePicker::make('until')->label('Đến ngày'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when($data['from'], fn ($query, $date) => $query->whereDate('created_at', '>=', $date))
                            ->when($data['until'], fn ($query, $date) => $query->whereDate('created_at', '<=', $date));
                    }),
            ])
            ->filtersFormColumns(2)
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make()
                        ->label('Xem chi tiết'),
                    Tables\Actions\EditAction::make()
                        ->label('Chỉnh sửa'),
                    Tables\Actions\Action::make('approve')
                        ->label('Duyệt yêu cầu')
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->visible(fn ($record) => $record->status === 'pending')
                        ->requiresConfirmation()
                        ->modalHeading('Xác nhận duyệt')
                        ->modalDescription('Bạn có chắc chắn muốn duyệt yêu cầu đổi thưởng này?')
                        ->action(function ($record) {
                            $record->update([
                                'status' => 'approved',
                                'processed_at' => now(),
                            ]);
                            Notification::make()
                                ->title('Đã duyệt yêu cầu')
                                ->body('Yêu cầu đổi thưởng đã được duyệt thành công.')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\Action::make('reject')
                        ->label('Từ chối')
                        ->icon('heroicon-o-x-mark')
                        ->color('danger')
                        ->visible(fn ($record) => $record->status === 'pending')
                        ->requiresConfirmation()
                        ->modalHeading('Xác nhận từ chối')
                        ->modalDescription('Bạn có chắc chắn muốn từ chối? Điểm sẽ được hoàn lại cho người dùng.')
                        ->form([
                            Forms\Components\Textarea::make('rejection_reason')
                                ->label('Lý do từ chối')
                                ->required()
                                ->maxLength(500),
                        ])
                        ->action(function ($record, array $data) {
                            // Hoàn điểm cho user
                            $record->user->increment('sport_points', $record->points_spent);
                            $record->update([
                                'status' => 'rejected',
                                'notes' => $data['rejection_reason'],
                                'processed_at' => now(),
                            ]);
                            Notification::make()
                                ->title('Đã từ chối yêu cầu')
                                ->body('Điểm đã được hoàn lại cho người dùng.')
                                ->warning()
                                ->send();
                        }),
                    Tables\Actions\Action::make('ship')
                        ->label('Chuyển giao hàng')
                        ->icon('heroicon-o-truck')
                        ->color('primary')
                        ->visible(fn ($record) => $record->status === 'approved')
                        ->action(function ($record) {
                            $record->update(['status' => 'shipped']);
                            Notification::make()
                                ->title('Đã chuyển trạng thái')
                                ->body('Yêu cầu đã được chuyển sang trạng thái giao hàng.')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\Action::make('deliver')
                        ->label('Hoàn thành giao hàng')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->visible(fn ($record) => $record->status === 'shipped')
                        ->action(function ($record) {
                            $record->update(['status' => 'delivered']);
                            Notification::make()
                                ->title('Hoàn thành!')
                                ->body('Yêu cầu đổi thưởng đã được hoàn tất.')
                                ->success()
                                ->send();
                        }),
                ])->tooltip('Thao tác'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('bulk_approve')
                        ->label('Duyệt hàng loạt')
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function ($records) {
                            $records->each(function ($record) {
                                if ($record->status === 'pending') {
                                    $record->update([
                                        'status' => 'approved',
                                        'processed_at' => now(),
                                    ]);
                                }
                            });
                            Notification::make()
                                ->title('Đã duyệt hàng loạt')
                                ->success()
                                ->send();
                        }),
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Xóa đã chọn'),
                ]),
            ])
            ->striped()
            ->poll('30s')
            ->emptyStateHeading('Không có yêu cầu nào')
            ->emptyStateDescription('Chưa có yêu cầu đổi thưởng nào được tạo.')
            ->emptyStateIcon('heroicon-o-gift');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Thông tin người dùng')
                    ->schema([
                        Infolists\Components\TextEntry::make('user.name')
                            ->label('Tên'),
                        Infolists\Components\TextEntry::make('user.email')
                            ->label('Email'),
                        Infolists\Components\TextEntry::make('user.sport_points')
                            ->label('Điểm hiện tại')
                            ->badge()
                            ->color('success'),
                    ])->columns(3),
                Infolists\Components\Section::make('Chi tiết phần thưởng')
                    ->schema([
                        Infolists\Components\TextEntry::make('reward.name')
                            ->label('Tên phần thưởng'),
                        Infolists\Components\TextEntry::make('reward.type')
                            ->label('Loại'),
                        Infolists\Components\TextEntry::make('points_spent')
                            ->label('Điểm đã dùng')
                            ->badge()
                            ->color('warning'),
                    ])->columns(3),
                Infolists\Components\Section::make('Trạng thái xử lý')
                    ->schema([
                        Infolists\Components\TextEntry::make('status')
                            ->label('Trạng thái')
                            ->badge(),
                        Infolists\Components\TextEntry::make('notes')
                            ->label('Ghi chú'),
                        Infolists\Components\TextEntry::make('processed_at')
                            ->label('Ngày xử lý')
                            ->dateTime('d/m/Y H:i'),
                    ])->columns(3),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRewardRedemptions::route('/'),
            'view' => Pages\ViewRewardRedemption::route('/{record}'),
            'edit' => Pages\EditRewardRedemption::route('/{record}/edit'),
        ];
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['user.name', 'user.email', 'reward.name'];
    }
}
