<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MatchResource;
use App\Http\Resources\CompetitionResource;
use App\Http\Resources\SeasonResource;
use App\Http\Resources\RoundResource;
use App\Http\Resources\StandingResource;
use App\Models\Competition;
use App\Models\FootballMatch;
use App\Models\Round;
use App\Models\Season;
use App\Models\Standing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompetitionController extends Controller
{
    /**
     * List all competitions
     */
    public function index(): JsonResponse
    {
        $competitions = Competition::where('is_active', true)
            ->with(['seasons' => function ($q) {
                $q->orderByDesc('start_date')->with('teams');
            }])
            ->get();

        return response()->json([
            'success' => true,
            'data' => CompetitionResource::collection($competitions),
        ]);
    }

    /**
     * Show competition details with full information
     */
    public function show(Competition $competition): JsonResponse
    {
        $competition->load([
            'seasons' => function ($q) {
                $q->orderByDesc('start_date')
                  ->with(['teams', 'standings', 'rounds' => function($rq) {
                      $rq->orderBy('round_number')->withCount('matches');
                  }]);
            },
        ]);

        return response()->json([
            'success' => true,
            'data' => new CompetitionResource($competition),
        ]);
    }

    /**
     * Get competition seasons
     */
    public function seasons(Competition $competition): JsonResponse
    {
        $seasons = $competition->seasons()
            ->orderByDesc('start_date')
            ->with('teams')
            ->get();

        return response()->json([
            'success' => true,
            'data' => SeasonResource::collection($seasons),
        ]);
    }

    /**
     * Get current season standings
     */
    public function standings(Competition $competition, Request $request): JsonResponse
    {
        $seasonId = $request->query('season_id');

        $season = $seasonId
            ? Season::findOrFail($seasonId)
            : $competition->currentSeason->first();

        if (!$season) {
            return response()->json([
                'success' => false,
                'message' => 'No season found',
            ], 404);
        }

        $standings = Standing::where('season_id', $season->id)
            ->with('team')
            ->orderBy('position')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'season' => new SeasonResource($season),
                'standings' => StandingResource::collection($standings),
            ],
        ]);
    }

    /**
     * Get season rounds
     */
    public function rounds(Season $season): JsonResponse
    {
        $rounds = $season->rounds()
            ->orderBy('round_number')
            ->withCount('matches')
            ->get();

        return response()->json([
            'success' => true,
            'data' => RoundResource::collection($rounds),
        ]);
    }

    /**
     * Get round matches
     */
    public function roundMatches(Round $round): JsonResponse
    {
        $matches = $round->matches()
            ->with(['homeTeam', 'awayTeam', 'firstScorer'])
            ->orderBy('match_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'round' => new RoundResource($round),
                'matches' => MatchResource::collection($matches),
            ],
        ]);
    }

    /**
     * Get competition matches
     */
    public function matches(Competition $competition, Request $request): JsonResponse
    {
        $seasonId = $request->query('season_id');
        $roundNumber = $request->query('round');
        $status = $request->query('status');

        // Get current season if not specified
        $season = $seasonId
            ? Season::findOrFail($seasonId)
            : $competition->currentSeason->first();

        if (!$season) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        // Build query for matches
        $query = FootballMatch::whereHas('round', function ($q) use ($season, $roundNumber) {
            $q->where('season_id', $season->id);
            if ($roundNumber) {
                $q->where('round_number', $roundNumber);
            }
        })
        ->with(['homeTeam', 'awayTeam', 'round'])
        ->orderBy('match_date');

        if ($status) {
            $query->where('status', $status);
        }

        $matches = $query->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }
}
