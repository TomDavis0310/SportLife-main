<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TeamResource;
use App\Http\Resources\PlayerResource;
use App\Http\Resources\MatchResource;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    /**
     * List all teams
     */
    public function index(Request $request): JsonResponse
    {
        $query = Team::query();

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('short_name', 'like', "%{$request->search}%");
            });
        }

        if ($request->filled('country')) {
            $query->where('country', $request->country);
        }

        $teams = $query->orderBy('name')->paginate(30);

        return response()->json([
            'success' => true,
            'data' => TeamResource::collection($teams),
            'meta' => [
                'current_page' => $teams->currentPage(),
                'last_page' => $teams->lastPage(),
                'total' => $teams->total(),
            ],
        ]);
    }

    /**
     * Show team details
     */
    public function show(Team $team): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new TeamResource($team),
        ]);
    }

    /**
     * Get team squad/players
     */
    public function players(Team $team): JsonResponse
    {
        $players = $team->players()
            ->orderBy('position')
            ->orderBy('jersey_number')
            ->get();

        return response()->json([
            'success' => true,
            'data' => PlayerResource::collection($players),
        ]);
    }

    /**
     * Get team upcoming matches
     */
    public function upcomingMatches(Team $team): JsonResponse
    {
        $matches = $team->allMatches()
            ->upcoming()
            ->with(['homeTeam', 'awayTeam', 'round.season.competition'])
            ->orderBy('match_date')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }

    /**
     * Get team recent results
     */
    public function recentResults(Team $team): JsonResponse
    {
        $matches = $team->allMatches()
            ->finished()
            ->with(['homeTeam', 'awayTeam', 'round.season.competition'])
            ->orderByDesc('match_date')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
        ]);
    }

    /**
     * Get all team matches
     */
    public function matches(Team $team, Request $request): JsonResponse
    {
        $limit = $request->input('limit', 20);
        
        $matches = $team->allMatches()
            ->with(['homeTeam', 'awayTeam', 'round.season.competition'])
            ->orderByDesc('match_date')
            ->paginate($limit);

        return response()->json([
            'success' => true,
            'data' => MatchResource::collection($matches),
            'meta' => [
                'current_page' => $matches->currentPage(),
                'last_page' => $matches->lastPage(),
                'total' => $matches->total(),
            ],
        ]);
    }

    /**
     * Get team statistics
     */
    public function statistics(Team $team, Request $request): JsonResponse
    {
        $seasonId = $request->season_id;

        // Get standing for current/specified season
        $standing = $team->standings()
            ->when($seasonId, fn($q) => $q->where('season_id', $seasonId))
            ->with('season.competition')
            ->first();

        // Calculate additional stats
        $matches = $team->allMatches()
            ->finished()
            ->when($seasonId, function ($q) use ($seasonId) {
                $q->whereHas('round', fn($r) => $r->where('season_id', $seasonId));
            })
            ->get();

        $homeWins = $matches->where('home_team_id', $team->id)
            ->where('home_score', '>', $matches->pluck('away_score')->first())->count();
        $awayWins = $matches->where('away_team_id', $team->id)
            ->where('away_score', '>', $matches->pluck('home_score')->first())->count();

        $goalsScored = $matches->sum(function ($match) use ($team) {
            return $match->home_team_id === $team->id ? $match->home_score : $match->away_score;
        });

        $goalsConceded = $matches->sum(function ($match) use ($team) {
            return $match->home_team_id === $team->id ? $match->away_score : $match->home_score;
        });

        return response()->json([
            'success' => true,
            'data' => [
                'team' => new TeamResource($team),
                'standing' => $standing,
                'matches_played' => $matches->count(),
                'goals_scored' => $goalsScored,
                'goals_conceded' => $goalsConceded,
                'goal_difference' => $goalsScored - $goalsConceded,
                'home_wins' => $homeWins,
                'away_wins' => $awayWins,
                'form' => $this->calculateForm($team, $matches->take(5)),
            ],
        ]);
    }

    /**
     * Calculate team form from last N matches
     */
    private function calculateForm(Team $team, $matches): string
    {
        $form = '';
        foreach ($matches as $match) {
            $isHome = $match->home_team_id === $team->id;
            $teamScore = $isHome ? $match->home_score : $match->away_score;
            $opponentScore = $isHome ? $match->away_score : $match->home_score;

            if ($teamScore > $opponentScore) {
                $form .= 'W';
            } elseif ($teamScore < $opponentScore) {
                $form .= 'L';
            } else {
                $form .= 'D';
            }
        }
        return $form;
    }

    /**
     * Follow a team
     */
    public function follow(Team $team, Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->isFollowing($team)) {
            return response()->json([
                'success' => false,
                'message' => 'Already following this team',
            ], 422);
        }

        $user->followings()->create([
            'followable_type' => Team::class,
            'followable_id' => $team->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Team followed successfully',
        ]);
    }

    /**
     * Unfollow a team
     */
    public function unfollow(Team $team, Request $request): JsonResponse
    {
        $user = $request->user();

        $user->followings()
            ->where('followable_type', Team::class)
            ->where('followable_id', $team->id)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Team unfollowed successfully',
        ]);
    }
}
