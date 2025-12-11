<?php

namespace App\Filament\Resources\SeasonChampionResource\Pages;

use App\Filament\Resources\SeasonChampionResource;
use Filament\Resources\Pages\ListRecords;
use Filament\Actions;

class ListSeasonChampions extends ListRecords
{
    protected static string $resource = SeasonChampionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
