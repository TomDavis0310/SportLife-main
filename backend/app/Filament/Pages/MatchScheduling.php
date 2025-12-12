<?php

namespace App\Filament\Pages;

use App\Models\FootballMatch;
use App\Models\Round;
use App\Models\Season;
use App\Models\Team;
use App\Services\MatchSchedulingService;
use Filament\Actions\Action;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Tabs;
use Filament\Forms\Components\Tabs\Tab;
use Filament\Forms\Components\TagsInput;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Wizard;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Tables\Actions\ActionGroup;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;
use Illuminate\Support\Carbon;

class MatchScheduling extends Page implements HasForms, HasTable
{
    use InteractsWithForms;
    use InteractsWithTable;

    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?string $navigationLabel = 'Xếp lịch thi đấu';
    protected static ?string $title = 'Xếp lịch thi đấu';
    protected static ?string $navigationGroup = 'Quản lý giải đấu';
    protected static ?int $navigationSort = 5;

    protected static string $view = 'filament.pages.match-scheduling';

    public ?int $selectedSeasonId = null;
    public ?int $selectedRoundId = null;
    public ?string $scheduleType = 'home_away';
    public ?string $startDate = null;
    public array $timeSlots = ['15:00', '17:30', '19:00', '21:00'];
    public array $matchDays = [0, 6]; // Sunday, Saturday
    public int $matchesPerDay = 4;
    public bool $clearExisting = false;
    public array $previewSchedule = [];

    // Manual match creation
    public ?int $manualRoundId = null;
    public ?int $homeTeamId = null;
    public ?int $awayTeamId = null;
    public ?string $matchDate = null;
    public ?string $venue = null;

    protected MatchSchedulingService $schedulingService;

    public function boot(MatchSchedulingService $schedulingService)
    {
        $this->schedulingService = $schedulingService;
    }

