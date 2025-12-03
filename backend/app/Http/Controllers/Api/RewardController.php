<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\RewardResource;
use App\Http\Resources\RedemptionResource;
use App\Models\Reward;
use App\Models\RewardRedemption;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RewardController extends Controller
{
    /**
     * List available rewards
     */
    public function index(Request $request): JsonResponse
    {
        $rewards = Reward::available()
            ->with('sponsor')
            ->orderBy('points_required')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => RewardResource::collection($rewards),
            'meta' => [
                'current_page' => $rewards->currentPage(),
                'last_page' => $rewards->lastPage(),
                'total' => $rewards->total(),
            ],
        ]);
    }

    /**
     * Show reward details
     */
    public function show(Reward $reward): JsonResponse
    {
        $reward->load('sponsor');

        return response()->json([
            'success' => true,
            'data' => new RewardResource($reward),
        ]);
    }

    /**
     * Redeem a reward
     */
    public function redeem(Request $request, Reward $reward): JsonResponse
    {
        // Check if reward is available
        if (!$reward->is_available) {
            return response()->json([
                'success' => false,
                'message' => 'This reward is no longer available',
            ], 422);
        }

        $user = $request->user();

        // Check if user has enough points
        if ($user->sport_points < $reward->points_required) {
            return response()->json([
                'success' => false,
                'message' => 'Not enough SportPoints',
                'data' => [
                    'required' => $reward->points_required,
                    'current' => $user->sport_points,
                ],
            ], 422);
        }

        // Validate shipping info for physical rewards
        if ($reward->is_physical) {
            $request->validate([
                'shipping_name' => 'required|string|max:255',
                'shipping_phone' => 'required|string|max:20',
                'shipping_address' => 'required|string|max:500',
            ]);
        }

        // Deduct points
        $user->deductPoints(
            $reward->points_required,
            'redemption',
            "Redeemed: {$reward->name}",
            $reward
        );

        // Decrease stock
        $reward->decrement('stock');

        // Generate voucher code if applicable
        $voucherCode = $reward->type === 'voucher' ? $reward->generateVoucherCode() : null;

        // Create redemption record
        $redemption = RewardRedemption::create([
            'user_id' => $user->id,
            'reward_id' => $reward->id,
            'voucher_code' => $voucherCode,
            'points_spent' => $reward->points_required,
            'status' => 'pending',
            'shipping_name' => $request->shipping_name,
            'shipping_phone' => $request->shipping_phone,
            'shipping_address' => $request->shipping_address,
        ]);

        $redemption->load('reward');

        return response()->json([
            'success' => true,
            'message' => 'Reward redeemed successfully!',
            'data' => new RedemptionResource($redemption),
        ], 201);
    }

    /**
     * Get user's redemption history
     */
    public function history(Request $request): JsonResponse
    {
        $redemptions = RewardRedemption::where('user_id', $request->user()->id)
            ->with('reward')
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => RedemptionResource::collection($redemptions),
        ]);
    }

    /**
     * Get redemption details
     */
    public function redemptionDetails(RewardRedemption $redemption, Request $request): JsonResponse
    {
        if ($redemption->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $redemption->load('reward');

        return response()->json([
            'success' => true,
            'data' => new RedemptionResource($redemption),
        ]);
    }
}
