<?php

namespace App\Filament\Resources\ChampionPredictionResource\Pages;

use App\Filament\Resources\ChampionPredictionResource;
use Filament\Resources\Pages\ListRecords;
use Filament\Actions;

class ListChampionPredictions extends ListRecords
{
    protected static string $resource = ChampionPredictionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
