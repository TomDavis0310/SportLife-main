<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SeasonChampionResource\Pages;
use App\Models\SeasonChampion;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class SeasonChampionResource extends Resource
{
    protected static ?string $model = SeasonChampion::class;

    protected static ?string $navigationIcon = 'heroicon-o-star';

    protected static ?string $navigationGroup = 'Dự đoán';

    protected static ?string $modelLabel = 'Nhà vô địch';

    protected static ?string $pluralModelLabel = 'Danh sách Vô địch';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin vô địch')
                    ->schema([
                        Forms\Components\Select::make('season_id')
                            ->label('Mùa giải')
                            ->relationship('season', 'name')
                            ->required()
                            ->searchable()
                            ->unique(ignoreRecord: true),
                        Forms\Components\Select::make('champion_team_id')
                            ->label('Đội vô địch')
                            ->relationship('championTeam', 'name')
                            ->required()
                            ->searchable(),
                        Forms\Components\DateTimePicker::make('confirmed_at')
                            ->label('Thời điểm xác nhận')
                            ->default(now()),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('season.competition.name')
                    ->label('Giải đấu')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('season.name')
                    ->label('Mùa giải')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\ImageColumn::make('championTeam.logo_url')
                    ->label('')
                    ->circular()
                    ->size(40),
                Tables\Columns\TextColumn::make('championTeam.name')
                    ->label('Đội vô địch')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('confirmed_at')
                    ->label('Ngày xác nhận')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
                Tables\Actions\Action::make('calculate')
                    ->label('Tính điểm')
                    ->icon('heroicon-o-calculator')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Tính điểm cho tất cả dự đoán')
                    ->modalDescription('Hành động này sẽ tính điểm cho tất cả dự đoán của mùa giải này. Bạn có chắc chắn?')
                    ->action(function (SeasonChampion $record) {
                        $record->calculateAllPredictions();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('confirmed_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSeasonChampions::route('/'),
            'create' => Pages\CreateSeasonChampion::route('/create'),
            'edit' => Pages\EditSeasonChampion::route('/{record}/edit'),
        ];
    }
}
