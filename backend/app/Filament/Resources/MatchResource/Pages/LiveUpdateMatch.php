<?php

namespace App\Filament\Resources\MatchResource\Pages;

use App\Filament\Resources\MatchResource;
use App\Models\FootballMatch;
use App\Models\MatchEvent;
use App\Enums\MatchStatus;
use App\Enums\MatchEventType;
use App\Events\MatchUpdated;
use App\Events\GoalScored;
use App\Jobs\CalculatePredictionPoints;
use App\Jobs\SendMatchNotification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\Page;

class LiveUpdateMatch extends Page
{
    protected static string $resource = MatchResource::class;

    protected static string $view = 'filament.resources.match-resource.pages.live-update-match';

    public ?FootballMatch $record = null;

    public ?int $homeScore = null;
    public ?int $awayScore = null;
    public ?int $minute = null;
    public ?string $status = null;

    public function mount(int | string $record): void
    {
        $this->record = FootballMatch::findOrFail($record);
        $this->homeScore = $this->record->home_score ?? 0;
        $this->awayScore = $this->record->away_score ?? 0;
        $this->minute = $this->record->minute ?? 0;
        $this->status = $this->record->status?->value ?? MatchStatus::SCHEDULED->value;
    }

    public function getTitle(): string
    {
        return "Live Update: {$this->record->homeTeam->name} vs {$this->record->awayTeam->name}";
    }

    public function startMatch(): void
    {
        $this->record->update([
            'status' => MatchStatus::FIRST_HALF,
            'home_score' => 0,
            'away_score' => 0,
            'minute' => 1,
        ]);

        $this->status = MatchStatus::FIRST_HALF->value;
        $this->minute = 1;
        $this->homeScore = 0;
        $this->awayScore = 0;

        event(new MatchUpdated($this->record));
        SendMatchNotification::dispatch($this->record, 'kickoff');

        Notification::make()
            ->title('Match Started!')
            ->success()
            ->send();
    }

    public function updateScore(): void
    {
        $this->record->update([
            'home_score' => $this->homeScore,
            'away_score' => $this->awayScore,
            'minute' => $this->minute,
        ]);

        event(new MatchUpdated($this->record));

        Notification::make()
            ->title('Score Updated!')
            ->success()
            ->send();
    }

    public function addGoal(string $team): void
    {
        if ($team === 'home') {
            $this->homeScore++;
            $teamId = $this->record->home_team_id;
        } else {
            $this->awayScore++;
            $teamId = $this->record->away_team_id;
        }

        $this->record->update([
            'home_score' => $this->homeScore,
            'away_score' => $this->awayScore,
        ]);

        $event = MatchEvent::create([
            'match_id' => $this->record->id,
            'team_id' => $teamId,
            'event_type' => MatchEventType::GOAL,
            'minute' => $this->minute,
            'description' => 'Goal!',
        ]);

        event(new GoalScored($this->record, $event));
        SendMatchNotification::dispatch($this->record, 'goal', ['scorer' => 'Goal!']);

        Notification::make()
            ->title('Goal Added!')
            ->success()
            ->send();
    }

    public function halfTime(): void
    {
        $this->record->update([
            'status' => MatchStatus::HALFTIME,
            'home_score_ht' => $this->homeScore,
            'away_score_ht' => $this->awayScore,
            'minute' => 45,
        ]);

        $this->status = MatchStatus::HALFTIME->value;
        $this->minute = 45;

        event(new MatchUpdated($this->record));
        SendMatchNotification::dispatch($this->record, 'halftime');

        Notification::make()
            ->title('Half Time!')
            ->warning()
            ->send();
    }

    public function startSecondHalf(): void
    {
        $this->record->update([
            'status' => MatchStatus::SECOND_HALF,
            'minute' => 46,
        ]);

        $this->status = MatchStatus::SECOND_HALF->value;
        $this->minute = 46;

        event(new MatchUpdated($this->record));

        Notification::make()
            ->title('Second Half Started!')
            ->success()
            ->send();
    }

    public function startExtraTime(): void
    {
        $minute = max($this->minute ?? 90, 91);

        $this->record->update([
            'status' => MatchStatus::EXTRA_TIME,
            'minute' => $minute,
        ]);

        $this->status = MatchStatus::EXTRA_TIME->value;
        $this->minute = $minute;

        event(new MatchUpdated($this->record));

        Notification::make()
            ->title('Extra Time Started!')
            ->success()
            ->send();
    }

    public function startPenalties(): void
    {
        $minute = max($this->minute ?? 120, 121);

        $this->record->update([
            'status' => MatchStatus::PENALTIES,
            'minute' => $minute,
        ]);

        $this->status = MatchStatus::PENALTIES->value;
        $this->minute = $minute;

        event(new MatchUpdated($this->record));

        Notification::make()
            ->title('Penalty Shoot-out!')
            ->warning()
            ->send();
    }

    public function endMatch(): void
    {
        $this->record->update([
            'status' => MatchStatus::FINISHED,
            'minute' => 90,
        ]);

        $this->status = MatchStatus::FINISHED->value;
        $this->minute = 90;

        event(new MatchUpdated($this->record));
        SendMatchNotification::dispatch($this->record, 'fulltime');
        CalculatePredictionPoints::dispatch($this->record);

        Notification::make()
            ->title('Match Finished!')
            ->success()
            ->send();
    }
}
