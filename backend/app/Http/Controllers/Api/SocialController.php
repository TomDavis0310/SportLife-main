<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Http\Resources\NewsResource;
use App\Models\User;
use App\Models\Team;
use App\Models\Follow;
use App\Models\UserFriend;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SocialController extends Controller
{
    /**
     * Search users
     */
    public function searchUsers(Request $request): JsonResponse
    {
        $query = User::query();

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                    ->orWhere('username', 'like', "%{$request->search}%");
            });
        }

        $users = $query->where('id', '!=', $request->user()->id)
            ->orderBy('name')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => UserResource::collection($users),
        ]);
    }

    /**
     * Get user profile
     */
    public function userProfile(User $user, Request $request): JsonResponse
    {
        $currentUser = $request->user();

        $user->loadCount(['followings', 'friends', 'predictions', 'badges']);

        // Check relationship with current user
        $isFriend = $currentUser 
            ? UserFriend::areFriends($currentUser->id, $user->id) 
            : false;

        $friendRequestSent = $currentUser
            ? UserFriend::where('user_id', $currentUser->id)
                ->where('friend_id', $user->id)
                ->where('status', 'pending')
                ->exists()
            : false;

        $friendRequestReceived = $currentUser
            ? UserFriend::where('user_id', $user->id)
                ->where('friend_id', $currentUser->id)
                ->where('status', 'pending')
                ->exists()
            : false;

        return response()->json([
            'success' => true,
            'data' => [
                'user' => new UserResource($user),
                'is_friend' => $isFriend,
                'friend_request_sent' => $friendRequestSent,
                'friend_request_received' => $friendRequestReceived,
            ],
        ]);
    }

    /**
     * Send friend request
     */
    public function sendFriendRequest(Request $request, User $user): JsonResponse
    {
        $currentUser = $request->user();

        if ($currentUser->id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot send friend request to yourself',
            ], 422);
        }

        // Check if already friends
        if (UserFriend::areFriends($currentUser->id, $user->id)) {
            return response()->json([
                'success' => false,
                'message' => 'Already friends',
            ], 422);
        }

        // Check if request already sent
        $existing = UserFriend::where('user_id', $currentUser->id)
            ->where('friend_id', $user->id)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Friend request already sent',
            ], 422);
        }

        // Check if they sent us a request (auto-accept)
        $reverseRequest = UserFriend::where('user_id', $user->id)
            ->where('friend_id', $currentUser->id)
            ->where('status', 'pending')
            ->first();

        if ($reverseRequest) {
            $reverseRequest->update(['status' => 'accepted']);

            // Create reverse friendship
            UserFriend::create([
                'user_id' => $currentUser->id,
                'friend_id' => $user->id,
                'status' => 'accepted',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'You are now friends!',
            ]);
        }

        // Send new request
        UserFriend::create([
            'user_id' => $currentUser->id,
            'friend_id' => $user->id,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Friend request sent',
        ]);
    }

    /**
     * Accept friend request
     */
    public function acceptFriendRequest(Request $request, User $user): JsonResponse
    {
        $currentUser = $request->user();

        $friendRequest = UserFriend::where('user_id', $user->id)
            ->where('friend_id', $currentUser->id)
            ->where('status', 'pending')
            ->first();

        if (!$friendRequest) {
            return response()->json([
                'success' => false,
                'message' => 'No friend request found',
            ], 404);
        }

        $friendRequest->update(['status' => 'accepted']);

        // Create reverse friendship
        UserFriend::create([
            'user_id' => $currentUser->id,
            'friend_id' => $user->id,
            'status' => 'accepted',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Friend request accepted',
        ]);
    }

    /**
     * Reject friend request
     */
    public function rejectFriendRequest(Request $request, User $user): JsonResponse
    {
        $currentUser = $request->user();

        $friendRequest = UserFriend::where('user_id', $user->id)
            ->where('friend_id', $currentUser->id)
            ->where('status', 'pending')
            ->first();

        if (!$friendRequest) {
            return response()->json([
                'success' => false,
                'message' => 'No friend request found',
            ], 404);
        }

        $friendRequest->update(['status' => 'rejected']);

        return response()->json([
            'success' => true,
            'message' => 'Friend request rejected',
        ]);
    }

    /**
     * Remove friend
     */
    public function removeFriend(Request $request, User $user): JsonResponse
    {
        $currentUser = $request->user();

        // Delete both directions
        UserFriend::where(function ($q) use ($currentUser, $user) {
            $q->where('user_id', $currentUser->id)
                ->where('friend_id', $user->id);
        })->orWhere(function ($q) use ($currentUser, $user) {
            $q->where('user_id', $user->id)
                ->where('friend_id', $currentUser->id);
        })->delete();

        return response()->json([
            'success' => true,
            'message' => 'Friend removed',
        ]);
    }

    /**
     * Get friend requests
     */
    public function friendRequests(Request $request): JsonResponse
    {
        $requests = UserFriend::where('friend_id', $request->user()->id)
            ->where('status', 'pending')
            ->with('user')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $requests,
        ]);
    }

    /**
     * Get friends list
     */
    public function friends(Request $request): JsonResponse
    {
        $friends = $request->user()->friends()
            ->orderBy('name')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => UserResource::collection($friends),
        ]);
    }

    /**
     * Get followed teams
     */
    public function followedTeams(Request $request): JsonResponse
    {
        $follows = Follow::where('user_id', $request->user()->id)
            ->where('followable_type', Team::class)
            ->with('followable')
            ->get();

        $teams = $follows->map(fn($f) => $f->followable);

        return response()->json([
            'success' => true,
            'data' => $teams,
        ]);
    }

    /**
     * Get activity feed (friends' activities)
     */
    public function feed(Request $request): JsonResponse
    {
        $user = $request->user();
        $friendIds = $user->friends()->pluck('users.id');

        // Get friends' recent predictions
        $predictions = \App\Models\Prediction::whereIn('user_id', $friendIds)
            ->with(['user', 'match.homeTeam', 'match.awayTeam'])
            ->orderByDesc('created_at')
            ->limit(20)
            ->get();

        // Get friends' recent badges
        $badges = \App\Models\UserBadge::whereIn('user_id', $friendIds)
            ->with(['user', 'badge'])
            ->orderByDesc('earned_at')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'predictions' => $predictions,
                'badges' => $badges,
            ],
        ]);
    }
}
