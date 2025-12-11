<?php

namespace App\Filament\Resources\SeasonChampionResource\Pages;

use App\Filament\Resources\SeasonChampionResource;
use Filament\Resources\Pages\EditRecord;
use Filament\Actions;

class EditSeasonChampion extends EditRecord
{
    protected static string $resource = SeasonChampionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