    public function mount(): void
    {
        $currentSeason = Season::where('is_current', true)->first();
        if ($currentSeason) {
            $this->selectedSeasonId = $currentSeason->id;
        }
        $this->startDate = now()->addWeek()->format('Y-m-d');
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('autoSchedule')
                ->label('Tự động xếp lịch')
                ->icon('heroicon-o-sparkles')
                ->color('primary')
                ->form([
                    Select::make('season_id')
                        ->label('Mùa giải')
                        ->options(Season::with('competition')->get()->pluck('name', 'id'))
                        ->required()
                        ->default($this->selectedSeasonId),
                    Radio::make('type')
                        ->label('Loại lịch thi đấu')
                        ->options([
                            'round_robin' => 'Vòng tròn 1 lượt',
                            'home_away' => 'Vòng tròn 2 lượt (sân nhà - sân khách)',
                            'single_elimination' => 'Loại trực tiếp',
                            'group_stage' => 'Vòng bảng',
                        ])
                        ->default('home_away')
                        ->required(),
                    DatePicker::make('start_date')
                        ->label('Ngày bắt đầu')
                        ->default(now()->addWeek())
                        ->required(),
                    TagsInput::make('time_slots')
                        ->label('Khung giờ thi đấu')
                        ->placeholder('Thêm khung giờ')
                        ->default(['15:00', '17:30', '19:00', '21:00']),
                    Select::make('match_days')
                        ->label('Ngày thi đấu trong tuần')
                        ->multiple()
                        ->options([
                            0 => 'Chủ nhật',
                            1 => 'Thứ 2',
                            2 => 'Thứ 3',
                            3 => 'Thứ 4',
                            4 => 'Thứ 5',
                            5 => 'Thứ 6',
                            6 => 'Thứ 7',
                        ])
                        ->default([0, 6]),
                    TextInput::make('matches_per_day')
                        ->label('Số trận/ngày')
                        ->numeric()
                        ->default(4)
                        ->minValue(1)
                        ->maxValue(20),
                    Toggle::make('clear_existing')
                        ->label('Xóa lịch hiện tại trước khi tạo mới')
                        ->default(false),
                ])
                ->action(function (array $data) {
                    $this->generateAutoSchedule($data);
                }),

            Action::make('manualMatch')
                ->label('Thêm trận đấu')
                ->icon('heroicon-o-plus')
                ->color('success')
                ->form([
                    Select::make('round_id')
                        ->label('Vòng đấu')
                        ->options(function () {
                            return Round::whereHas('season', fn($q) => $q->where('id', $this->selectedSeasonId))
                                ->orderBy('round_number')
                                ->pluck('name', 'id');
                        })
                        ->required()
                        ->searchable(),
                    Grid::make(2)->schema([
                        Select::make('home_team_id')
                            ->label('Đội nhà')
                            ->options(function () {
                                if (!$this->selectedSeasonId) return [];
                                $season = Season::find($this->selectedSeasonId);
                                return $season?->teams()->pluck('name', 'teams.id') ?? [];
                            })
                            ->required()
                            ->searchable(),
                        Select::make('away_team_id')
                            ->label('Đội khách')
                            ->options(function () {
                                if (!$this->selectedSeasonId) return [];
                                $season = Season::find($this->selectedSeasonId);
                                return $season?->teams()->pluck('name', 'teams.id') ?? [];
                            })
                            ->required()
                            ->searchable()
                            ->different('home_team_id'),
                    ]),
                    DateTimePicker::make('match_date')
                        ->label('Ngày giờ thi đấu')
                        ->required(),
                    TextInput::make('venue')
                        ->label('Sân vận động')
                        ->maxLength(255),
                ])
                ->action(function (array $data) {
                    $this->createManualMatch($data);
                }),

            Action::make('createRound')
                ->label('Thêm vòng đấu')
                ->icon('heroicon-o-folder-plus')
                ->color('warning')
                ->form([
                    Select::make('season_id')
                        ->label('Mùa giải')
                        ->options(Season::pluck('name', 'id'))
                        ->default($this->selectedSeasonId)
                        ->required(),
                    TextInput::make('name')
                        ->label('Tên vòng đấu')
                        ->required()
                        ->maxLength(100),
                    TextInput::make('round_number')
                        ->label('Số thứ tự vòng')
                        ->numeric()
                        ->minValue(1),
                    Grid::make(2)->schema([
                        DatePicker::make('start_date')
                            ->label('Ngày bắt đầu'),
                        DatePicker::make('end_date')
                            ->label('Ngày kết thúc'),
                    ]),
                ])
                ->action(function (array $data) {
                    $this->createRound($data);
                }),
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(
                FootballMatch::query()
                    ->when($this->selectedRoundId, fn($q) => $q->where('round_id', $this->selectedRoundId))
                    ->when(
                        !$this->selectedRoundId && $this->selectedSeasonId,
                        fn($q) => $q->whereHas('round', fn($r) => $r->where('season_id', $this->selectedSeasonId))
                    )
                    ->with(['homeTeam', 'awayTeam', 'round'])
                    ->orderBy('match_date')
            )
            ->columns([
                TextColumn::make('round.name')
                    ->label('Vòng')
                    ->sortable(),
                TextColumn::make('homeTeam.name')
                    ->label('Đội nhà')
                    ->searchable(),
                TextColumn::make('score')
                    ->label('Tỉ số')
                    ->getStateUsing(fn($record) => $record->status === 'finished' 
                        ? "{$record->home_score} - {$record->away_score}" 
                        : 'vs'),
                TextColumn::make('awayTeam.name')
                    ->label('Đội khách')
                    ->searchable(),
                TextColumn::make('match_date')
                    ->label('Ngày giờ')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
                TextColumn::make('venue')
                    ->label('Sân')
                    ->limit(20),
                TextColumn::make('status')
                    ->label('Trạng thái')
                    ->badge()
                    ->color(fn($state) => match ($state?->value ?? $state) {
                        'scheduled' => 'gray',
                        'live', '1H', '2H', 'HT' => 'success',
                        'finished' => 'primary',
                        'postponed' => 'warning',
                        'cancelled' => 'danger',
                        default => 'gray',
                    }),
            ])
            ->filters([
                //
            ])
            ->actions([
                ActionGroup::make([
                    EditAction::make()
                        ->form([
                            DateTimePicker::make('match_date')
                                ->label('Ngày giờ thi đấu')
                                ->required(),
                            TextInput::make('venue')
                                ->label('Sân vận động'),
                            Select::make('round_id')
                                ->label('Vòng đấu')
                                ->options(fn($record) => Round::where('season_id', $record->round?->season_id)
                                    ->pluck('name', 'id')),
                        ]),
                    \Filament\Tables\Actions\Action::make('reschedule')
                        ->label('Dời lịch')
                        ->icon('heroicon-o-clock')
                        ->form([
                            DateTimePicker::make('new_date')
                                ->label('Ngày giờ mới')
                                ->required(),
                            TextInput::make('reason')
                                ->label('Lý do dời lịch'),
                        ])
                        ->action(function ($record, array $data) {
                            $record->update(['match_date' => $data['new_date']]);
                            Notification::make()
                                ->title('Đã dời lịch trận đấu')
                                ->success()
                                ->send();
                        }),
                    \Filament\Tables\Actions\Action::make('swapTeams')
                        ->label('Đổi sân')
                        ->icon('heroicon-o-arrows-right-left')
                        ->requiresConfirmation()
                        ->action(function ($record) {
                            $homeId = $record->home_team_id;
                            $awayId = $record->away_team_id;
                            $record->update([
                                'home_team_id' => $awayId,
                                'away_team_id' => $homeId,
                                'venue' => Team::find($awayId)?->stadium,
                            ]);
                            Notification::make()
                                ->title('Đã đổi sân')
                                ->success()
                                ->send();
                        }),
                    DeleteAction::make()
                        ->requiresConfirmation(),
                ]),
            ])
            ->bulkActions([
                \Filament\Tables\Actions\BulkAction::make('bulkDelete')
                    ->label('Xóa đã chọn')
                    ->icon('heroicon-o-trash')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->action(fn($records) => $records->each->delete()),
            ]);
    }

