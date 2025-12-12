<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Resource for authenticated user - always includes private fields
 */
class AuthUserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'username' => $this->username,
            'email' => $this->email, // Always include for authenticated user
            'avatar' => $this->avatar_url,
            'sport_points' => $this->sport_points,
            'total_points' => $this->sport_points, // Alias for mobile app compatibility
            'level' => $this->level,
            'level_name' => $this->level_name,
            'rank' => $this->rank,
            'bio' => $this->bio,
            'country' => $this->country,
            'phone' => $this->phone,
            'referral_code' => $this->referral_code,
            'email_verified' => (bool) $this->email_verified_at,
            'roles' => $this->getRoleNames()->toArray(),
            'prediction_streak' => $this->prediction_streak ?? 0,
            'max_prediction_streak' => $this->max_prediction_streak ?? 0,
            'stats' => [
                'predictions_count' => $this->predictions_count ?? $this->predictions()->count(),
                'correct_predictions' => $this->correct_predictions_count ?? 0,
                'badges_count' => $this->badges_count ?? $this->badges()->count(),
                'friends_count' => $this->friends_count ?? 0,
            ],
            'favorite_team' => $this->whenLoaded('favoriteTeam', fn() => [
                'id' => $this->favoriteTeam->id,
                'name' => $this->favoriteTeam->name,
                'logo' => $this->favoriteTeam->logo_url,
            ]),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
