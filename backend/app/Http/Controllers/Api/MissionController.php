<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MissionResource;
use App\Models\DailyMission;
use App\Models\UserMission;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

class MissionController extends Controller
{
    /**
     * Get today's missions
     */
    public function today(Request $request): JsonResponse
    {
        $user = $request->user();
        $today = Carbon::today();

        // Get all active daily missions
        $missions = DailyMission::active()
            ->orderBy('points_reward', 'desc')
            ->get();

        // Get user's progress for today
        $userMissions = UserMission::where('user_id', $user->id)
            ->whereDate('date', $today)
            ->get()
            ->keyBy('mission_id');

        $data = $missions->map(function ($mission) use ($userMissions) {
            $userMission = $userMissions->get($mission->id);

            return [
                'mission' => new MissionResource($mission),
                'progress' => $userMission?->progress ?? 0,
                'completed' => $userMission?->is_completed ?? false,
                'claimed' => $userMission?->claimed ?? false,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'meta' => [
                'date' => $today->toDateString(),
                'completed_count' => $userMissions->where('is_completed', true)->count(),
                'total_count' => $missions->count(),
            ],
        ]);
    }

    /**
     * Update mission progress
     */
    public function updateProgress(DailyMission $mission, Request $request): JsonResponse
    {
        $request->validate([
            'progress' => 'required|integer|min:0',
        ]);

        $user = $request->user();
        $today = Carbon::today();

        $userMission = UserMission::firstOrCreate(
            [
                'user_id' => $user->id,
                'mission_id' => $mission->id,
                'date' => $today,
            ],
            [
                'progress' => 0,
                'is_completed' => false,
                'claimed' => false,
            ]
        );

        if ($userMission->is_completed) {
            return response()->json([
                'success' => false,
                'message' => 'Mission already completed',
            ], 422);
        }

        $newProgress = min($request->progress, $mission->target_count);
        $userMission->update([
            'progress' => $newProgress,
            'is_completed' => $newProgress >= $mission->target_count,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'progress' => $newProgress,
                'target' => $mission->target_count,
                'completed' => $userMission->is_completed,
            ],
        ]);
    }

    /**
     * Claim mission reward
     */
    public function claim(DailyMission $mission, Request $request): JsonResponse
    {
        $user = $request->user();
        $today = Carbon::today();

        $userMission = UserMission::where('user_id', $user->id)
            ->where('mission_id', $mission->id)
            ->whereDate('date', $today)
            ->first();

        if (!$userMission) {
            return response()->json([
                'success' => false,
                'message' => 'Mission not found',
            ], 404);
        }

        if (!$userMission->is_completed) {
            return response()->json([
                'success' => false,
                'message' => 'Mission not completed yet',
            ], 422);
        }

        if ($userMission->claimed) {
            return response()->json([
                'success' => false,
                'message' => 'Reward already claimed',
            ], 422);
        }

        // Award points
        $user->addPoints(
            $mission->points_reward,
            'mission',
            "Completed mission: {$mission->name}",
            $mission
        );

        $userMission->update(['claimed' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Reward claimed successfully!',
            'data' => [
                'points_earned' => $mission->points_reward,
                'new_balance' => $user->fresh()->sport_points,
            ],
        ]);
    }

    /**
     * Get mission history
     */
    public function history(Request $request): JsonResponse
    {
        $completedMissions = UserMission::where('user_id', $request->user()->id)
            ->where('is_completed', true)
            ->with('mission')
            ->orderByDesc('date')
            ->paginate(30);

        return response()->json([
            'success' => true,
            'data' => $completedMissions,
        ]);
    }

    /**
     * Get weekly summary
     */
    public function weeklySummary(Request $request): JsonResponse
    {
        $user = $request->user();
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $completedMissions = UserMission::where('user_id', $user->id)
            ->where('is_completed', true)
            ->whereBetween('date', [$startOfWeek, $endOfWeek])
            ->with('mission')
            ->get();

        $totalPoints = $completedMissions->sum(fn($um) => $um->mission->points_reward);

        // Daily breakdown
        $dailyBreakdown = [];
        for ($date = $startOfWeek->copy(); $date <= $endOfWeek; $date->addDay()) {
            $dayMissions = $completedMissions->where('date', $date->toDateString());
            $dailyBreakdown[$date->format('D')] = [
                'completed' => $dayMissions->count(),
                'points' => $dayMissions->sum(fn($um) => $um->mission->points_reward),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_completed' => $completedMissions->count(),
                'total_points' => $totalPoints,
                'daily_breakdown' => $dailyBreakdown,
            ],
        ]);
    }
}
