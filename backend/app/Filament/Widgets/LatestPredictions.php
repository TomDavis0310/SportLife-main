<?php

namespace App\Filament\Widgets;

use App\Models\Prediction;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestPredictions extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?int $sort = 2;

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Prediction::query()
                    ->with(['user', 'match.homeTeam', 'match.awayTeam'])
                    ->latest()
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Người dùng')
                    ->searchable(),
                Tables\Columns\TextColumn::make('match.homeTeam.short_name')
                    ->label('Đội nhà'),
                Tables\Columns\TextColumn::make('predicted_home_score')
                    ->label('Dự đoán')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('predicted_away_score')
                    ->label('Dự đoán')
                    ->alignCenter(),
                Tables\Columns\TextColumn::make('match.awayTeam.short_name')
                    ->label('Đội khách'),
                Tables\Columns\TextColumn::make('points_earned')
                    ->label('Điểm')
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'success' : 'gray'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Thời gian')
                    ->since(),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