    public function generateAutoSchedule(array $data): void
    {
        try {
            $season = Season::findOrFail($data['season_id']);
            $schedulingService = app(MatchSchedulingService::class);

            if ($data['clear_existing'] ?? false) {
                $schedulingService->clearSeasonSchedule($season);
            }

            $schedule = $schedulingService->generateSchedule($season, $data['type'], [
                'start_date' => $data['start_date'],
                'time_slots' => $data['time_slots'] ?? ['15:00', '17:30', '19:00', '21:00'],
                'match_days' => array_map('intval', $data['match_days'] ?? [0, 6]),
                'matches_per_day' => $data['matches_per_day'] ?? 4,
            ]);

            $result = $schedulingService->saveSchedule($season, $schedule);

            Notification::make()
                ->title('Tạo lịch thành công')
                ->body("Đã tạo {$result['summary']['total_rounds']} vòng đấu với {$result['summary']['total_matches']} trận")
                ->success()
                ->send();

            $this->selectedSeasonId = $season->id;
        } catch (\Exception $e) {
            Notification::make()
                ->title('Lỗi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function createManualMatch(array $data): void
    {
        try {
            $match = FootballMatch::create([
                'round_id' => $data['round_id'],
                'home_team_id' => $data['home_team_id'],
                'away_team_id' => $data['away_team_id'],
                'match_date' => $data['match_date'],
                'venue' => $data['venue'] ?? Team::find($data['home_team_id'])?->stadium,
                'status' => 'scheduled',
            ]);

            Notification::make()
                ->title('Đã tạo trận đấu')
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Lỗi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function createRound(array $data): void
    {
        try {
            $season = Season::findOrFail($data['season_id']);
            $roundNumber = $data['round_number'] ?? (Round::where('season_id', $season->id)->max('round_number') + 1);

            $round = Round::create([
                'season_id' => $season->id,
                'name' => $data['name'],
                'round_number' => $roundNumber,
                'start_date' => $data['start_date'],
                'end_date' => $data['end_date'],
                'is_current' => false,
            ]);

            Notification::make()
                ->title('Đã tạo vòng đấu')
                ->body("Vòng đấu: {$round->name}")
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Lỗi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function clearSeasonSchedule(): void
    {
        if (!$this->selectedSeasonId) {
            Notification::make()
                ->title('Vui lòng chọn mùa giải')
                ->warning()
                ->send();
            return;
        }

        try {
            $season = Season::findOrFail($this->selectedSeasonId);
            $schedulingService = app(MatchSchedulingService::class);
            $deletedCount = $schedulingService->clearSeasonSchedule($season);

            Notification::make()
                ->title('Đã xóa lịch thi đấu')
                ->body("Đã xóa $deletedCount trận đấu")
                ->success()
                ->send();
        } catch (\Exception $e) {
            Notification::make()
                ->title('Lỗi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function checkConflicts(): void
    {
        if (!$this->selectedSeasonId) {
            Notification::make()
                ->title('Vui lòng chọn mùa giải')
                ->warning()
                ->send();
            return;
        }

        try {
            $season = Season::findOrFail($this->selectedSeasonId);
            $schedulingService = app(MatchSchedulingService::class);
            $conflicts = $schedulingService->getSchedulingConflicts($season);

            if (empty($conflicts)) {
                Notification::make()
                    ->title('Không có xung đột')
                    ->body('Lịch thi đấu không có vấn đề')
                    ->success()
                    ->send();
            } else {
                $message = "Phát hiện " . count($conflicts) . " xung đột:\n";
                foreach (array_slice($conflicts, 0, 5) as $conflict) {
                    $message .= "- {$conflict['type']}: {$conflict['team_name']}\n";
                }
                
                Notification::make()
                    ->title('Có xung đột lịch thi đấu')
                    ->body($message)
                    ->warning()
                    ->send();
            }
        } catch (\Exception $e) {
            Notification::make()
                ->title('Lỗi')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    public function getSeasons()
    {
        return Season::with('competition')
            ->withCount(['teams', 'rounds'])
            ->orderByDesc('is_current')
            ->orderByDesc('start_date')
            ->get();
    }

    public function getRounds()
    {
        if (!$this->selectedSeasonId) {
            return collect();
        }

        return Round::where('season_id', $this->selectedSeasonId)
            ->withCount('matches')
            ->orderBy('round_number')
            ->get();
    }

    public function selectSeason($seasonId)
    {
        $this->selectedSeasonId = $seasonId;
        $this->selectedRoundId = null;
    }

    public function selectRound($roundId)
    {
        $this->selectedRoundId = $roundId;
    }
}
