<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BadgeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'icon' => $this->icon_url,
            'category' => $this->category,
            'points_required' => $this->points_required,
            'criteria' => $this->criteria,
            'is_rare' => $this->is_rare ?? false,
        ];
    }
}
