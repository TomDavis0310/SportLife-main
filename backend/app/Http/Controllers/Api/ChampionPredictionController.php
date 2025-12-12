<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ChampionPredictionResource;
use App\Http\Resources\ChampionPredictionLeaderboardResource;
use App\Http\Resources\SeasonChampionResource;
use App\Http\Resources\TeamResource;
use App\Models\ChampionPrediction;
use App\Models\ChampionPredictionLeaderboard;
use App\Models\SeasonChampion;
use App\Models\Season;
use App\Models\Standing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChampionPredictionController extends Controller
{
    /**
     * Get available seasons for champion prediction
     */
    public function availableSeasons(): JsonResponse
    {
        $seasons = Season::where('is_current', true)
            ->orWhere('end_date', '>=', now())
            ->with(['competition', 'teams'])
            ->orderByDesc('start_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $seasons->map(function ($season) {
                return [
                    'id' => $season->id,
                    'name' => $season->name,
                    'competition' => [
                        'id' => $season->competition->id,
                        'name' => $season->competition->name,
                        'short_name' => $season->competition->short_name,
                        'logo_url' => $season->competition->logo_url,
                    ],
                    'start_date' => $season->start_date?->toISOString(),
                    'end_date' => $season->end_date?->toISOString(),
                    'is_current' => $season->is_current,
                    'teams_count' => $season->teams->count(),
                    'can_predict' => $season->end_date?->isFuture() ?? true,
                ];
            }),
        ]);
    }

    /**
     * Get teams in a season with their current standings
     */
    public function seasonTeams(Season $season): JsonResponse
    {
        $teams = $season->teams()
            ->with(['standings' => function ($q) use ($season) {
                $q->where('season_id', $season->id);
            }])
            ->get();

        // Get prediction stats for each team
        $predictionStats = ChampionPrediction::where('season_id', $season->id)
            ->selectRaw('predicted_team_id, COUNT(*) as prediction_count')
            ->groupBy('predicted_team_id')
            ->pluck('prediction_count', 'predicted_team_id');

        $totalPredictions = $predictionStats->sum();

        $teamsData = $teams->map(function ($team) use ($season, $predictionStats, $totalPredictions) {
            $standing = $team->standings->first();
            $predCount = $predictionStats[$team->id] ?? 0;

            return [
                'id' => $team->id,
                'name' => $team->name,
                'short_name' => $team->short_name,
                'logo_url' => $team->logo_url,
                'standing' => $standing ? [
                    'position' => $standing->position,
                    'points' => $standing->points,
                    'played' => $standing->played,
                    'won' => $standing->won,
                    'drawn' => $standing->drawn,
                    'lost' => $standing->lost,
                    'goals_for' => $standing->goals_for,
                    'goals_against' => $standing->goals_against,
                    'goal_difference' => $standing->goal_difference,
                ] : null,
                'prediction_stats' => [
                    'count' => $predCount,
                    'percentage' => $totalPredictions > 0 
                        ? round(($predCount / $totalPredictions) * 100, 1) 
                        : 0,
                ],
            ];
        });

        // Sort by standing position
        $teamsData = $teamsData->sortBy(function ($team) {
            return $team['standing']['position'] ?? 999;
        })->values();

        return response()->json([
            'success' => true,
            'data' => [
                'season' => [
                    'id' => $season->id,
                    'name' => $season->name,
                    'competition_name' => $season->competition->name,
                    'end_date' => $season->end_date?->toISOString(),
                    'can_predict' => $season->end_date?->isFuture() ?? true,
                ],
                'teams' => $teamsData,
                'total_predictions' => $totalPredictions,
            ],
        ]);
    }

    /**
     * Get user's champion predictions
     */
    public function myPredictions(Request $request): JsonResponse
    {
        $predictions = ChampionPrediction::where('user_id', $request->user()->id)
            ->with(['season.competition', 'predictedTeam'])
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => ChampionPredictionResource::collection($predictions),
        ]);
    }

    /**
     * Get user's prediction for a specific season
     */
    public function mySeasonPrediction(Season $season, Request $request): JsonResponse
    {
        $prediction = ChampionPrediction::where('user_id', $request->user()->id)
            ->where('season_id', $season->id)
            ->with(['season.competition', 'predictedTeam'])
            ->first();

        if (!$prediction) {
            return response()->json([
                'success' => true,
                'data' => null,
                'message' => 'No prediction found for this season',
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => new ChampionPredictionResource($prediction),
        ]);
    }

    /**
     * Make a champion prediction
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'season_id' => 'required|exists:seasons,id',
            'predicted_team_id' => 'required|exists:teams,id',
            'reason' => 'nullable|string|max:500',
            'confidence_level' => 'required|integer|min:1|max:100',
            'points_wagered' => 'required|integer|min:10|max:1000',
        ]);

        $user = $request->user();
        $season = Season::findOrFail($request->season_id);

        // Check if season is still open for predictions
        if ($season->end_date && $season->end_date->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Mùa giải đã kết thúc, không thể dự đoán',
            ], 422);
        }

        // Check if user already predicted for this season
        $existingPrediction = ChampionPrediction::where('user_id', $user->id)
            ->where('season_id', $season->id)
            ->first();

        if ($existingPrediction) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn đã dự đoán cho mùa giải này rồi',
            ], 422);
        }

        // Check if team is in the season
        if (!$season->teams()->where('teams.id', $request->predicted_team_id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Đội bóng không tham gia mùa giải này',
            ], 422);
        }

        // Check if user has enough points
        if ($user->sport_points < $request->points_wagered) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có đủ điểm để đặt cược',
            ], 422);
        }

        // Deduct points
        $user->deductPoints($request->points_wagered, 'champion_prediction', 
            "Dự đoán đội vô địch mùa giải {$season->name}");

        $prediction = ChampionPrediction::create([
            'user_id' => $user->id,
            'season_id' => $season->id,
            'predicted_team_id' => $request->predicted_team_id,
            'reason' => $request->reason,
            'confidence_level' => $request->confidence_level,
            'points_wagered' => $request->points_wagered,
        ]);

        $prediction->load(['season.competition', 'predictedTeam']);

        return response()->json([
            'success' => true,
            'message' => 'Dự đoán đã được ghi nhận thành công',
            'data' => new ChampionPredictionResource($prediction),
        ], 201);
    }

    /**
     * Update prediction (only if season hasn't ended)
     */
    public function update(Request $request, ChampionPrediction $championPrediction): JsonResponse
    {
        // Check ownership
        if ($championPrediction->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        // Check if season is still open
        if ($championPrediction->season->end_date?->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'Mùa giải đã kết thúc, không thể thay đổi dự đoán',
            ], 422);
        }

        // Check if already calculated
        if ($championPrediction->calculated_at) {
            return response()->json([
                'success' => false,
                'message' => 'Dự đoán đã được tính điểm, không thể thay đổi',
            ], 422);
        }

        $request->validate([
            'predicted_team_id' => 'required|exists:teams,id',
            'reason' => 'nullable|string|max:500',
            'confidence_level' => 'required|integer|min:1|max:100',
        ]);

        // Check if team is in the season
        if (!$championPrediction->season->teams()->where('teams.id', $request->predicted_team_id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Đội bóng không tham gia mùa giải này',
            ], 422);
        }

        $championPrediction->update([
            'predicted_team_id' => $request->predicted_team_id,
            'reason' => $request->reason,
            'confidence_level' => $request->confidence_level,
        ]);

        $championPrediction->load(['season.competition', 'predictedTeam']);

        return response()->json([
            'success' => true,
            'message' => 'Dự đoán đã được cập nhật',
            'data' => new ChampionPredictionResource($championPrediction),
        ]);
    }

    /**
     * Get prediction details
     */
    public function show(ChampionPrediction $championPrediction): JsonResponse
    {
        $championPrediction->load(['season.competition', 'predictedTeam', 'user']);

        return response()->json([
            'success' => true,
            'data' => new ChampionPredictionResource($championPrediction),
        ]);
    }

    /**
     * Get season predictions statistics
     */
    public function seasonStats(Season $season): JsonResponse
    {
        $stats = ChampionPrediction::where('season_id', $season->id)
            ->selectRaw('predicted_team_id, COUNT(*) as count, AVG(confidence_level) as avg_confidence, SUM(points_wagered) as total_wagered')
            ->groupBy('predicted_team_id')
            ->with('predictedTeam')
            ->orderByDesc('count')
            ->get();

        $totalPredictions = $stats->sum('count');
        $champion = SeasonChampion::where('season_id', $season->id)
            ->with('championTeam')
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'season' => [
                    'id' => $season->id,
                    'name' => $season->name,
                    'competition_name' => $season->competition->name,
                ],
                'champion' => $champion ? new SeasonChampionResource($champion) : null,
                'total_predictions' => $totalPredictions,
                'teams' => $stats->map(function ($stat) use ($totalPredictions) {
                    return [
                        'team' => new TeamResource($stat->predictedTeam),
                        'prediction_count' => $stat->count,
                        'percentage' => $totalPredictions > 0 
                            ? round(($stat->count / $totalPredictions) * 100, 1) 
                            : 0,
                        'avg_confidence' => round($stat->avg_confidence, 1),
                        'total_wagered' => (int) $stat->total_wagered,
                    ];
                }),
            ],
        ]);
    }

    /**
     * Get champion prediction leaderboard
     */
    public function leaderboard(Request $request): JsonResponse
    {
        $seasonId = $request->query('season_id');
        $period = $request->query('period', 'all_time');

        $query = ChampionPredictionLeaderboard::with('user');

        if ($period === 'season' && $seasonId) {
            $query->where('season_id', $seasonId);
        } else {
            $query->whereNull('season_id');
        }

        $leaderboard = $query->orderByDesc('total_points_earned')
            ->orderByDesc('correct_predictions')
            ->orderBy('total_points_wagered')
            ->limit(100)
            ->get();

        return response()->json([
            'success' => true,
            'data' => ChampionPredictionLeaderboardResource::collection($leaderboard),
        ]);
    }

    /**
     * Get user's rank in champion prediction
     */
    public function myRank(Request $request): JsonResponse
    {
        $user = $request->user();
        $seasonId = $request->query('season_id');

        $query = ChampionPredictionLeaderboard::where('user_id', $user->id);
        
        if ($seasonId) {
            $query->where('season_id', $seasonId);
        } else {
            $query->whereNull('season_id');
        }

        $userStats = $query->first();

        if (!$userStats) {
            return response()->json([
                'success' => true,
                'data' => [
                    'rank' => null,
                    'total_predictions' => 0,
                    'correct_predictions' => 0,
                    'win_rate' => 0,
                    'total_points_wagered' => 0,
                    'total_points_earned' => 0,
                    'profit' => 0,
                ],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => new ChampionPredictionLeaderboardResource($userStats),
        ]);
    }

    /**
     * Get season champion
     */
    public function seasonChampion(Season $season): JsonResponse
    {
        $champion = SeasonChampion::where('season_id', $season->id)
            ->with(['championTeam', 'season.competition'])
            ->first();

        if (!$champion) {
            return response()->json([
                'success' => true,
                'data' => null,
                'message' => 'Chưa có đội vô địch được xác nhận',
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => new SeasonChampionResource($champion),
        ]);
    }

    /**
     * Get all season champions
     */
    public function allChampions(): JsonResponse
    {
        $champions = SeasonChampion::with(['championTeam', 'season.competition'])
            ->orderByDesc('confirmed_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => SeasonChampionResource::collection($champions),
        ]);
    }
}
