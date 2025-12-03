<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SponsorResource;
use App\Http\Resources\CampaignResource;
use App\Models\Sponsor;
use App\Models\SponsorCampaign;
use App\Models\CampaignInteraction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SponsorController extends Controller
{
    /**
     * List active sponsors
     */
    public function index(): JsonResponse
    {
        $sponsors = Sponsor::active()
            ->withCount('campaigns')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => SponsorResource::collection($sponsors),
        ]);
    }

    /**
     * Show sponsor details
     */
    public function show(Sponsor $sponsor): JsonResponse
    {
        $sponsor->loadCount('campaigns');

        return response()->json([
            'success' => true,
            'data' => new SponsorResource($sponsor),
        ]);
    }

    /**
     * Get sponsor campaigns
     */
    public function campaigns(Sponsor $sponsor): JsonResponse
    {
        $campaigns = $sponsor->campaigns()
            ->active()
            ->orderByDesc('start_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => CampaignResource::collection($campaigns),
        ]);
    }

    /**
     * List all active campaigns
     */
    public function allCampaigns(): JsonResponse
    {
        $campaigns = SponsorCampaign::active()
            ->with('sponsor')
            ->orderByDesc('start_date')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => CampaignResource::collection($campaigns),
        ]);
    }

    /**
     * Show campaign details
     */
    public function campaignDetails(SponsorCampaign $campaign): JsonResponse
    {
        $campaign->load('sponsor');

        return response()->json([
            'success' => true,
            'data' => new CampaignResource($campaign),
        ]);
    }

    /**
     * Interact with a campaign (view, click, participate)
     */
    public function interact(Request $request, SponsorCampaign $campaign): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:view,click,participate,share',
        ]);

        if (!$campaign->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Campaign is not active',
            ], 422);
        }

        $user = $request->user();
        $type = $request->type;

        // Check if already participated (for participate type)
        if ($type === 'participate') {
            $existing = CampaignInteraction::where('campaign_id', $campaign->id)
                ->where('user_id', $user->id)
                ->where('interaction_type', 'participate')
                ->exists();

            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Already participated in this campaign',
                ], 422);
            }
        }

        // Create interaction
        $interaction = CampaignInteraction::create([
            'campaign_id' => $campaign->id,
            'user_id' => $user->id,
            'interaction_type' => $type,
        ]);

        // Award points based on interaction type
        $points = match ($type) {
            'view' => $campaign->view_points ?? 1,
            'click' => $campaign->click_points ?? 2,
            'participate' => $campaign->participate_points ?? 10,
            'share' => $campaign->share_points ?? 5,
            default => 0,
        };

        if ($points > 0) {
            $user->addPoints(
                $points,
                'campaign_interaction',
                "Campaign interaction: {$type}",
                $campaign
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Interaction recorded successfully',
            'data' => [
                'points_earned' => $points,
            ],
        ]);
    }

    /**
     * Get user's campaign interactions
     */
    public function myInteractions(Request $request): JsonResponse
    {
        $interactions = CampaignInteraction::where('user_id', $request->user()->id)
            ->with('campaign.sponsor')
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $interactions,
        ]);
    }
}
