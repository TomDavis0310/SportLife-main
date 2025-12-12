<?php

namespace App\Filament\Resources;

use App\Enums\PlayerPosition;
use App\Filament\Resources\PlayerResource\Pages;
use App\Models\Player;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class PlayerResource extends Resource
{
    protected static ?string $model = Player::class;

    protected static ?string $navigationIcon = 'heroicon-o-user';

    protected static ?string $navigationGroup = 'Bóng đá';

    // Ẩn khỏi Admin Panel - để Club Manager quản lý
    protected static bool $shouldRegisterNavigation = false;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin cầu thủ')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên cầu thủ')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('team_id')
                            ->label('Đội bóng')
                            ->relationship('team', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\TextInput::make('jersey_number')
                            ->label('Số áo')
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(99),
                        Forms\Components\Select::make('position')
                            ->label('Vị trí')
                            ->options(PlayerPosition::class)
                            ->required(),
                    ])->columns(2),

                Forms\Components\Section::make('Chi tiết cá nhân')
                    ->schema([
                        Forms\Components\TextInput::make('nationality')
                            ->label('Quốc tịch')
                            ->maxLength(100),
                        Forms\Components\DatePicker::make('date_of_birth')
                            ->label('Ngày sinh'),
                        Forms\Components\TextInput::make('height')
                            ->label('Chiều cao')
                            ->numeric()
                            ->suffix('cm'),
                        Forms\Components\TextInput::make('weight')
                            ->label('Cân nặng')
                            ->numeric()
                            ->suffix('kg'),
                        Forms\Components\TextInput::make('market_value')
                            ->label('Giá trị chuyển nhượng')
                            ->numeric()
                            ->prefix('€'),
                    ])->columns(3),

                Forms\Components\Section::make('Hình ảnh')
                    ->schema([
                        Forms\Components\FileUpload::make('photo')
                            ->label('Ảnh đại diện')
                            ->image()
                            ->directory('players'),
                    ]),

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
                Tables\Columns\ImageColumn::make('photo')
                    ->label('Ảnh')
                    ->circular(),
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên cầu thủ')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('jersey_number')
                    ->label('Số áo'),
                Tables\Columns\TextColumn::make('position')
                    ->label('Vị trí')
                    ->badge(),
                Tables\Columns\TextColumn::make('team.name')
                    ->label('Đội bóng'),
                Tables\Columns\TextColumn::make('nationality')
                    ->label('Quốc tịch'),
                Tables\Columns\TextColumn::make('date_of_birth')
                    ->label('Ngày sinh')
                    ->date(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('team')
                    ->label('Đội bóng')
                    ->relationship('team', 'name'),
                Tables\Filters\SelectFilter::make('position')
                    ->label('Vị trí')
                    ->options(PlayerPosition::class),
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
            'index' => Pages\ListPlayers::route('/'),
            'create' => Pages\CreatePlayer::route('/create'),
            'edit' => Pages\EditPlayer::route('/{record}/edit'),
        ];
    }
}
