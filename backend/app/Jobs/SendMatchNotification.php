<?php

namespace App\Jobs;

use App\Models\FootballMatch;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FCMNotification;

class SendMatchNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public FootballMatch $match,
        public string $type,
        public ?array $extra = null
    ) {}

    public function handle(): void
    {
        // Get users who follow either team or have predictions for this match
        $userIds = collect();

        // Users following home team
        $homeFollowers = $this->match->homeTeam->followers()->pluck('user_id');
        $userIds = $userIds->merge($homeFollowers);

        // Users following away team
        $awayFollowers = $this->match->awayTeam->followers()->pluck('user_id');
        $userIds = $userIds->merge($awayFollowers);

        // Users with predictions
        $predictors = $this->match->predictions()->pluck('user_id');
        $userIds = $userIds->merge($predictors);

        $userIds = $userIds->unique();

        // Build notification content
        $notification = $this->buildNotification();

        // Create in-app notifications
        foreach ($userIds as $userId) {
            Notification::create([
                'user_id' => $userId,
                'type' => "match_{$this->type}",
                'title' => $notification['title'],
                'body' => $notification['body'],
                'data' => [
                    'match_id' => $this->match->id,
                    'type' => $this->type,
                    ...$this->extra ?? [],
                ],
            ]);
        }

        // Send FCM push notifications
        $this->sendPushNotifications($userIds->toArray(), $notification);
    }

    private function buildNotification(): array
    {
        $homeTeam = $this->match->homeTeam->short_name;
        $awayTeam = $this->match->awayTeam->short_name;
        $score = "{$this->match->home_score} - {$this->match->away_score}";

        return match ($this->type) {
            'kickoff' => [
                'title' => '⚽ Match Started!',
                'body' => "{$homeTeam} vs {$awayTeam} has kicked off!",
            ],
            'goal' => [
                'title' => '⚽ GOAL!',
                'body' => "{$homeTeam} {$score} {$awayTeam} - " . ($this->extra['scorer'] ?? 'Goal scored!'),
            ],
            'halftime' => [
                'title' => '⏱️ Half Time',
                'body' => "{$homeTeam} {$score} {$awayTeam}",
            ],
            'fulltime' => [
                'title' => '🏁 Full Time',
                'body' => "{$homeTeam} {$score} {$awayTeam}",
            ],
            'red_card' => [
                'title' => '🟥 Red Card!',
                'body' => ($this->extra['player'] ?? 'A player') . " has been sent off!",
            ],
            'reminder' => [
                'title' => '⏰ Match Reminder',
                'body' => "{$homeTeam} vs {$awayTeam} starts in 30 minutes. Make your prediction!",
            ],
            default => [
                'title' => 'Match Update',
                'body' => "{$homeTeam} vs {$awayTeam}",
            ],
        };
    }

    private function sendPushNotifications(array $userIds, array $notification): void
    {
        try {
            $messaging = app('firebase.messaging');

            $users = User::whereIn('id', $userIds)
                ->whereNotNull('fcm_tokens')
                ->get();

            foreach ($users as $user) {
                $tokens = $user->fcm_tokens ?? [];

                foreach ($tokens as $token) {
                    if (!$token) continue;

                    $message = CloudMessage::withTarget('token', $token)
                        ->withNotification(FCMNotification::create(
                            $notification['title'],
                            $notification['body']
                        ))
                        ->withData([
                            'match_id' => (string) $this->match->id,
                            'type' => $this->type,
                            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                        ]);

                    try {
                        $messaging->send($message);
                    } catch (\Exception $e) {
                        // Log failed token, potentially remove invalid tokens
                        \Log::warning("FCM send failed for user {$user->id}: {$e->getMessage()}");
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::error("FCM batch send failed: {$e->getMessage()}");
        }
    }
}
