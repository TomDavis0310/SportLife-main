<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Player;
use App\Models\Team;
use App\Models\TeamStaff;
use Illuminate\Http\Request;

class TeamManagementController extends Controller
{
    public function getMyTeam(Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)
            ->with(['players', 'staff'])
            ->first();

        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        return response()->json(['success' => true, 'data' => $team]);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'stadium' => 'sometimes|string|max:255',
            'city' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'founded_year' => 'nullable|integer|min:1800|max:' . (date('Y')),
            'primary_color' => 'sometimes|string|regex:/^#[a-fA-F0-9]{6}$/',
            'secondary_color' => 'sometimes|string|regex:/^#[a-fA-F0-9]{6}$/',
        ]);

        $team->update($validated);

        return response()->json(['success' => true, 'data' => $team]);
    }

    public function addPlayer(Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $validated = $request->validate([
            'name' => 'required|string',
            'position' => 'required|string', // Goalkeeper, Defender, Midfielder, Forward
            'jersey_number' => 'required|integer',
        ]);

        $player = $team->players()->create([
            'name' => $validated['name'],
            'position' => $validated['position'],
            'jersey_number' => $validated['jersey_number'],
            'is_active' => true,
        ]);

        return response()->json(['success' => true, 'data' => $player]);
    }

    public function removePlayer(Request $request, $playerId)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $player = Player::where('id', $playerId)->where('team_id', $team->id)->first();
        if (!$player) {
            return response()->json(['message' => 'Player not found in your team'], 404);
        }

        $player->delete(); // Or set is_active = false

        return response()->json(['success' => true, 'message' => 'Player removed']);
    }

    public function updatePlayer(Request $request, $playerId)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $player = Player::where('id', $playerId)->where('team_id', $team->id)->first();
        if (!$player) {
            return response()->json(['message' => 'Player not found in your team'], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string',
            'position' => 'sometimes|string',
            'jersey_number' => 'sometimes|integer',
            'avatar' => 'nullable|string',
            'market_value' => 'nullable|numeric',
            'nationality' => 'nullable|string',
            'height' => 'nullable|integer',
            'weight' => 'nullable|integer',
            'birth_date' => 'nullable|date',
            'contract_until' => 'nullable|date',
        ]);

        $player->update($validated);

        return response()->json(['success' => true, 'data' => $player]);
    }

    public function addStaff(Request $request)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $validated = $request->validate([
            'name' => 'required|string',
            'role' => 'required|string',
            'nationality' => 'nullable|string',
            'avatar' => 'nullable|string',
        ]);

        $staff = TeamStaff::create([
            'team_id' => $team->id,
            'name' => $validated['name'],
            'role' => $validated['role'],
            'nationality' => $validated['nationality'] ?? null,
            'avatar' => $validated['avatar'] ?? null,
        ]);

        return response()->json(['success' => true, 'data' => $staff]);
    }

    public function removeStaff(Request $request, $staffId)
    {
        $user = $request->user();
        if (!$user->hasRole('club_manager')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = Team::where('manager_user_id', $user->id)->first();
        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

        $staff = TeamStaff::where('id', $staffId)->where('team_id', $team->id)->first();
        if (!$staff) {
            return response()->json(['message' => 'Staff not found'], 404);
        }

        $staff->delete();

        return response()->json(['success' => true, 'message' => 'Staff removed']);
    }
}
