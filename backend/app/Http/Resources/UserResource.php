<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            // 'username' => $this->username, // Removed as column does not exist
            'email' => $this->when($this->isCurrentUser($request), $this->email),
            'avatar' => $this->avatar_url,
            'sport_points' => $this->sport_points,
            'total_points' => $this->sport_points,
            'level' => $this->level,
            'level_name' => $this->level_name,
            'rank' => $this->rank,
            'bio' => $this->bio,
            'country' => $this->country,
            'referral_code' => $this->when($this->isCurrentUser($request), $this->referral_code),
            'email_verified' => $this->when($this->isCurrentUser($request), (bool) $this->email_verified_at),
            'stats' => $this->when($request->routeIs('profile.*'), [
                'predictions_count' => $this->predictions_count ?? $this->predictions()->count(),
                'correct_predictions' => $this->correct_predictions_count ?? 0,
                'badges_count' => $this->badges_count ?? $this->badges()->count(),
                'friends_count' => $this->friends_count ?? 0,
            ]),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }

    private function isCurrentUser(Request $request): bool
    {
        return $request->user()?->id === $this->id;
    }
}
