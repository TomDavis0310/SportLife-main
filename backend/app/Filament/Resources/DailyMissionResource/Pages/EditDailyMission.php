<?php

namespace App\Filament\Resources\DailyMissionResource\Pages;

use App\Filament\Resources\DailyMissionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDailyMission extends EditRecord
{
    protected static string $resource = DailyMissionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
