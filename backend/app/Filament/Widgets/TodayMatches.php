<?php

namespace App\Filament\Widgets;

use App\Enums\MatchStatus;
use App\Models\FootballMatch;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class TodayMatches extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?int $sort = 3;

    public function table(Table $table): Table
    {
        return $table
            ->query(
                FootballMatch::query()
                    ->with(['homeTeam', 'awayTeam', 'round.season.competition'])
                    ->today()
            )
            ->columns([
                Tables\Columns\TextColumn::make('round.season.competition.short_name')
                    ->label('Giải đấu')
                    ->badge(),
                Tables\Columns\TextColumn::make('homeTeam.short_name')
                    ->label('Đội nhà'),
                Tables\Columns\TextColumn::make('home_score')
                    ->label('Tỉ số')
                    ->alignCenter()
                    ->formatStateUsing(fn ($record) => 
                        $record->home_score !== null 
                            ? "{$record->home_score} - {$record->away_score}" 
                            : 'vs'
                    ),
                Tables\Columns\TextColumn::make('awayTeam.short_name')
                    ->label('Đội khách'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->formatStateUsing(function ($state) {
                        $status = $state instanceof MatchStatus
                            ? $state
                            : MatchStatus::tryFrom($state);

                        return $status?->label() ?? 'Không xác định';
                    })
                    ->color(function ($state) {
                        $status = $state instanceof MatchStatus
                            ? $state
                            : MatchStatus::tryFrom($state);

                        return $status?->color() ?? 'gray';
                    }),
                Tables\Columns\TextColumn::make('match_date')
                    ->label('Giờ thi đấu')
                    ->dateTime('H:i'),
            ])
            ->defaultSort('match_date');
    }
}
