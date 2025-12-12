<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BadgeResource\Pages;
use App\Models\Badge;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class BadgeResource extends Resource
{
    protected static ?string $model = Badge::class;

    protected static ?string $navigationIcon = 'heroicon-o-star';

    protected static ?string $navigationGroup = 'Trò chơi hóa';

    protected static ?string $modelLabel = 'Huy hiệu';

    // Ẩn khỏi Admin Panel - hệ thống gamification tự động
    protected static bool $shouldRegisterNavigation = false;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết huy hiệu')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên huy hiệu')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('code')
                            ->label('Mã')
                            ->required()
                            ->maxLength(50)
                            ->unique(ignoreRecord: true),
                        Forms\Components\Select::make('type')
                            ->label('Loại')
                            ->options([
                                'achievement' => 'Thành tích',
                                'milestone' => 'Cột mốc',
                                'special' => 'Đặc biệt',
                            ])
                            ->required(),
                        Forms\Components\Select::make('rarity')
                            ->label('Độ hiếm')
                            ->options([
                                'common' => 'Thường',
                                'uncommon' => 'Không thường',
                                'rare' => 'Hiếm',
                                'epic' => 'Sử thi',
                                'legendary' => 'Huyền thoại',
                            ])
                            ->required(),
                    ])->columns(2),

                Forms\Components\Section::make('Yêu cầu')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả')
                            ->required()
                            ->maxLength(500),
                        Forms\Components\TextInput::make('points_reward')
                            ->label('Điểm thưởng')
                            ->numeric()
                            ->default(0),
                        Forms\Components\KeyValue::make('criteria')
                            ->label('Tiêu chí đạt được')
                            ->helperText('Định nghĩa tiêu chí như: predictions_count => 100'),
                    ]),

                Forms\Components\Section::make('Hình ảnh')
                    ->schema([
                        Forms\Components\FileUpload::make('icon')
                            ->label('Biểu tượng')
                            ->image()
                            ->directory('badges'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('icon')
                    ->label('Biểu tượng')
                    ->square(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên huy hiệu')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('code')
                    ->label('Mã'),
                Tables\Columns\TextColumn::make('type')
                    ->label('Loại')
                    ->badge(),
                Tables\Columns\TextColumn::make('rarity')
                    ->label('Độ hiếm')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'common' => 'gray',
                        'uncommon' => 'success',
                        'rare' => 'info',
                        'epic' => 'warning',
                        'legendary' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('points_reward')
                    ->label('Điểm thưởng')
                    ->sortable(),
                Tables\Columns\TextColumn::make('users_count')
                    ->label('Người đạt được')
                    ->counts('users'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Loại')
                    ->options([
                        'achievement' => 'Thành tích',
                        'milestone' => 'Cột mốc',
                        'special' => 'Đặc biệt',
                    ]),
                Tables\Filters\SelectFilter::make('rarity')
                    ->label('Độ hiếm')
                    ->options([
                        'common' => 'Thường',
                        'uncommon' => 'Không thường',
                        'rare' => 'Hiếm',
                        'epic' => 'Sử thi',
                        'legendary' => 'Huyền thoại',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListBadges::route('/'),
            'create' => Pages\CreateBadge::route('/create'),
            'edit' => Pages\EditBadge::route('/{record}/edit'),
        ];
    }
}
