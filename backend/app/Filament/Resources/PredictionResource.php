<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PredictionResource\Pages;
use App\Models\Prediction;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class PredictionResource extends Resource
{
    protected static ?string $model = Prediction::class;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar';

    protected static ?string $navigationGroup = 'Dự đoán';

    protected static ?string $modelLabel = 'Dự đoán';

    // Ẩn khỏi Admin Panel - người dùng tự quản lý
    protected static bool $shouldRegisterNavigation = false;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết dự đoán')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Người dùng')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('match_id')
                            ->label('Trận đấu')
                            ->relationship('match', 'id')
                            ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->homeTeam->name} vs {$record->awayTeam->name}")
                            ->required()
                            ->searchable(),
                    ])->columns(2),

                Forms\Components\Section::make('Dự đoán tỉ số')
                    ->schema([
                        Forms\Components\TextInput::make('home_score')
                            ->label('Bàn thắng đội nhà')
                            ->numeric()
                            ->minValue(0)
                            ->required(),
                        Forms\Components\TextInput::make('away_score')
                            ->label('Bàn thắng đội khách')
                            ->numeric()
                            ->minValue(0)
                            ->required(),
                        Forms\Components\Select::make('first_scorer_id')
                            ->label('Cầu thủ ghi bàn đầu tiên')
                            ->relationship('firstScorer', 'name')
                            ->searchable()
                            ->preload(),
                        Forms\Components\TextInput::make('streak_multiplier')
                            ->label('Hệ số chuỗi thắng')
                            ->numeric()
                            ->default(1.0)
                            ->disabled(),
                    ])->columns(2),

                Forms\Components\Section::make('Điểm & Kết quả')
                    ->schema([
                        Forms\Components\TextInput::make('points_earned')
                            ->label('Điểm đạt được')
                            ->numeric(),
                        Forms\Components\Toggle::make('is_correct_score')
                            ->label('Tỉ số chính xác'),
                        Forms\Components\Toggle::make('is_correct_winner')
                            ->label('Kết quả thắng/thua đúng'),
                    ])->columns(3),
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
                Tables\Columns\TextColumn::make('match.homeTeam.name')
                    ->label('Trận đấu')
                    ->formatStateUsing(fn ($record) => $record->match ? "{$record->match->homeTeam->short_name} vs {$record->match->awayTeam->short_name}" : ''),
                Tables\Columns\TextColumn::make('home_score')
                    ->label('Dự đoán')
                    ->formatStateUsing(fn ($record) => "{$record->home_score} - {$record->away_score}"),
                Tables\Columns\TextColumn::make('points_earned')
                    ->label('Điểm')
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'success' : 'gray')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_correct_score')
                    ->label('Đúng tỉ số')
                    ->boolean(),
                Tables\Columns\TextColumn::make('streak_multiplier')
                    ->label('Streak')
                    ->formatStateUsing(fn ($state) => "x{$state}"),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('match_id')
                    ->label('Trận đấu')
                    ->relationship('match', 'id')
                    ->getOptionLabelFromRecordUsing(fn ($record) => "{$record->homeTeam->name} vs {$record->awayTeam->name}"),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
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
            'index' => Pages\ListPredictions::route('/'),
        ];
    }
}
