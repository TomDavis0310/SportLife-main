<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BadgeResource;
use App\Models\Badge;
use App\Models\UserBadge;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BadgeController extends Controller
{
    /**
     * List all available badges
     */
    public function index(): JsonResponse
    {
        $badges = Badge::orderBy('category')
            ->orderBy('points_required')
            ->get();

        return response()->json([
            'success' => true,
            'data' => BadgeResource::collection($badges),
        ]);
    }

    /**
     * Get badges by category
     */
    public function byCategory(string $category): JsonResponse
    {
        $badges = Badge::where('category', $category)
            ->orderBy('points_required')
            ->get();

        return response()->json([
            'success' => true,
            'data' => BadgeResource::collection($badges),
        ]);
    }

    /**
     * Get user's earned badges
     */
    public function myBadges(Request $request): JsonResponse
    {
        $userBadges = UserBadge::where('user_id', $request->user()->id)
            ->with('badge')
            ->orderByDesc('earned_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $userBadges,
        ]);
    }

    /**
     * Get user's badge progress
     */
    public function progress(Request $request): JsonResponse
    {
        $user = $request->user();
        $earnedBadgeIds = $user->badges()->pluck('badges.id');

        $allBadges = Badge::all()->map(function ($badge) use ($user, $earnedBadgeIds) {
            $earned = $earnedBadgeIds->contains($badge->id);
            $progress = 0;

            if (!$earned) {
                // Calculate progress based on badge criteria
                $progress = $this->calculateProgress($user, $badge);
            }

            return [
                'badge' => new BadgeResource($badge),
                'earned' => $earned,
                'progress' => $earned ? 100 : $progress,
                'earned_at' => $earned 
                    ? UserBadge::where('user_id', $user->id)
                        ->where('badge_id', $badge->id)
                        ->value('earned_at')
                    : null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $allBadges,
        ]);
    }

    /**
     * Get badge details with unlock criteria
     */
    public function show(Badge $badge, Request $request): JsonResponse
    {
        $user = $request->user();
        $userBadge = UserBadge::where('user_id', $user->id)
            ->where('badge_id', $badge->id)
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'badge' => new BadgeResource($badge),
                'earned' => (bool) $userBadge,
                'earned_at' => $userBadge?->earned_at,
                'progress' => $userBadge ? 100 : $this->calculateProgress($user, $badge),
            ],
        ]);
    }

    /**
     * Calculate progress towards earning a badge
     */
    private function calculateProgress($user, Badge $badge): int
    {
        $criteria = $badge->criteria;
        if (!$criteria) {
            return 0;
        }

        $type = $criteria['type'] ?? null;
        $target = $criteria['count'] ?? 0;

        if (!$type || !$target) {
            return 0;
        }

        $current = match ($type) {
            'predictions_count' => $user->predictions()->count(),
            'correct_predictions' => $user->predictions()->where('points_earned', '>', 0)->count(),
            'perfect_predictions' => $user->predictions()
                ->whereColumn('predicted_home_score', 'home_score')
                ->whereColumn('predicted_away_score', 'away_score')
                ->count(),
            'total_points' => $user->sport_points,
            'login_streak' => $user->login_streak ?? 0,
            'friends_count' => $user->friends()->count(),
            'referrals' => $user->referrals()->count(),
            default => 0,
        };

        return min(100, (int) (($current / $target) * 100));
    }

    /**
     * Get available badge categories
     */
    public function categories(): JsonResponse
    {
        $categories = Badge::distinct('category')
            ->pluck('category')
            ->map(function ($category) {
                return [
                    'name' => $category,
                    'count' => Badge::where('category', $category)->count(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }
}
