<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Competition;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TournamentController extends Controller
{
    // List competitions/seasons
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->hasRole('sponsor')) {
            // Sponsors see all competitions they can manage (for now all)
            $competitions = Competition::with(['seasons' => function($q) {
                $q->withCount('teams');
            }])->get();
        } else {
            // Managers see active competitions to register
            $competitions = Competition::where('is_active', true)
                ->with(['seasons' => function($q) {
                    $q->where('is_current', true);
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
            'season_name' => 'required|string', // e.g. 2025
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
        ]);

        DB::beginTransaction();
        try {
            $competition = Competition::create([
                'name' => $validated['name'],
                'type' => $validated['type'],
                'is_active' => true,
            ]);

            $season = $competition->seasons()->create([
                'name' => $validated['season_name'],
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
                'is_current' => true,
            ]);

            DB::commit();
            return response()->json(['success' => true, 'data' => $competition->load('seasons')]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
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
        
        // Check if already registered
        if ($season->teams()->where('team_id', $team->id)->exists()) {
            return response()->json(['message' => 'Team already registered'], 422);
        }

        $season->teams()->attach($team->id, ['status' => 'pending']);

        return response()->json(['success' => true, 'message' => 'Registration submitted']);
    }

    // Get registrations (Sponsor)
    public function getRegistrations(Request $request, $seasonId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);
        $teams = $season->teams()->get();

        return response()->json(['success' => true, 'data' => $teams]);
    }

    // Approve registration (Sponsor)
    public function approveRegistration(Request $request, $seasonId, $teamId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season = Season::findOrFail($seasonId);
        $season->teams()->updateExistingPivot($teamId, ['status' => 'approved']);

        return response()->json(['success' => true, 'message' => 'Team approved']);
    }

    // Update competition (Sponsor only)
    public function update(Request $request, $competitionId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string',
            'type' => 'required|in:league,cup',
        ]);

        $competition = Competition::findOrFail($competitionId);
        $competition->update($validated);

        return response()->json(['success' => true, 'data' => $competition->load('seasons')]);
    }

    // Delete competition (Sponsor only)
    public function destroy(Request $request, $competitionId)
    {
        if (!$request->user()->hasRole('sponsor')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $competition = Competition::findOrFail($competitionId);
        $competition->delete();

        return response()->json(['success' => true, 'message' => 'Competition deleted successfully']);
    }
}
