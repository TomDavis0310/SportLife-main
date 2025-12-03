<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AuthUserResource;
use App\Http\Resources\UserResource;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * Get user profile
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'favoriteTeam',
            'managedTeam',
            'badges.badge',
        ]);

        return response()->json([
            'success' => true,
            'data' => new AuthUserResource($user),
        ]);
    }

    /**
     * Update profile
     */
    public function update(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string|max:20',
            'favorite_team_id' => 'nullable|exists:teams,id',
        ]);

        $user = $request->user();
        $user->update($request->only(['name', 'phone', 'favorite_team_id']));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => new AuthUserResource($user->load(['favoriteTeam'])),
        ]);
    }

    /**
     * Update avatar
     */
    public function updateAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $user = $request->user();

        // Use Media Library
        $user->addMediaFromRequest('avatar')
            ->toMediaCollection('avatar');

        return response()->json([
            'success' => true,
            'message' => 'Avatar updated successfully',
            'data' => [
                'avatar_url' => $user->getFirstMediaUrl('avatar'),
            ],
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->password)]);

        // Revoke all tokens except current
        $user->tokens()->where('id', '!=', $user->currentAccessToken()->id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully',
        ]);
    }

    /**
     * Get point history
     */
    public function pointHistory(Request $request): JsonResponse
    {
        $transactions = $request->user()
            ->pointTransactions()
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $transactions,
        ]);
    }

    /**
     * Get user statistics
     */
    public function statistics(Request $request): JsonResponse
    {
        $user = $request->user();

        $predictions = $user->predictions();
        $calculatedPredictions = $predictions->clone()->whereNotNull('calculated_at');

        $stats = [
            'total_points' => $user->sport_points,
            'current_streak' => $user->prediction_streak,
            'max_streak' => $user->max_prediction_streak,
            'total_predictions' => $predictions->count(),
            'correct_scores' => $calculatedPredictions->where('is_correct_score', true)->count(),
            'correct_winners' => $calculatedPredictions->where('is_correct_winner', true)->count(),
            'correct_differences' => $calculatedPredictions->where('is_correct_difference', true)->count(),
            'badges_count' => $user->badges()->count(),
            'friends_count' => $user->friendRequestsSent()->accepted()->count() +
                $user->friendRequestsReceived()->accepted()->count(),
            'referrals_count' => $user->referrals()->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
        ]);
    }

    /**
     * Get user badges
     */
    public function badges(Request $request): JsonResponse
    {
        $badges = $request->user()
            ->badges()
            ->with('badge')
            ->orderByDesc('earned_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $badges,
        ]);
    }

    /**
     * Delete account
     */
    public function destroy(Request $request): JsonResponse
    {
        $request->validate([
            'password' => 'required|string',
        ]);

        $user = $request->user();

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password is incorrect',
            ], 422);
        }

        // Delete all tokens
        $user->tokens()->delete();

        // Soft delete or permanently delete
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Account deleted successfully',
        ]);
    }
}
