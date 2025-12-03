<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Player;
use App\Models\Team;
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
            ->with('players')
            ->first();

        if (!$team) {
            return response()->json(['message' => 'No team found'], 404);
        }

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
}
