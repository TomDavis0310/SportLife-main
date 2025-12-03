<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeamResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'short_name' => $this->short_name,
            'logo' => $this->logo_url,
            'country' => $this->country,
            'city' => $this->city,
            'stadium' => $this->stadium,
            'founded_year' => $this->founded_year,
            'primary_color' => $this->primary_color,
            'secondary_color' => $this->secondary_color,
            'colors' => $this->colors,
            'website' => $this->website,
            'players_count' => $this->when(isset($this->players_count), $this->players_count),
        ];
    }
}
