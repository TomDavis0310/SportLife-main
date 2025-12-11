<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\Season;
use App\Models\Team;
use App\Models\FootballMatch;
use App\Models\Round;
use App\Services\MatchSchedulingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TournamentController extends Controller
{
    protected MatchSchedulingService $schedulingService;

    public function __construct(MatchSchedulingService $schedulingService)
    {
        $this->schedulingService = $schedulingService;
    }

    // List competitions/seasons
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->hasRole('sponsor')) {
            // Sponsors see competitions they manage
            $competitions = Competition::with(['seasons' => function($q) use ($user) {
                $q->where('sponsor_user_id', $user->id)
                    ->withCount(['teams', 'teams as approved_teams_count' => function($q) {
                        $q->where('season_teams.status', 'approved');
                    }]);
            }])->whereHas('seasons', function($q) use ($user) {
                $q->where('sponsor_user_id', $user->id);
            })->get();
        } else {
            // Managers see active competitions to register
            $competitions = Competition::where('is_active', true)
                ->with(['seasons' => function($q) {
                    $q->where('is_current', true)
                        ->withCount(['teams', 'teams as approved_teams_count' => function($q) {
                            $q->where('season_teams.status', 'approved');
                        }]);
                }])
                ->get();
        }

        return response()->json([
            'success' => true,
            'data' => $competitions
        ]);
    }

    // Create competition (Sponsor)
    public function store(Request $request)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string',
            'type' => 'required|in:league,cup',
            'round_type' => 'nullable|in:round_robin,group_stage,knockout,league,mixed',
            'season_name' => 'required|string', // e.g. 2025
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'max_teams' => 'nullable|integer|min:2|max:64',
            'min_teams' => 'nullable|integer|min:2|max:64',
            'registration_start_date' => 'nullable|date',
            'registration_end_date' => 'nullable|date',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'prize' => 'nullable|string|max:255',
            'rules' => 'nullable|string',
            'contact' => 'nullable|string|max:255',
        ]);

        DB::beginTransaction();
        try {
            $competition = Competition::create([
                'name' => $validated['name'],
                'type' => $validated['type'],
                'description' => $validated['description'] ?? null,
                'is_active' => true,
            ]);

            $season = $competition->seasons()->create([
                'name' => $validated['season_name'],
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'is_current' => true,
                'format' => $validated['type'], // league or cup
                'round_type' => $validated['round_type'] ?? 'round_robin',
                'max_teams' => $validated['max_teams'] ?? 20,
                'min_teams' => $validated['min_teams'] ?? 2,
                'registration_start_date' => $validated['registration_start_date'] ?? null,
                'registration_end_date' => $validated['registration_end_date'] ?? null,
                'registration_locked' => false,
                'sponsor_user_id' => $request->user()->id,
                'location' => $validated['location'] ?? null,
                'prize' => $validated['prize'] ?? null,
                'rules' => $validated['rules'] ?? null,
                'contact' => $validated['contact'] ?? null,
            ]);

            DB::commit();
            return response()->json([
                'success' => true, 
                'data' => $competition->load(['seasons' => function($q) {
                    $q->withCount('teams');
                }]),
                'message' => 'Giải đấu đã được tạo thành công'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // Get season details (for both sponsors and managers)
    public function show(Request $request, $seasonId)
    {
        $season = Season::with(['competition', 'teams' => function($q) {
            $q->withPivot('status', 'created_at');
        }])
        ->withCount(['teams', 'teams as approved_teams_count' => function($q) {
            $q->wherePivot('status', 'approved');
        }, 'teams as pending_teams_count' => function($q) {
            $q->wherePivot('status', 'pending');
        }])
        ->findOrFail($seasonId);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $season->id,
                'name' => $season->name,
                'competition' => $season->competition,
                'start_date' => $season->start_date?->format('Y-m-d'),
                'end_date' => $season->end_date?->format('Y-m-d'),
                'max_teams' => $season->max_teams,
                'min_teams' => $season->min_teams,
                'registration_start_date' => $season->registration_start_date?->format('Y-m-d'),
                'registration_end_date' => $season->registration_end_date?->format('Y-m-d'),
                'registration_locked' => $season->registration_locked,
                'description' => $season->description,
                'location' => $season->location,
                'prize' => $season->prize,
                'rules' => $season->rules,
                'contact' => $season->contact,
                'teams_count' => $season->teams_count,
                'approved_teams_count' => $season->approved_teams_count,
                'pending_teams_count' => $season->pending_teams_count,
                'can_register' => $season->can_register,
                'is_registration_full' => $season->is_registration_full,
                'teams' => $season->teams->map(function($team) {
                    return [
                        'id' => $team->id,
                        'name' => $team->name,
                        'short_name' => $team->short_name,
                        'logo' => $team->logo_url ?? $team->logo,
                        'status' => $team->pivot->status,
                        'registered_at' => $team->pivot->created_at?->format('Y-m-d H:i:s'),
                    ];
                }),
            ]
        ]);
    }

    // Register team (Manager)
    public function registerTeam(Request $request, $seasonId)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'You do not manage any team'], 404);
        }

        $season = Season::findOrFail($seasonId);
        
        // Check if registration is locked
        if ($season->registration_locked) {
            return response()->json(['message' => 'Đăng ký đã đóng cho giải đấu này'], 422);
        }

        // Check if already registered
        if ($season->teams()->where('team_id', $team->id)->exists()) {
            return response()->json(['message' => 'Đội của bạn đã đăng ký giải đấu này'], 422);
        }

        // Check if registration is full
        if ($season->is_registration_full) {
            return response()->json(['message' => 'Giải đấu đã đủ số lượng đội'], 422);
        }

        $season->teams()->attach($team->id, ['status' => 'pending']);

        return response()->json([
            'success' => true, 
            'message' => 'Đăng ký tham gia giải đấu thành công. Vui lòng đợi nhà tài trợ phê duyệt.'
        ]);
    }

    // Get registrations (Sponsor)
    public function getRegistrations(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::with(['teams' => function($q) {
            $q->withPivot('status', 'created_at')
              ->orderByPivot('created_at', 'desc');
        }])->findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        $teams = $season->teams->map(function($team) {
            return [
                'id' => $team->id,
                'name' => $team->name,
                'short_name' => $team->short_name,
                'logo' => $team->logo_url ?? $team->logo,
                'stadium' => $team->stadium,
                'status' => $team->pivot->status,
                'registered_at' => $team->pivot->created_at?->format('Y-m-d H:i:s'),
            ];
        });

        return response()->json([
            'success' => true, 
            'data' => [
                'season' => [
                    'id' => $season->id,
                    'name' => $season->name,
                    'max_teams' => $season->max_teams,
                    'registration_locked' => $season->registration_locked,
                ],
                'teams' => $teams,
                'summary' => [
                    'total' => $teams->count(),
                    'approved' => $teams->where('status', 'approved')->count(),
                    'pending' => $teams->where('status', 'pending')->count(),
                    'rejected' => $teams->where('status', 'rejected')->count(),
                ],
            ]
        ]);
    }

    // Approve registration (Sponsor)
    public function approveRegistration(Request $request, $seasonId, $teamId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        // Check if season already has max teams approved
        if ($season->is_registration_full) {
            return response()->json(['message' => 'Giải đấu đã đủ số lượng đội'], 422);
        }

        $season->teams()->updateExistingPivot($teamId, ['status' => 'approved']);

        return response()->json([
            'success' => true, 
            'message' => 'Đã phê duyệt đội tham gia giải đấu'
        ]);
    }

    // Reject registration (Sponsor)
    public function rejectRegistration(Request $request, $seasonId, $teamId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        $season->teams()->updateExistingPivot($teamId, ['status' => 'rejected']);

        return response()->json([
            'success' => true, 
            'message' => 'Đã từ chối đội tham gia giải đấu'
        ]);
    }

    // Lock registration (Sponsor)
    public function lockRegistration(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        // Check minimum teams
        $approvedCount = $season->teams()->wherePivot('status', 'approved')->count();
        if ($approvedCount < 2) {
            return response()->json([
                'success' => false,
                'message' => 'Cần ít nhất 2 đội đã được phê duyệt để khóa đăng ký'
            ], 422);
        }

        $season->update(['registration_locked' => true]);

        return response()->json([
            'success' => true, 
            'message' => 'Đã khóa đăng ký giải đấu. Bây giờ bạn có thể tạo lịch thi đấu.',
            'data' => [
                'registration_locked' => true,
                'approved_teams_count' => $approvedCount,
            ]
        ]);
    }

    // Unlock registration (Sponsor)
    public function unlockRegistration(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        // Check if schedule already generated
        $hasMatches = FootballMatch::whereHas('round', function($q) use ($seasonId) {
            $q->where('season_id', $seasonId);
        })->exists();

        if ($hasMatches) {
            return response()->json([
                'success' => false,
                'message' => 'Không thể mở lại đăng ký vì lịch thi đấu đã được tạo. Hãy xóa lịch thi đấu trước.'
            ], 422);
        }

        $season->update(['registration_locked' => false]);

        return response()->json([
            'success' => true, 
            'message' => 'Đã mở lại đăng ký giải đấu.'
        ]);
    }

    // Generate schedule for tournament (Sponsor)
    public function generateSchedule(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        // Check if registration is locked
        if (!$season->registration_locked) {
            return response()->json([
                'success' => false,
                'message' => 'Vui lòng khóa đăng ký trước khi tạo lịch thi đấu'
            ], 422);
        }

        $validated = $request->validate([
            'type' => 'required|in:round_robin,home_away,single_elimination,group_stage',
            'start_date' => 'nullable|date',
            'time_slots' => 'nullable|array',
            'time_slots.*' => 'string',
            'match_days' => 'nullable|array',
            'match_days.*' => 'integer|min:0|max:6',
            'matches_per_day' => 'nullable|integer|min:1|max:20',
            'clear_existing' => 'nullable|boolean',
        ]);

        try {
            // Clear existing schedule if requested
            if ($request->boolean('clear_existing')) {
                $this->schedulingService->clearSeasonSchedule($season);
            }

            // Generate schedule
            $schedule = $this->schedulingService->generateSchedule(
                $season,
                $validated['type'],
                $request->only(['start_date', 'time_slots', 'match_days', 'matches_per_day'])
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

    // Preview schedule before generating (Sponsor)
    public function previewSchedule(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        $validated = $request->validate([
            'type' => 'required|in:round_robin,home_away,single_elimination,group_stage',
            'start_date' => 'nullable|date',
            'time_slots' => 'nullable|array',
            'match_days' => 'nullable|array',
            'matches_per_day' => 'nullable|integer|min:1|max:20',
        ]);

        try {
            $schedule = $this->schedulingService->previewSchedule(
                $season,
                $validated['type'],
                $request->only(['start_date', 'time_slots', 'match_days', 'matches_per_day'])
            );

            $totalMatches = array_sum(array_map(fn($r) => count($r['matches']), $schedule));

            return response()->json([
                'success' => true,
                'data' => [
                    'schedule' => $schedule,
                    'summary' => [
                        'total_rounds' => count($schedule),
                        'total_matches' => $totalMatches,
                        'type' => $validated['type'],
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

    // Get tournament schedule (Public - for teams to view)
    public function getSchedule(Request $request, $seasonId)
    {
        $season = Season::with(['competition', 'rounds' => function($q) {
            $q->orderBy('round_number');
        }])->findOrFail($seasonId);

        $rounds = $season->rounds->map(function($round) {
            $matches = FootballMatch::where('round_id', $round->id)
                ->with(['homeTeam', 'awayTeam'])
                ->orderBy('match_date')
                ->get();

            return [
                'id' => $round->id,
                'name' => $round->name,
                'round_number' => $round->round_number,
                'start_date' => $round->start_date?->format('Y-m-d'),
                'end_date' => $round->end_date?->format('Y-m-d'),
                'matches' => $matches->map(fn($m) => [
                    'id' => $m->id,
                    'home_team' => [
                        'id' => $m->homeTeam->id,
                        'name' => $m->homeTeam->name,
                        'short_name' => $m->homeTeam->short_name,
                        'logo' => $m->homeTeam->logo_url ?? $m->homeTeam->logo,
                    ],
                    'away_team' => [
                        'id' => $m->awayTeam->id,
                        'name' => $m->awayTeam->name,
                        'short_name' => $m->awayTeam->short_name,
                        'logo' => $m->awayTeam->logo_url ?? $m->awayTeam->logo,
                    ],
                    'match_date' => $m->match_date?->format('Y-m-d H:i'),
                    'match_date_formatted' => $m->match_date?->format('d/m/Y H:i'),
                    'venue' => $m->venue,
                    'status' => $m->status,
                    'home_score' => $m->home_score,
                    'away_score' => $m->away_score,
                ]),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'season' => [
                    'id' => $season->id,
                    'name' => $season->name,
                    'competition' => $season->competition,
                ],
                'rounds' => $rounds,
            ]
        ]);
    }

    // Update match (Sponsor - edit schedule)
    public function updateMatch(Request $request, $seasonId, $matchId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        $match = FootballMatch::whereHas('round', function($q) use ($seasonId) {
            $q->where('season_id', $seasonId);
        })->findOrFail($matchId);

        $validated = $request->validate([
            'match_date' => 'nullable|date',
            'venue' => 'nullable|string|max:255',
            'home_team_id' => 'nullable|exists:teams,id',
            'away_team_id' => 'nullable|exists:teams,id',
        ]);

        $match->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Đã cập nhật thông tin trận đấu',
            'data' => $match->load(['homeTeam', 'awayTeam']),
        ]);
    }

    // Clear schedule (Sponsor)
    public function clearSchedule(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);

        // Verify sponsor owns this season
        if ($season->sponsor_user_id !== $request->user()->id) {
            return response()->json(['message' => 'Bạn không có quyền quản lý giải đấu này'], 403);
        }

        try {
            $this->schedulingService->clearSeasonSchedule($season);

            return response()->json([
                'success' => true,
                'message' => 'Đã xóa toàn bộ lịch thi đấu',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }
}
