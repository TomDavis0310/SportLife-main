<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MatchResource\Pages;
use App\Models\FootballMatch;
use App\Enums\MatchStatus;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class MatchResource extends Resource
{
    protected static ?string $model = FootballMatch::class;

    protected static ?string $navigationIcon = 'heroicon-o-play';

    protected static ?string $navigationGroup = 'Bóng đá';

    protected static ?string $modelLabel = 'Trận đấu';

    // Hiện CRUD trận đấu trên Admin Panel
    protected static bool $shouldRegisterNavigation = true;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Chi tiết trận đấu')
                    ->schema([
                        Forms\Components\Select::make('round_id')
                            ->label('Vòng đấu')
                            ->relationship('round', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('home_team_id')
                            ->label('Đội nhà')
                            ->relationship('homeTeam', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('away_team_id')
                            ->label('Đội khách')
                            ->relationship('awayTeam', 'name')
                            ->required()
                            ->searchable()
                            ->preload(),
                        Forms\Components\DateTimePicker::make('match_date')
                            ->label('Ngày thi đấu')
                            ->required(),
                        Forms\Components\TextInput::make('venue')
                            ->label('Sân vận động')
                            ->maxLength(255),
                    ])->columns(2),

                Forms\Components\Section::make('Tỉ số')
                    ->schema([
                        Forms\Components\TextInput::make('home_score')
                            ->label('Bàn thắng đội nhà')
                            ->numeric()
                            ->minValue(0),
                        Forms\Components\TextInput::make('away_score')
                            ->label('Bàn thắng đội khách')
                            ->numeric()
                            ->minValue(0),
                        Forms\Components\TextInput::make('home_score_ht')
                            ->label('Bàn thắng đội nhà (H1)')
                            ->numeric()
                            ->minValue(0),
                        Forms\Components\TextInput::make('away_score_ht')
                            ->label('Bàn thắng đội khách (H1)')
                            ->numeric()
                            ->minValue(0),
                    ])->columns(4),

                Forms\Components\Section::make('Trạng thái')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->label('Trạng thái')
                            ->options(MatchStatus::options())
                            ->required(),
                        Forms\Components\TextInput::make('minute')
                            ->label('Phút')
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(120),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('round.season.competition.short_name')
                    ->label('Giải đấu')
                    ->badge(),
                Tables\Columns\TextColumn::make('homeTeam.short_name')
                    ->label('Đội nhà'),
                Tables\Columns\TextColumn::make('score')
                    ->label('Tỉ số')
                    ->getStateUsing(fn ($record) => 
                        $record->home_score !== null 
                            ? "{$record->home_score} - {$record->away_score}" 
                            : 'vs'
                    )
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('awayTeam.short_name')
                    ->label('Đội khách'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(function ($state) {
                        if ($state instanceof MatchStatus) {
                            return $state->label();
                        }

                        return MatchStatus::tryFrom($state)?->label() ?? (string) $state;
                    })
                    ->color(function ($state) {
                        $value = $state instanceof MatchStatus ? $state->value : $state;

                        return match ($value) {
                            MatchStatus::LIVE->value,
                            MatchStatus::FIRST_HALF->value,
                            MatchStatus::SECOND_HALF->value => 'danger',
                            MatchStatus::EXTRA_TIME->value,
                            MatchStatus::PENALTIES->value => 'primary',
                            MatchStatus::HALFTIME->value => 'warning',
                            MatchStatus::FINISHED->value => 'success',
                            MatchStatus::POSTPONED->value => 'warning',
                            MatchStatus::CANCELLED->value => 'danger',
                            default => 'gray',
                        };
                    }),
                Tables\Columns\TextColumn::make('match_date')
                    ->label('Ngày thi đấu')
                    ->dateTime('d/m H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('venue')
                    ->label('Sân vận động')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('match_date', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Trạng thái')
                    ->options(MatchStatus::options()),
                Tables\Filters\SelectFilter::make('round.season.competition')
                    ->label('Giải đấu')
                    ->relationship('round.season.competition', 'name'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('liveUpdate')
                    ->label('Cập nhật trực tiếp')
                    ->icon('heroicon-o-play')
                    ->color('danger')
                    ->url(fn ($record) => route('filament.admin.resources.matches.live', $record)),
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
            'index' => Pages\ListMatches::route('/'),
            'create' => Pages\CreateMatch::route('/create'),
            'edit' => Pages\EditMatch::route('/{record}/edit'),
            'live' => Pages\LiveUpdateMatch::route('/{record}/live'),
        ];
    }
}
