<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Infolists;
use Filament\Infolists\Infolist;
use Illuminate\Support\Facades\Hash;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\Filter;
use Illuminate\Database\Eloquent\Builder;
use Filament\Support\Enums\FontWeight;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationGroup = 'Người dùng';

    protected static ?string $modelLabel = 'Người dùng';

    protected static ?string $pluralModelLabel = 'Người dùng';

    protected static ?int $navigationSort = 1;

    protected static ?string $recordTitleAttribute = 'name';

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Grid::make()
                    ->schema([
                        Forms\Components\Section::make('Thông tin cơ bản')
                            ->description('Thông tin đăng nhập của người dùng')
                            ->icon('heroicon-o-user')
                            ->schema([
                                Forms\Components\TextInput::make('name')
                                    ->label('Họ và tên')
                                    ->required()
                                    ->maxLength(255)
                                    ->placeholder('Nhập họ và tên'),
                                Forms\Components\TextInput::make('username')
                                    ->label('Tên đăng nhập')
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(255)
                                    ->placeholder('Nhập tên đăng nhập')
                                    ->alphaDash(),
                                Forms\Components\TextInput::make('email')
                                    ->label('Email')
                                    ->email()
                                    ->required()
                                    ->unique(ignoreRecord: true)
                                    ->maxLength(255)
                                    ->placeholder('example@email.com'),
                                Forms\Components\TextInput::make('password')
                                    ->label('Mật khẩu')
                                    ->password()
                                    ->revealable()
                                    ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                                    ->dehydrated(fn ($state) => filled($state))
                                    ->required(fn (string $operation): bool => $operation === 'create')
                                    ->minLength(8)
                                    ->placeholder('Tối thiểu 8 ký tự'),
                            ])->columns(2),

                        Forms\Components\Section::make('Hồ sơ cá nhân')
                            ->description('Thông tin chi tiết về người dùng')
                            ->icon('heroicon-o-identification')
                            ->schema([
                                Forms\Components\FileUpload::make('avatar')
                                    ->label('Ảnh đại diện')
                                    ->image()
                                    ->imageEditor()
                                    ->circleCropper()
                                    ->directory('avatars')
                                    ->columnSpanFull(),
                                Forms\Components\Textarea::make('bio')
                                    ->label('Giới thiệu bản thân')
                                    ->maxLength(500)
                                    ->rows(3)
                                    ->placeholder('Mô tả ngắn về bản thân...'),
                                Forms\Components\TextInput::make('country')
                                    ->label('Quốc gia')
                                    ->maxLength(100)
                                    ->placeholder('Việt Nam'),
                            ])->columns(2),
                    ])->columnSpan(['lg' => 2]),

                Forms\Components\Grid::make()
                    ->schema([
                        Forms\Components\Section::make('Điểm & Thành tích')
                            ->icon('heroicon-o-star')
                            ->schema([
                                Forms\Components\TextInput::make('sport_points')
                                    ->label('Điểm Sport')
                                    ->numeric()
                                    ->default(0)
                                    ->suffix('điểm')
                                    ->helperText('Điểm tích lũy từ hoạt động'),
                                Forms\Components\TextInput::make('prediction_streak')
                                    ->label('Chuỗi thắng')
                                    ->numeric()
                                    ->default(0)
                                    ->suffix('trận')
                                    ->helperText('Số trận dự đoán đúng liên tiếp'),
                            ]),

                        Forms\Components\Section::make('Vai trò & Quyền hạn')
                            ->icon('heroicon-o-shield-check')
                            ->schema([
                                Forms\Components\Select::make('roles')
                                    ->label('Vai trò')
                                    ->relationship('roles', 'name')
                                    ->multiple()
                                    ->preload()
                                    ->searchable()
                                    ->helperText('Chọn vai trò cho người dùng'),
                            ]),

                        Forms\Components\Section::make('Trạng thái')
                            ->icon('heroicon-o-cog')
                            ->schema([
                                Forms\Components\Toggle::make('email_verified_at')
                                    ->label('Email đã xác thực')
                                    ->helperText('Trạng thái xác thực email')
                                    ->dehydrateStateUsing(fn ($state) => $state ? now() : null)
                                    ->formatStateUsing(fn ($state) => $state !== null),
                            ]),
                    ])->columnSpan(['lg' => 1]),
            ])->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('avatar')
                    ->label('')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=10b981&color=fff')
                    ->size(45),
                Tables\Columns\TextColumn::make('name')
                    ->label('Người dùng')
                    ->searchable()
                    ->sortable()
                    ->weight(FontWeight::Bold)
                    ->description(fn ($record) => $record->email),
                Tables\Columns\TextColumn::make('username')
                    ->label('Tên đăng nhập')
                    ->searchable()
                    ->toggleable()
                    ->copyable()
                    ->copyMessage('Đã sao chép!')
                    ->color('gray'),
                Tables\Columns\TextColumn::make('sport_points')
                    ->label('Điểm Sport')
                    ->sortable()
                    ->badge()
                    ->color('success')
                    ->icon('heroicon-m-star')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('prediction_streak')
                    ->label('Chuỗi thắng')
                    ->sortable()
                    ->badge()
                    ->color('warning')
                    ->icon('heroicon-m-fire')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('roles.name')
                    ->label('Vai trò')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'admin' => 'danger',
                        'club_manager' => 'warning',
                        'sponsor' => 'info',
                        default => 'gray',
                    })
                    ->separator(', '),
                Tables\Columns\IconColumn::make('email_verified_at')
                    ->label('Xác thực')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Cập nhật')
                    ->since()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('roles')
                    ->label('Vai trò')
                    ->relationship('roles', 'name')
                    ->multiple()
                    ->preload(),
                Filter::make('verified')
                    ->label('Đã xác thực email')
                    ->query(fn (Builder $query): Builder => $query->whereNotNull('email_verified_at')),
                Filter::make('high_points')
                    ->label('Điểm cao (>1000)')
                    ->query(fn (Builder $query): Builder => $query->where('sport_points', '>', 1000)),
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
                Tables\Actions\ViewAction::make()
                    ->label('Xem'),
                Tables\Actions\EditAction::make()
                    ->label('Sửa'),
                Tables\Actions\Action::make('resetPassword')
                    ->label('Đặt lại MK')
                    ->icon('heroicon-o-key')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->modalHeading('Đặt lại mật khẩu')
                    ->modalDescription('Mật khẩu mới sẽ là "password123". Người dùng nên đổi mật khẩu sau khi đăng nhập.')
                    ->action(fn (User $record) => $record->update(['password' => Hash::make('password123')])),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Xóa đã chọn'),
                ]),
            ])
            ->striped()
            ->poll('60s');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Infolists\Components\Section::make('Thông tin người dùng')
                    ->schema([
                        Infolists\Components\ImageEntry::make('avatar')
                            ->label('Ảnh đại diện')
                            ->circular()
                            ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=10b981&color=fff'),
                        Infolists\Components\TextEntry::make('name')
                            ->label('Họ và tên'),
                        Infolists\Components\TextEntry::make('username')
                            ->label('Tên đăng nhập'),
                        Infolists\Components\TextEntry::make('email')
                            ->label('Email'),
                        Infolists\Components\TextEntry::make('country')
                            ->label('Quốc gia'),
                        Infolists\Components\TextEntry::make('bio')
                            ->label('Giới thiệu'),
                    ])->columns(3),
                Infolists\Components\Section::make('Thống kê')
                    ->schema([
                        Infolists\Components\TextEntry::make('sport_points')
                            ->label('Điểm Sport')
                            ->badge()
                            ->color('success'),
                        Infolists\Components\TextEntry::make('prediction_streak')
                            ->label('Chuỗi thắng')
                            ->badge()
                            ->color('warning'),
                        Infolists\Components\TextEntry::make('predictions_count')
                            ->label('Số dự đoán')
                            ->state(fn ($record) => $record->predictions()->count()),
                    ])->columns(3),
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
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'view' => Pages\ViewUser::route('/{record}'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'email', 'username'];
    }
}
