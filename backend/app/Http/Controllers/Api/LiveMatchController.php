<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class LiveMatchController extends Controller
{
    /**
     * Get matches available for live update (sponsor's tournaments)
     */
    public function getMatches(Request $request): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $sponsorId = $request->user()->id;

        // Get all seasons owned by this sponsor
        $seasonIds = Season::where('sponsor_user_id', $sponsorId)->pluck('id');

        // Get matches from these seasons
        $matches = FootballMatch::whereHas('round', function($q) use ($seasonIds) {
            $q->whereIn('season_id', $seasonIds);
        })
        ->with(['homeTeam:id,name,short_name,logo', 'awayTeam:id,name,short_name,logo', 'round.season.competition:id,name'])
        ->orderBy('match_date', 'asc')
        ->get()
        ->map(function($match) {
            return [
                'id' => $match->id,
                'home_team' => [
                    'id' => $match->homeTeam->id,
                    'name' => $match->homeTeam->name,
                    'short_name' => $match->homeTeam->short_name,
                    'logo' => $match->homeTeam->logo_url,
                ],
                'away_team' => [
                    'id' => $match->awayTeam->id,
                    'name' => $match->awayTeam->name,
                    'short_name' => $match->awayTeam->short_name,
                    'logo' => $match->awayTeam->logo_url,
                ],
                'home_score' => $match->home_score,
                'away_score' => $match->away_score,
                'status' => $match->status->value ?? $match->status,
                'minute' => $match->minute,
                'match_date' => $match->match_date?->format('Y-m-d H:i'),
                'venue' => $match->venue,
                'competition' => $match->round?->season?->competition?->name,
                'round_name' => $match->round?->name,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $matches,
        ]);
    }

    /**
     * Get single match details for live update
     */
    public function getMatch(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with([
            'homeTeam.activePlayers',
            'awayTeam.activePlayers',
            'round.season.competition',
            'events' => function($q) {
                $q->orderBy('minute', 'desc')->orderBy('id', 'desc');
            },
            'events.player',
            'events.assistPlayer',
        ])->findOrFail($matchId);

        // Verify sponsor owns this match's tournament
        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $match->id,
                'home_team' => [
                    'id' => $match->homeTeam->id,
                    'name' => $match->homeTeam->name,
                    'short_name' => $match->homeTeam->short_name,
                    'logo' => $match->homeTeam->logo_url,
                    'players' => $match->homeTeam->activePlayers->map(fn($p) => [
                        'id' => $p->id,
                        'name' => $p->name,
                        'jersey_number' => $p->jersey_number,
                        'position' => $p->position,
                    ]),
                ],
                'away_team' => [
                    'id' => $match->awayTeam->id,
                    'name' => $match->awayTeam->name,
                    'short_name' => $match->awayTeam->short_name,
                    'logo' => $match->awayTeam->logo_url,
                    'players' => $match->awayTeam->activePlayers->map(fn($p) => [
                        'id' => $p->id,
                        'name' => $p->name,
                        'jersey_number' => $p->jersey_number,
                        'position' => $p->position,
                    ]),
                ],
                'home_score' => $match->home_score ?? 0,
                'away_score' => $match->away_score ?? 0,
                'home_score_ht' => $match->home_score_ht,
                'away_score_ht' => $match->away_score_ht,
                'status' => $match->status->value ?? $match->status,
                'minute' => $match->minute ?? 0,
                'match_date' => $match->match_date?->format('Y-m-d H:i'),
                'venue' => $match->venue,
                'competition' => $match->round?->season?->competition?->name,
                'round_name' => $match->round?->name,
                'events' => $match->events->map(fn($e) => [
                    'id' => $e->id,
                    'type' => $e->event_type,
                    'minute' => $e->minute,
                    'team_id' => $e->team_id,
                    'player' => $e->player ? [
                        'id' => $e->player->id,
                        'name' => $e->player->name,
                        'jersey_number' => $e->player->jersey_number,
                    ] : null,
                    'assist_player' => $e->assistPlayer ? [
                        'id' => $e->assistPlayer->id,
                        'name' => $e->assistPlayer->name,
                    ] : null,
                    'description' => $e->description,
                ]),
            ],
        ]);
    }

    /**
     * Start match - change status to live
     */
    public function startMatch(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $match->update([
            'status' => 'live',
            'minute' => 0,
            'home_score' => 0,
            'away_score' => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Trận đấu đã bắt đầu!',
            'data' => ['status' => 'live', 'minute' => 0],
        ]);
    }

    /**
     * Update match status and time
     */
    public function updateStatus(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $validated = $request->validate([
            'status' => 'nullable|in:scheduled,live,half_time,second_half,finished,postponed,cancelled',
            'minute' => 'nullable|integer|min:0|max:120',
        ]);

        // Handle half time - save HT score
        if (($validated['status'] ?? null) === 'half_time') {
            $match->update([
                'status' => 'half_time',
                'home_score_ht' => $match->home_score,
                'away_score_ht' => $match->away_score,
                'minute' => 45,
            ]);
        } elseif (($validated['status'] ?? null) === 'second_half') {
            $match->update([
                'status' => 'live',
                'minute' => 46,
            ]);
        } else {
            $match->update(array_filter($validated));
        }

        return response()->json([
            'success' => true,
            'message' => 'Đã cập nhật trạng thái trận đấu',
            'data' => [
                'status' => $match->status->value ?? $match->status,
                'minute' => $match->minute,
            ],
        ]);
    }

    /**
     * Update match score
     */
    public function updateScore(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $match->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Đã cập nhật tỷ số',
            'data' => [
                'home_score' => $match->home_score,
                'away_score' => $match->away_score,
            ],
        ]);
    }

    /**
     * Add match event (goal, card, substitution)
     */
    public function addEvent(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $validated = $request->validate([
            'event_type' => 'required|in:goal,own_goal,penalty,yellow_card,red_card,substitution,injury,var',
            'minute' => 'required|integer|min:0|max:120',
            'team_id' => 'required|exists:teams,id',
            'player_id' => 'nullable|exists:players,id',
            'assist_player_id' => 'nullable|exists:players,id',
            'player_out_id' => 'nullable|exists:players,id', // For substitution
            'description' => 'nullable|string|max:255',
        ]);

        $event = MatchEvent::create([
            'match_id' => $match->id,
            'event_type' => $validated['event_type'],
            'minute' => $validated['minute'],
            'team_id' => $validated['team_id'],
            'player_id' => $validated['player_id'] ?? null,
            'assist_player_id' => $validated['assist_player_id'] ?? null,
            'player_out_id' => $validated['player_out_id'] ?? null,
            'description' => $validated['description'] ?? null,
        ]);

        // Auto update score for goals
        if (in_array($validated['event_type'], ['goal', 'penalty'])) {
            if ($validated['team_id'] == $match->home_team_id) {
                $match->increment('home_score');
            } else {
                $match->increment('away_score');
            }
        } elseif ($validated['event_type'] === 'own_goal') {
            // Own goal - add to opponent's score
            if ($validated['team_id'] == $match->home_team_id) {
                $match->increment('away_score');
            } else {
                $match->increment('home_score');
            }
        }

        $match->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Đã thêm sự kiện',
            'data' => [
                'event' => $event->load('player'),
                'home_score' => $match->home_score,
                'away_score' => $match->away_score,
            ],
        ]);
    }

    /**
     * Delete match event
     */
    public function deleteEvent(Request $request, $matchId, $eventId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $event = MatchEvent::where('match_id', $matchId)->findOrFail($eventId);

        // Revert score if it was a goal
        if (in_array($event->event_type, ['goal', 'penalty'])) {
            if ($event->team_id == $match->home_team_id) {
                $match->decrement('home_score');
            } else {
                $match->decrement('away_score');
            }
        } elseif ($event->event_type === 'own_goal') {
            if ($event->team_id == $match->home_team_id) {
                $match->decrement('away_score');
            } else {
                $match->decrement('home_score');
            }
        }

        $event->delete();
        $match->refresh();

        return response()->json([
            'success' => true,
            'message' => 'Đã xóa sự kiện',
            'data' => [
                'home_score' => $match->home_score,
                'away_score' => $match->away_score,
            ],
        ]);
    }

    /**
     * End match
     */
    public function endMatch(Request $request, $matchId): JsonResponse
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $match = FootballMatch::with('round.season')->findOrFail($matchId);

        if ($match->round?->season?->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý trận đấu này'], 403);
        }

        $match->update([
            'status' => 'finished',
            'minute' => 90,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Trận đấu đã kết thúc!',
            'data' => [
                'status' => 'finished',
                'home_score' => $match->home_score,
                'away_score' => $match->away_score,
            ],
        ]);
    }
}
