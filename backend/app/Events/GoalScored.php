<?php

namespace App\Events;

use App\Models\MatchEvent;
use App\Models\FootballMatch;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class GoalScored implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public FootballMatch $match,
        public MatchEvent $event
    ) {}

    public function broadcastOn(): array
    {
        return [
            new Channel('matches'),
            new Channel("match.{$this->match->id}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'goal.scored';
    }

    public function broadcastWith(): array
    {
        return [
            'match_id' => $this->match->id,
            'home_score' => $this->match->home_score,
            'away_score' => $this->match->away_score,
            'event' => [
                'id' => $this->event->id,
                'type' => $this->event->event_type,
                'minute' => $this->event->minute,
                'team_id' => $this->event->team_id,
                'player' => $this->event->player?->name,
                'description' => $this->event->description,
            ],
        ];
    }
}
