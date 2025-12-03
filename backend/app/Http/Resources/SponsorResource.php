<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SponsorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'logo' => $this->logo_url,
            'website' => $this->website,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'campaigns_count' => $this->campaigns_count ?? 0,
        ];
    }
}
