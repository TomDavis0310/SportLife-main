<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HighlightResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'match_id' => $this->match_id,
            'title' => $this->title,
            'description' => $this->description,
            'provider' => $this->provider,
            'video_url' => $this->video_url,
            'thumbnail_url' => $this->thumbnail_url,
            'duration_seconds' => $this->duration_seconds,
            'published_at' => $this->published_at?->toISOString(),
            'is_featured' => $this->is_featured,
            'view_count' => $this->view_count,
            'meta' => $this->meta ?? [],
            'match' => $this->whenLoaded('match', function () {
                return [
                    'id' => $this->match->id,
                    'status' => $this->match->status,
                    'match_time' => $this->match->match_date?->toISOString(),
                    'competition_name' => $this->match->round?->season?->competition?->name,
                    'home_team' => TeamResource::make($this->match->homeTeam),
                    'away_team' => TeamResource::make($this->match->awayTeam),
                    'score' => [
                        'home' => $this->match->home_score,
                        'away' => $this->match->away_score,
                    ],
                ];
            }),
        ];
    }
}
