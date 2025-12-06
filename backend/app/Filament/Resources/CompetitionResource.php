<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CompetitionResource\Pages;
use App\Models\Competition;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CompetitionResource extends Resource
{
    protected static ?string $model = Competition::class;

    protected static ?string $navigationIcon = 'heroicon-o-trophy';

    protected static ?string $navigationGroup = 'Bóng đá';

    // Ẩn khỏi Admin Panel - để Club Manager quản lý
    protected static bool $shouldRegisterNavigation = false;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết giải đấu')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên giải đấu')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('code')
                            ->label('Mã giải đấu')
                            ->required()
                            ->maxLength(10),
                        Forms\Components\Select::make('type')
                            ->label('Loại giải đấu')
                            ->options([
                                'league' => 'Giải vô địch',
                                'cup' => 'Cúp',
                                'super_cup' => 'Siêu cúp',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('country')
                            ->label('Quốc gia')
                            ->maxLength(100),
                    ])->columns(2),

                Forms\Components\Section::make('Hình ảnh')
                    ->schema([
                        Forms\Components\FileUpload::make('logo')
                            ->label('Logo')
                            ->image()
                            ->directory('competitions'),
                        Forms\Components\FileUpload::make('flag')
                            ->label('Cờ')
                            ->image()
                            ->directory('competitions/flags'),
                    ])->columns(2),

                Forms\Components\Section::make('Mở rộng')
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
                    ->label('Logo')
                    ->square(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên giải đấu')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('code')
                    ->label('Mã'),
                Tables\Columns\TextColumn::make('type')
                    ->label('Loại')
                    ->badge(),
                Tables\Columns\TextColumn::make('country')
                    ->label('Quốc gia'),
                Tables\Columns\TextColumn::make('teams_count')
                    ->label('Số đội')
                    ->counts('teams'),
                Tables\Columns\TextColumn::make('seasons_count')
                    ->label('Số mùa giải')
                    ->counts('seasons'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Loại')
                    ->options([
                        'league' => 'Giải vô địch',
                        'cup' => 'Cúp',
                        'super_cup' => 'Siêu cúp',
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
            'index' => Pages\ListCompetitions::route('/'),
            'create' => Pages\CreateCompetition::route('/create'),
            'edit' => Pages\EditCompetition::route('/{record}/edit'),
        ];
    }
}
