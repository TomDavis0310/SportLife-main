<?php

namespace App\Filament\Resources\RewardRedemptionResource\Pages;

use App\Filament\Resources\RewardRedemptionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewRewardRedemption extends ViewRecord
{
    protected static string $resource = RewardRedemptionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
