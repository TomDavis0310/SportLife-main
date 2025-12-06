<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DailyMissionResource\Pages;
use App\Models\DailyMission;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class DailyMissionResource extends Resource
{
    protected static ?string $model = DailyMission::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-check';

    protected static ?string $navigationGroup = 'Trò chơi hóa';

    protected static ?string $modelLabel = 'Nhiệm vụ hàng ngày';

    // Ẩn khỏi Admin Panel - hệ thống gamification tự động
    protected static bool $shouldRegisterNavigation = false;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết nhiệm vụ')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên nhiệm vụ')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('code')
                            ->label('Mã')
                            ->required()
                            ->maxLength(50)
                            ->unique(ignoreRecord: true),
                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả')
                            ->required()
                            ->maxLength(500),
                    ]),

                Forms\Components\Section::make('Yêu cầu')
                    ->schema([
                        Forms\Components\Select::make('action_type')
                            ->label('Loại hành động')
                            ->options([
                                'prediction' => 'Dự đoán',
                                'exact_prediction' => 'Dự đoán tỉ số chính xác',
                                'share' => 'Chia sẻ nội dung',
                                'comment' => 'Viết bình luận',
                                'read_news' => 'Đọc tin tức',
                                'watch_video' => 'Xem video',
                                'invite_friend' => 'Mời bạn bè',
                                'streak' => 'Chuỗi đăng nhập',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('target_count')
                            ->label('Số lượng mục tiêu')
                            ->numeric()
                            ->required()
                            ->minValue(1)
                            ->default(1),
                        Forms\Components\TextInput::make('points_reward')
                            ->label('Điểm thưởng')
                            ->numeric()
                            ->required()
                            ->minValue(1),
                    ])->columns(3),

                Forms\Components\Section::make('Trạng thái')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label('Kích hoạt')
                            ->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên nhiệm vụ')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('code')
                    ->label('Mã'),
                Tables\Columns\TextColumn::make('action_type')
                    ->label('Loại hành động')
                    ->badge(),
                Tables\Columns\TextColumn::make('target_count')
                    ->label('Mục tiêu'),
                Tables\Columns\TextColumn::make('points_reward')
                    ->label('Điểm thưởng')
                    ->badge()
                    ->color('success'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Kích hoạt')
                    ->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('action_type')
                    ->label('Loại hành động')
                    ->options([
                        'prediction' => 'Dự đoán',
                        'exact_prediction' => 'Dự đoán tỉ số chính xác',
                        'share' => 'Chia sẻ nội dung',
                        'comment' => 'Viết bình luận',
                        'read_news' => 'Đọc tin tức',
                        'watch_video' => 'Xem video',
                        'invite_friend' => 'Mời bạn bè',
                        'streak' => 'Chuỗi đăng nhập',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active'),
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
            'index' => Pages\ListDailyMissions::route('/'),
            'create' => Pages\CreateDailyMission::route('/create'),
            'edit' => Pages\EditDailyMission::route('/{record}/edit'),
        ];
    }
}
