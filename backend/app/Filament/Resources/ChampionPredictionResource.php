<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChampionPredictionResource\Pages;
use App\Models\ChampionPrediction;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ChampionPredictionResource extends Resource
{
    protected static ?string $model = ChampionPrediction::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';

    protected static ?string $navigationGroup = 'Dự đoán';

    protected static ?string $modelLabel = 'Dự đoán Vô địch';

    protected static ?string $pluralModelLabel = 'Dự đoán Vô địch';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin dự đoán')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('Người dùng')
                            ->relationship('user', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('season_id')
                            ->label('Mùa giải')
                            ->relationship('season', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\Select::make('predicted_team_id')
                            ->label('Đội dự đoán')
                            ->relationship('predictedTeam', 'name')
                            ->required()
                            ->searchable(),
                    ])->columns(3),

                Forms\Components\Section::make('Chi tiết dự đoán')
                    ->schema([
                        Forms\Components\Textarea::make('reason')
                            ->label('Lý do')
                            ->maxLength(500),
                        Forms\Components\TextInput::make('confidence_level')
                            ->label('Độ tự tin (%)')
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(100)
                            ->default(50),
                        Forms\Components\TextInput::make('points_wagered')
                            ->label('Điểm đặt cược')
                            ->numeric()
                            ->minValue(10)
                            ->maxValue(1000)
                            ->default(100),
                    ])->columns(3),

                Forms\Components\Section::make('Kết quả')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Trạng thái')
                            ->options([
                                'pending' => 'Đang chờ',
                                'won' => 'Thắng',
                                'lost' => 'Thua',
                            ])
                            ->default('pending'),
                        Forms\Components\TextInput::make('points_earned')
                            ->label('Điểm nhận được')
                            ->numeric()
                            ->default(0),
                        Forms\Components\DateTimePicker::make('calculated_at')
                            ->label('Thời điểm tính điểm'),
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
                Tables\Columns\TextColumn::make('season.name')
                    ->label('Mùa giải')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('predictedTeam.name')
                    ->label('Đội dự đoán')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('confidence_level')
                    ->label('Độ tự tin')
                    ->suffix('%')
                    ->sortable(),
                Tables\Columns\TextColumn::make('points_wagered')
                    ->label('Điểm cược')
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'won' => 'success',
                        'lost' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => 'Đang chờ',
                        'won' => 'Thắng',
                        'lost' => 'Thua',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('points_earned')
                    ->label('Điểm nhận')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Trạng thái')
                    ->options([
                        'pending' => 'Đang chờ',
                        'won' => 'Thắng',
                        'lost' => 'Thua',
                    ]),
                Tables\Filters\SelectFilter::make('season_id')
                    ->label('Mùa giải')
                    ->relationship('season', 'name'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChampionPredictions::route('/'),
            'create' => Pages\CreateChampionPrediction::route('/create'),
            'edit' => Pages\EditChampionPrediction::route('/{record}/edit'),
        ];
    }
}
