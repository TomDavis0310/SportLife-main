<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FootballMatch;
use App\Models\Round;
use App\Models\Season;
use App\Services\MatchSchedulingService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MatchSchedulingController extends Controller
{
    protected MatchSchedulingService $schedulingService;

    public function __construct(MatchSchedulingService $schedulingService)
    {
        $this->schedulingService = $schedulingService;
    }

    /**
     * Get available seasons for scheduling
     */
    public function seasons(): JsonResponse
    {
        $seasons = Season::with('competition')
            ->withCount(['teams', 'rounds'])
            ->orderByDesc('is_current')
            ->orderByDesc('start_date')
            ->get()
            ->map(function ($season) {
                return [
                    'id' => $season->id,
                    'name' => $season->name,
                    'competition_id' => $season->competition_id,
                    'competition_name' => $season->competition?->name,
                    'start_date' => $season->start_date?->format('Y-m-d'),
                    'end_date' => $season->end_date?->format('Y-m-d'),
                    'is_current' => $season->is_current,
                    'teams_count' => $season->teams_count,
                    'rounds_count' => $season->rounds_count,
                    'has_schedule' => $season->rounds_count > 0,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $seasons,
        ]);
    }

    /**
     * Get season details with teams
     */
    public function seasonDetails(Season $season): JsonResponse
    {
        $season->load(['competition', 'teams', 'rounds' => function ($q) {
            $q->withCount('matches')->orderBy('round_number');
        }]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $season->id,
                'name' => $season->name,
                'competition' => [
                    'id' => $season->competition?->id,
                    'name' => $season->competition?->name,
                ],
                'start_date' => $season->start_date?->format('Y-m-d'),
                'end_date' => $season->end_date?->format('Y-m-d'),
                'is_current' => $season->is_current,
                'teams' => $season->teams->map(fn($t) => [
                    'id' => $t->id,
                    'name' => $t->name,
                    'short_name' => $t->short_name,
                    'logo' => $t->logo_url,
                    'stadium' => $t->stadium,
                ]),
                'rounds' => $season->rounds->map(fn($r) => [
                    'id' => $r->id,
                    'name' => $r->name,
                    'round_number' => $r->round_number,
                    'start_date' => $r->start_date?->format('Y-m-d'),
                    'end_date' => $r->end_date?->format('Y-m-d'),
                    'is_current' => $r->is_current,
                    'matches_count' => $r->matches_count,
                ]),
            ],
        ]);
    }

    /**
     * Preview auto-generated schedule
     */
    public function previewSchedule(Request $request, Season $season): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:round_robin,home_away,single_elimination,group_stage',
            'start_date' => 'nullable|date',
            'time_slots' => 'nullable|array',
            'time_slots.*' => 'string',
            'match_days' => 'nullable|array',
            'match_days.*' => 'integer|min:0|max:6',
            'matches_per_day' => 'nullable|integer|min:1|max:20',
            'num_groups' => 'nullable|integer|min:2|max:16',
            'home_and_away' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $schedule = $this->schedulingService->previewSchedule(
                $season,
                $request->type,
                $request->only(['start_date', 'time_slots', 'match_days', 'matches_per_day', 'num_groups', 'home_and_away'])
            );

            $totalMatches = array_sum(array_map(fn($r) => count($r['matches']), $schedule));

            return response()->json([
                'success' => true,
                'data' => [
                    'schedule' => $schedule,
                    'summary' => [
                        'total_rounds' => count($schedule),
                        'total_matches' => $totalMatches,
                        'type' => $request->type,
                    ],
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Generate and save auto schedule
     */
    public function generateSchedule(Request $request, Season $season): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:round_robin,home_away,single_elimination,group_stage',
            'start_date' => 'nullable|date',
            'time_slots' => 'nullable|array',
            'time_slots.*' => 'string',
            'match_days' => 'nullable|array',
            'match_days.*' => 'integer|min:0|max:6',
            'matches_per_day' => 'nullable|integer|min:1|max:20',
            'num_groups' => 'nullable|integer|min:2|max:16',
            'home_and_away' => 'nullable|boolean',
            'clear_existing' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Clear existing schedule if requested
            if ($request->boolean('clear_existing')) {
                $this->schedulingService->clearSeasonSchedule($season);
            }

            // Generate schedule
            $schedule = $this->schedulingService->generateSchedule(
                $season,
                $request->type,
                $request->only(['start_date', 'time_slots', 'match_days', 'matches_per_day', 'num_groups', 'home_and_away'])
            );

            // Save to database
            $result = $this->schedulingService->saveSchedule($season, $schedule);

            return response()->json([
                'success' => true,
                'message' => 'Đã tạo lịch thi đấu thành công',
                'data' => [
                    'summary' => $result['summary'],
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Get rounds for a season
     */
    public function rounds(Season $season): JsonResponse
    {
        $rounds = Round::where('season_id', $season->id)
            ->withCount('matches')
            ->orderBy('round_number')
            ->get()
            ->map(fn($r) => [
                'id' => $r->id,
                'name' => $r->name,
                'round_number' => $r->round_number,
                'start_date' => $r->start_date?->format('Y-m-d'),
                'end_date' => $r->end_date?->format('Y-m-d'),
                'is_current' => $r->is_current,
                'matches_count' => $r->matches_count,
            ]);

        return response()->json([
            'success' => true,
            'data' => $rounds,
        ]);
    }

    /**
     * Get matches for a round
     */
    public function roundMatches(Round $round): JsonResponse
    {
        $matches = FootballMatch::where('round_id', $round->id)
            ->with(['homeTeam', 'awayTeam'])
            ->orderBy('match_date')
            ->get()
            ->map(fn($m) => [
                'id' => $m->id,
                'home_team' => [
                    'id' => $m->homeTeam->id,
                    'name' => $m->homeTeam->name,
                    'short_name' => $m->homeTeam->short_name,
                    'logo' => $m->homeTeam->logo_url,
                ],
                'away_team' => [
                    'id' => $m->awayTeam->id,
                    'name' => $m->awayTeam->name,
                    'short_name' => $m->awayTeam->short_name,
                    'logo' => $m->awayTeam->logo_url,
                ],
                'match_date' => $m->match_date?->format('Y-m-d H:i'),
                'match_date_formatted' => $m->match_date?->format('d/m/Y H:i'),
                'venue' => $m->venue,
                'status' => $m->status,
                'home_score' => $m->home_score,
                'away_score' => $m->away_score,
            ]);

        return response()->json([
            'success' => true,
            'data' => [
                'round' => [
                    'id' => $round->id,
                    'name' => $round->name,
                    'round_number' => $round->round_number,
                ],
                'matches' => $matches,
            ],
        ]);
    }

    /**
     * Create a manual match
     */
    public function createMatch(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'round_id' => 'required|exists:rounds,id',
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'match_date' => 'required|date',
            'venue' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $match = $this->schedulingService->createMatch($request->all());
            $match->load(['homeTeam', 'awayTeam', 'round']);

            return response()->json([
                'success' => true,
                'message' => 'Đã tạo trận đấu thành công',
                'data' => [
                    'id' => $match->id,
                    'round' => $match->round->name,
                    'home_team' => $match->homeTeam->name,
                    'away_team' => $match->awayTeam->name,
                    'match_date' => $match->match_date->format('d/m/Y H:i'),
                    'venue' => $match->venue,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Update match schedule
     */
    public function updateMatch(Request $request, FootballMatch $match): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'round_id' => 'nullable|exists:rounds,id',
            'match_date' => 'nullable|date',
            'venue' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $match = $this->schedulingService->updateMatchSchedule($match, $request->all());
            $match->load(['homeTeam', 'awayTeam', 'round']);

            return response()->json([
                'success' => true,
                'message' => 'Đã cập nhật trận đấu thành công',
                'data' => [
                    'id' => $match->id,
                    'round' => $match->round->name,
                    'home_team' => $match->homeTeam->name,
                    'away_team' => $match->awayTeam->name,
                    'match_date' => $match->match_date->format('d/m/Y H:i'),
                    'venue' => $match->venue,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Reschedule a match
     */
    public function rescheduleMatch(Request $request, FootballMatch $match): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'new_date' => 'required|date',
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $match = $this->schedulingService->rescheduleMatch(
                $match,
                Carbon::parse($request->new_date),
                $request->reason
            );
            $match->load(['homeTeam', 'awayTeam']);

            return response()->json([
                'success' => true,
                'message' => 'Đã dời lịch trận đấu thành công',
                'data' => [
                    'id' => $match->id,
                    'home_team' => $match->homeTeam->name,
                    'away_team' => $match->awayTeam->name,
                    'new_date' => $match->match_date->format('d/m/Y H:i'),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Swap home/away teams
     */
    public function swapTeams(FootballMatch $match): JsonResponse
    {
        try {
            $match = $this->schedulingService->swapHomeAway($match);
            $match->load(['homeTeam', 'awayTeam']);

            return response()->json([
                'success' => true,
                'message' => 'Đã đổi sân thành công',
                'data' => [
                    'id' => $match->id,
                    'home_team' => $match->homeTeam->name,
                    'away_team' => $match->awayTeam->name,
                    'venue' => $match->venue,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Delete a match
     */
    public function deleteMatch(FootballMatch $match): JsonResponse
    {
        try {
            $matchInfo = [
                'id' => $match->id,
                'home_team' => $match->homeTeam?->name,
                'away_team' => $match->awayTeam?->name,
            ];
            
            $match->delete();

            return response()->json([
                'success' => true,
                'message' => 'Đã xóa trận đấu thành công',
                'data' => $matchInfo,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Check scheduling conflicts
     */
    public function checkConflicts(Season $season): JsonResponse
    {
        $conflicts = $this->schedulingService->getSchedulingConflicts($season);

        return response()->json([
            'success' => true,
            'data' => [
                'has_conflicts' => !empty($conflicts),
                'conflicts' => $conflicts,
            ],
        ]);
    }

    /**
     * Create a new round
     */
    public function createRound(Request $request, Season $season): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'round_number' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Auto determine round number if not provided
        $roundNumber = $request->round_number ?? (Round::where('season_id', $season->id)->max('round_number') + 1);

        $round = Round::create([
            'season_id' => $season->id,
            'name' => $request->name,
            'round_number' => $roundNumber,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'is_current' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Đã tạo vòng đấu thành công',
            'data' => [
                'id' => $round->id,
                'name' => $round->name,
                'round_number' => $round->round_number,
            ],
        ]);
    }

    /**
     * Clear season schedule
     */
    public function clearSchedule(Season $season): JsonResponse
    {
        try {
            $deletedCount = $this->schedulingService->clearSeasonSchedule($season);

            return response()->json([
                'success' => true,
                'message' => "Đã xóa $deletedCount trận đấu",
                'data' => [
                    'deleted_matches' => $deletedCount,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }
}
