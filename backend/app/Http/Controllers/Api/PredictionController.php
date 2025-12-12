<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PredictionResource;
use App\Http\Resources\LeaderboardResource;
use App\Models\FootballMatch;
use App\Models\Prediction;
use App\Models\PredictionLeaderboard;
use App\Models\Season;
use App\Models\Round;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PredictionController extends Controller
{
    /**
     * Get user's predictions
     */
    public function index(Request $request): JsonResponse
    {
        $predictions = Prediction::where('user_id', $request->user()->id)
            ->with(['match.homeTeam', 'match.awayTeam', 'match.round.season.competition'])
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => PredictionResource::collection($predictions),
            'meta' => [
                'current_page' => $predictions->currentPage(),
                'last_page' => $predictions->lastPage(),
                'total' => $predictions->total(),
            ],
        ]);
    }

    /**
     * Make a prediction
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'match_id' => 'required|exists:matches,id',
            'predicted_outcome' => 'required|in:home,draw,away',
        ]);

        $match = FootballMatch::findOrFail($request->match_id);

        // Check if predictions are still open
        if (!$match->can_predict) {
            return response()->json([
                'success' => false,
                'message' => 'Predictions are closed for this match',
            ], 422);
        }

        // Check if user already predicted
        $existingPrediction = Prediction::where('user_id', $request->user()->id)
            ->where('match_id', $match->id)
            ->first();

        if ($existingPrediction) {
            return response()->json([
                'success' => false,
                'message' => 'You have already made a prediction for this match',
            ], 422);
        }

        // Calculate streak multiplier
        $user = $request->user();
        $streak = $user->prediction_streak ?? 0;
        $multiplier = 1.0;
        if ($streak >= 10) {
            $multiplier = 3.0;
        } elseif ($streak >= 5) {
            $multiplier = 2.0;
        } elseif ($streak >= 3) {
            $multiplier = 1.5;
        }

        $prediction = Prediction::create([
            'user_id' => $user->id,
            'match_id' => $match->id,
            'predicted_outcome' => $request->predicted_outcome,
            'streak_multiplier' => $multiplier,
        ]);

        $prediction->load(['match.homeTeam', 'match.awayTeam']);

        return response()->json([
            'success' => true,
            'message' => 'Prediction submitted successfully',
            'data' => new PredictionResource($prediction),
        ], 201);
    }

    /**
     * Update prediction (only if match hasn't started)
     */
    public function update(Request $request, Prediction $prediction): JsonResponse
    {
        // Check ownership
        if ($prediction->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        // Check if still can edit
        if (!$prediction->match->can_predict) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot edit prediction after match has started',
            ], 422);
        }

        $request->validate([
            'predicted_outcome' => 'required|in:home,draw,away',
        ]);

        $prediction->update([
            'predicted_outcome' => $request->predicted_outcome,
        ]);

        $prediction->load(['match.homeTeam', 'match.awayTeam']);

        return response()->json([
            'success' => true,
            'message' => 'Prediction updated successfully',
            'data' => new PredictionResource($prediction),
        ]);
    }

    /**
     * Get prediction details
     */
    public function show(Prediction $prediction, Request $request): JsonResponse
    {
        // Check if viewing own prediction or it's after match
        if ($prediction->user_id !== $request->user()->id && !$prediction->match->is_finished) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot view other users predictions before match ends',
            ], 403);
        }

        $prediction->load(['match.homeTeam', 'match.awayTeam', 'user']);

        return response()->json([
            'success' => true,
            'data' => new PredictionResource($prediction),
        ]);
    }

    /**
     * Get predictions for a match (after it ends)
     */
    public function matchPredictions(FootballMatch $match, Request $request): JsonResponse
    {
        if (!$match->is_finished) {
            return response()->json([
                'success' => false,
                'message' => 'Predictions are hidden until match ends',
            ], 403);
        }

        $predictions = $match->predictions()
            ->with(['user'])
            ->orderByDesc('points_earned')
            ->paginate(50);

        return response()->json([
            'success' => true,
            'data' => PredictionResource::collection($predictions),
        ]);
    }

    /**
     * Get global leaderboard
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $seasonId = $request->query('season_id');
        $roundId = $request->query('round_id');
        $period = $request->query('period');

        $query = PredictionLeaderboard::with('user');

        if ($period === 'weekly') {
            $currentRound = Round::where('is_current', true)->first();
            if ($currentRound) {
                $query->where('round_id', $currentRound->id)->whereNull('season_id');
            } else {
                // Return empty if no current round found
                return response()->json([
                    'success' => true,
                    'data' => [],
                ]);
            }
        } elseif ($period === 'season') {
            $currentSeason = Season::where('is_current', true)->first();
            if ($currentSeason) {
                $query->where('season_id', $currentSeason->id)->whereNull('round_id');
            } else {
                return response()->json([
                    'success' => true,
                    'data' => [],
                ]);
            }
        } elseif ($roundId) {
            $query->where('round_id', $roundId)->whereNull('season_id');
        } elseif ($seasonId) {
            $query->where('season_id', $seasonId)->whereNull('round_id');
        } else {
            $query->whereNull('season_id')->whereNull('round_id');
        }

        $leaderboard = $query->orderByDesc('total_points')
            ->orderByDesc('correct_scores')
            ->paginate(50);

        return response()->json([
            'success' => true,
            'data' => LeaderboardResource::collection($leaderboard),
        ]);
    }

    /**
     * Get user's rank
     */
    public function myRank(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $seasonId = $request->query('season_id');

        $entry = PredictionLeaderboard::where('user_id', $userId)
            ->when($seasonId, fn ($q) => $q->where('season_id', $seasonId))
            ->when(!$seasonId, fn ($q) => $q->whereNull('season_id'))
            ->whereNull('round_id')
            ->first();

        if (!$entry) {
            return response()->json([
                'success' => true,
                'data' => [
                    'rank' => null,
                    'total_points' => 0,
                    'total_predictions' => 0,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => new LeaderboardResource($entry),
        ]);
    }

    /**
     * Get friends leaderboard
     */
    public function friendsLeaderboard(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get friend IDs
        $friendIds = $user->friendRequestsSent()->accepted()->pluck('friend_id')
            ->merge($user->friendRequestsReceived()->accepted()->pluck('user_id'))
            ->push($user->id)
            ->unique();

        $leaderboard = PredictionLeaderboard::whereIn('user_id', $friendIds)
            ->whereNull('season_id')
            ->whereNull('round_id')
            ->with('user')
            ->orderByDesc('total_points')
            ->get();

        return response()->json([
            'success' => true,
            'data' => LeaderboardResource::collection($leaderboard),
        ]);
    }
}
