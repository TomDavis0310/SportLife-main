<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get all notifications
     */
    public function index(Request $request): JsonResponse
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->paginate(30);

        return response()->json([
            'success' => true,
            'data' => NotificationResource::collection($notifications),
            'meta' => [
                'unread_count' => Notification::where('user_id', $request->user()->id)
                    ->whereNull('read_at')
                    ->count(),
            ],
        ]);
    }

    /**
     * Get unread notifications count
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'unread_count' => $count,
            ],
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Notification $notification, Request $request): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }

    /**
     * Delete a notification
     */
    public function destroy(Notification $notification, Request $request): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notification deleted',
        ]);
    }

    /**
     * Delete all read notifications
     */
    public function deleteRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNotNull('read_at')
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Read notifications deleted',
        ]);
    }

    /**
     * Update notification settings
     */
    public function updateSettings(Request $request): JsonResponse
    {
        $request->validate([
            'push_enabled' => 'boolean',
            'email_enabled' => 'boolean',
            'match_reminders' => 'boolean',
            'prediction_results' => 'boolean',
            'friend_activities' => 'boolean',
            'promotions' => 'boolean',
        ]);

        $user = $request->user();
        
        $settings = $user->notification_settings ?? [];
        $settings = array_merge($settings, $request->only([
            'push_enabled',
            'email_enabled',
            'match_reminders',
            'prediction_results',
            'friend_activities',
            'promotions',
        ]));

        $user->update(['notification_settings' => $settings]);

        return response()->json([
            'success' => true,
            'message' => 'Notification settings updated',
            'data' => $settings,
        ]);
    }

    /**
     * Get notification settings
     */
    public function getSettings(Request $request): JsonResponse
    {
        $defaults = [
            'push_enabled' => true,
            'email_enabled' => true,
            'match_reminders' => true,
            'prediction_results' => true,
            'friend_activities' => true,
            'promotions' => false,
        ];

        $settings = array_merge($defaults, $request->user()->notification_settings ?? []);

        return response()->json([
            'success' => true,
            'data' => $settings,
        ]);
    }

    /**
     * Register FCM token
     */
    public function registerFcmToken(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required|string',
            'device_type' => 'required|in:ios,android,web',
        ]);

        $user = $request->user();

        // Store FCM token (you might want to create a separate table for this)
        $tokens = $user->fcm_tokens ?? [];
        $tokens[$request->device_type] = $request->token;
        $user->update(['fcm_tokens' => $tokens]);

        return response()->json([
            'success' => true,
            'message' => 'FCM token registered',
        ]);
    }
}
