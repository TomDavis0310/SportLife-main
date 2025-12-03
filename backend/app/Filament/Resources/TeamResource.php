<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamResource\Pages;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class TeamResource extends Resource
{
    protected static ?string $model = Team::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationGroup = 'Bóng đá';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin đội bóng')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên đội')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('short_name')
                            ->label('Tên viết tắt')
                            ->required()
                            ->maxLength(10),
                        Forms\Components\TextInput::make('code')
                            ->label('Mã đội')
                            ->required()
                            ->maxLength(3),
                        Forms\Components\Select::make('competition_id')
                            ->label('Giải đấu')
                            ->relationship('competition', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                    ])->columns(2),

                Forms\Components\Section::make('Chi tiết')
                    ->schema([
                        Forms\Components\TextInput::make('city')
                            ->label('Thành phố')
                            ->maxLength(100),
                        Forms\Components\TextInput::make('country')
                            ->label('Quốc gia')
                            ->maxLength(100),
                        Forms\Components\TextInput::make('stadium')
                            ->label('Sân vận động')
                            ->maxLength(255),
                        Forms\Components\TextInput::make('stadium_capacity')
                            ->numeric(),
                        Forms\Components\TextInput::make('founded')
                            ->numeric()
                            ->minValue(1800)
                            ->maxValue(now()->year),
                        Forms\Components\TextInput::make('manager')
                            ->maxLength(255),
                    ])->columns(3),

                Forms\Components\Section::make('Media')
                    ->schema([
                        Forms\Components\FileUpload::make('logo')
                            ->image()
                            ->directory('teams'),
                        Forms\Components\ColorPicker::make('primary_color'),
                        Forms\Components\ColorPicker::make('secondary_color'),
                    ])->columns(3),

                Forms\Components\Section::make('External')
                    ->schema([
                        Forms\Components\TextInput::make('external_id')
                            ->label('API Football ID'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->square(),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('short_name'),
                Tables\Columns\TextColumn::make('code'),
                Tables\Columns\TextColumn::make('competition.name')
                    ->label('Competition'),
                Tables\Columns\TextColumn::make('city'),
                Tables\Columns\TextColumn::make('stadium'),
                Tables\Columns\TextColumn::make('players_count')
                    ->label('Players')
                    ->counts('players'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('competition')
                    ->relationship('competition', 'name'),
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
            'index' => Pages\ListTeams::route('/'),
            'create' => Pages\CreateTeam::route('/create'),
            'edit' => Pages\EditTeam::route('/{record}/edit'),
        ];
    }
}
