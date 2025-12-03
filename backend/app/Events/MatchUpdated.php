<?php

namespace App\Events;

use App\Models\FootballMatch;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MatchUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public FootballMatch $match
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
        return 'match.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'id' => $this->match->id,
            'home_team' => [
                'id' => $this->match->homeTeam->id,
                'name' => $this->match->homeTeam->name,
                'short_name' => $this->match->homeTeam->short_name,
                'logo' => $this->match->homeTeam->logo_url,
            ],
            'away_team' => [
                'id' => $this->match->awayTeam->id,
                'name' => $this->match->awayTeam->name,
                'short_name' => $this->match->awayTeam->short_name,
                'logo' => $this->match->awayTeam->logo_url,
            ],
            'home_score' => $this->match->home_score,
            'away_score' => $this->match->away_score,
            'status' => $this->match->status,
            'minute' => $this->match->minute,
            'updated_at' => $this->match->updated_at->toISOString(),
        ];
    }
}
