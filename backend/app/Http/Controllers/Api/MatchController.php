<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MatchResource;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Events\MatchUpdated;
use App\Events\MatchEventCreated;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

class MatchController extends Controller
{
    /**
     * List matches with filters
     */
    public function index(Request $request): JsonResponse
    {
        $query = FootballMatch::query()
            ->with([
                'homeTeam',
                'awayTeam',
                'round.season.competition',
                'statistics',
            ]);

        // Filter by date
        if ($request->has('date')) {
            $date = Carbon::parse($request->date);
            $query->whereDate('match_date', $date);
        }

        // Filter by status
        if ($request->has('status')) {
            if ($request->status === 'live') {
                $query->live();
            } elseif ($request->status === 'finished') {
                $query->finished();
            } elseif ($request->status === 'upcoming') {
                $query->upcoming();
            } else {
                $query->where('status', $request->status);
            }
        }

        // Filter by competition
        if ($request->has('competition_id')) {
            $query->whereHas('round.season', function ($q) use ($request) {
                $q->where('competition_id', $request->competition_id);
            });
        }

        // Filter by team
        if ($request->has('team_id')) {
            $query->where(function ($q) use ($request) {
                $q->where('home_team_id', $request->team_id)
                    ->orWhere('away_team_id', $request->team_id);
            });
        }

        $matches = $query->orderBy('match_date')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
            'meta' => [
                'current_page' => $matches->currentPage(),
                'last_page' => $matches->lastPage(),
                'per_page' => $matches->perPage(),
                'total' => $matches->total(),
            ],
        ]);
    }

    /**
     * Get today's matches
     */
    public function today(): JsonResponse
    {
        $matches = FootballMatch::today()
            ->with(['homeTeam', 'awayTeam', 'round.season.competition', 'statistics'])
            ->orderBy('match_date')
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }

    /**
     * Get live matches
     */
    public function live(): JsonResponse
    {
        $matches = FootballMatch::live()
            ->with([
                'homeTeam',
                'awayTeam',
                'round.season.competition',
                'events.player',
                'events.assistPlayer',
                'events.substitutePlayer',
                'events.team',
                'statistics',
            ])
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }

    /**
     * Get upcoming matches
     */
    public function upcoming(Request $request): JsonResponse
    {
        $limit = $request->get('limit', 10);

        $matches = FootballMatch::upcoming()
            ->with(['homeTeam', 'awayTeam', 'round.season.competition', 'statistics'])
            ->limit($limit)
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }

    /**
     * Show match details
     */
    public function show(FootballMatch $match): JsonResponse
    {
        $match->load([
            'homeTeam.activePlayers',
            'awayTeam.activePlayers',
            'round.season.competition',
            'events.player',
            'events.assistPlayer',
            'events.substitutePlayer',
            'events.team',
            'firstScorer',
            'statistics',
            'highlights' => fn($query) => $query
                ->orderByDesc('published_at')
                ->orderByDesc('created_at')
                ->limit(10),
        ]);

        return response()->json([
            'success' => true,
            'data' => new MatchResource($match),
        ]);
    }

    /**
     * Get match events
     */
    public function events(FootballMatch $match): JsonResponse
    {
        $events = $match->events()
            ->with(['player', 'assistPlayer', 'substitutePlayer', 'team'])
            ->orderBy('minute')
            ->orderBy('extra_minute')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $events,
        ]);
    }

    /**
     * Get match head-to-head
     */
    public function headToHead(FootballMatch $match): JsonResponse
    {
        $h2h = FootballMatch::where('status', 'finished')
            ->where(function ($query) use ($match) {
                $query->where(function ($q) use ($match) {
                    $q->where('home_team_id', $match->home_team_id)
                        ->where('away_team_id', $match->away_team_id);
                })->orWhere(function ($q) use ($match) {
                    $q->where('home_team_id', $match->away_team_id)
                        ->where('away_team_id', $match->home_team_id);
                });
            })
            ->where('id', '!=', $match->id)
            ->with(['homeTeam', 'awayTeam'])
            ->orderByDesc('match_date')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($h2h),
        ]);
    }

    /**
     * Get user's prediction for match
     */
    public function userPrediction(FootballMatch $match, Request $request): JsonResponse
    {
        $prediction = $match->predictions()
            ->where('user_id', $request->user()->id)
            ->with('firstScorer')
            ->first();

        return response()->json([
            'success' => true,
            'data' => $prediction,
        ]);
    }
}
