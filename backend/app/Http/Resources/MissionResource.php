<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MissionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'type' => $this->type,
            'action_type' => $this->action_type,
            'target_count' => $this->target_count,
            'points_reward' => $this->points_reward,
            'icon' => $this->icon,
            'is_active' => $this->is_active,
        ];
    }
}
