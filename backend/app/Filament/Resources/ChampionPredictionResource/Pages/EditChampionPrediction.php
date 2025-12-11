<?php

namespace App\Filament\Resources\ChampionPredictionResource\Pages;

use App\Filament\Resources\ChampionPredictionResource;
use Filament\Resources\Pages\EditRecord;
use Filament\Actions;

class EditChampionPrediction extends EditRecord
{
    protected static string $resource = ChampionPredictionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
