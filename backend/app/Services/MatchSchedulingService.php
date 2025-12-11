<?php

namespace App\Services;

use App\Models\FootballMatch;
use App\Models\Round;
use App\Models\Season;
use App\Models\Team;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class MatchSchedulingService
{
    /**
     * Schedule type constants
     */
    const TYPE_ROUND_ROBIN = 'round_robin';
    const TYPE_HOME_AWAY = 'home_away';
    const TYPE_SINGLE_ELIMINATION = 'single_elimination';
    const TYPE_GROUP_STAGE = 'group_stage';

    /**
     * Default match time slots
     */
    protected array $defaultTimeSlots = [
        '15:00', '17:30', '19:00', '21:00'
    ];

    /**
     * Default match days (0 = Sunday, 6 = Saturday)
     */
    protected array $defaultMatchDays = [0, 6]; // Weekend

    /**
     * Generate automatic schedule for a season
     */
    public function generateSchedule(
        Season $season,
        string $type = self::TYPE_HOME_AWAY,
        array $options = []
    ): array {
        $teams = $season->teams()->where('is_active', true)->get();
        
        if ($teams->count() < 2) {
            throw new \InvalidArgumentException('Cần ít nhất 2 đội để xếp lịch');
        }

        $startDate = Carbon::parse($options['start_date'] ?? $season->start_date);
        $timeSlots = $options['time_slots'] ?? $this->defaultTimeSlots;
        $matchDays = $options['match_days'] ?? $this->defaultMatchDays;
        $venue = $options['venue'] ?? null;
        $matchesPerDay = $options['matches_per_day'] ?? 4;

        return match ($type) {
            self::TYPE_ROUND_ROBIN => $this->generateRoundRobin($season, $teams, $startDate, $timeSlots, $matchDays, $venue, $matchesPerDay, false),
            self::TYPE_HOME_AWAY => $this->generateRoundRobin($season, $teams, $startDate, $timeSlots, $matchDays, $venue, $matchesPerDay, true),
            self::TYPE_SINGLE_ELIMINATION => $this->generateSingleElimination($season, $teams, $startDate, $timeSlots, $venue),
            self::TYPE_GROUP_STAGE => $this->generateGroupStage($season, $teams, $startDate, $timeSlots, $matchDays, $venue, $options),
            default => throw new \InvalidArgumentException("Loại lịch không hợp lệ: $type"),
        };
    }

    /**
     * Generate Round Robin schedule (each team plays every other team once or twice)
     */
    protected function generateRoundRobin(
        Season $season,
        Collection $teams,
        Carbon $startDate,
        array $timeSlots,
        array $matchDays,
        ?string $venue,
        int $matchesPerDay,
        bool $homeAndAway
    ): array {
        $teamIds = $teams->pluck('id')->toArray();
        $numTeams = count($teamIds);
        
        // If odd number of teams, add a "bye" team
        if ($numTeams % 2 !== 0) {
            $teamIds[] = null; // bye
            $numTeams++;
        }

        $rounds = [];
        $numRounds = $numTeams - 1;
        
        // Generate first leg
        for ($round = 0; $round < $numRounds; $round++) {
            $roundMatches = [];
            
            for ($match = 0; $match < $numTeams / 2; $match++) {
                $home = ($round + $match) % ($numTeams - 1);
                $away = ($numTeams - 1 - $match + $round) % ($numTeams - 1);
                
                // Last team stays in place
                if ($match === 0) {
                    $away = $numTeams - 1;
                }
                
                // Skip bye matches
                if ($teamIds[$home] !== null && $teamIds[$away] !== null) {
                    // Alternate home/away for fairness
                    if ($round % 2 === 0) {
                        $roundMatches[] = [
                            'home_team_id' => $teamIds[$home],
                            'away_team_id' => $teamIds[$away],
                        ];
                    } else {
                        $roundMatches[] = [
                            'home_team_id' => $teamIds[$away],
                            'away_team_id' => $teamIds[$home],
                        ];
                    }
                }
            }
            
            $rounds[] = [
                'round_number' => $round + 1,
                'name' => 'Vòng ' . ($round + 1),
                'matches' => $roundMatches,
            ];
        }

        // Generate second leg (reverse fixtures) if home and away
        if ($homeAndAway) {
            foreach ($rounds as $index => $round) {
                $reversedMatches = [];
                foreach ($round['matches'] as $match) {
                    $reversedMatches[] = [
                        'home_team_id' => $match['away_team_id'],
                        'away_team_id' => $match['home_team_id'],
                    ];
                }
                
                $rounds[] = [
                    'round_number' => $numRounds + $index + 1,
                    'name' => 'Vòng ' . ($numRounds + $index + 1),
                    'matches' => $reversedMatches,
                ];
            }
        }

        // Assign dates to matches
        return $this->assignDatesToRounds($rounds, $startDate, $timeSlots, $matchDays, $venue, $matchesPerDay);
    }

    /**
     * Generate Single Elimination (Knockout) schedule
     */
    protected function generateSingleElimination(
        Season $season,
        Collection $teams,
        Carbon $startDate,
        array $timeSlots,
        ?string $venue
    ): array {
        $teamIds = $teams->shuffle()->pluck('id')->toArray();
        $numTeams = count($teamIds);
        
        // Find next power of 2
        $bracketSize = pow(2, ceil(log($numTeams, 2)));
        
        // Add byes if needed
        $byes = $bracketSize - $numTeams;
        for ($i = 0; $i < $byes; $i++) {
            $teamIds[] = null;
        }

        $rounds = [];
        $roundNumber = 1;
        $currentTeams = $teamIds;
        
        $roundNames = [
            2 => 'Chung kết',
            4 => 'Bán kết',
            8 => 'Tứ kết',
            16 => 'Vòng 16',
            32 => 'Vòng 32',
        ];

        while (count($currentTeams) > 1) {
            $roundMatches = [];
            $nextRoundTeams = [];
            
            for ($i = 0; $i < count($currentTeams); $i += 2) {
                $home = $currentTeams[$i];
                $away = $currentTeams[$i + 1];
                
                // Handle byes
                if ($home === null) {
                    $nextRoundTeams[] = $away;
                    continue;
                }
                if ($away === null) {
                    $nextRoundTeams[] = $home;
                    continue;
                }
                
                $roundMatches[] = [
                    'home_team_id' => $home,
                    'away_team_id' => $away,
                ];
                
                // Placeholder for winner
                $nextRoundTeams[] = 'winner_' . count($roundMatches);
            }
            
            if (!empty($roundMatches)) {
                $numMatchesInRound = count($currentTeams) / 2;
                $roundName = $roundNames[$numMatchesInRound] ?? "Vòng $roundNumber";
                
                $rounds[] = [
                    'round_number' => $roundNumber,
                    'name' => $roundName,
                    'matches' => $roundMatches,
                ];
                $roundNumber++;
            }
            
            $currentTeams = $nextRoundTeams;
        }

        // Assign dates (1 week between rounds)
        $currentDate = $startDate->copy();
        foreach ($rounds as &$round) {
            $matchDate = $currentDate->copy();
            $timeIndex = 0;
            
            foreach ($round['matches'] as &$match) {
                $match['match_date'] = $matchDate->copy()->setTimeFromTimeString($timeSlots[$timeIndex % count($timeSlots)]);
                $match['venue'] = $venue;
                $timeIndex++;
            }
            
            $round['start_date'] = $currentDate->toDateString();
            $round['end_date'] = $currentDate->toDateString();
            $currentDate->addWeek();
        }

        return $rounds;
    }

    /**
     * Generate Group Stage schedule
     */
    protected function generateGroupStage(
        Season $season,
        Collection $teams,
        Carbon $startDate,
        array $timeSlots,
        array $matchDays,
        ?string $venue,
        array $options
    ): array {
        $numGroups = $options['num_groups'] ?? 4;
        $teamsPerGroup = ceil($teams->count() / $numGroups);
        
        $shuffledTeams = $teams->shuffle();
        $groups = $shuffledTeams->chunk($teamsPerGroup);
        
        $allRounds = [];
        $groupLetter = 'A';
        
        foreach ($groups as $groupTeams) {
            $groupRounds = $this->generateRoundRobin(
                $season,
                $groupTeams,
                $startDate,
                $timeSlots,
                $matchDays,
                $venue,
                $options['matches_per_day'] ?? 4,
                $options['home_and_away'] ?? false
            );
            
            // Prefix round names with group letter
            foreach ($groupRounds as &$round) {
                $round['group'] = $groupLetter;
                $round['name'] = "Bảng $groupLetter - " . $round['name'];
            }
            
            $allRounds = array_merge($allRounds, $groupRounds);
            $groupLetter++;
        }

        return $allRounds;
    }

    /**
     * Assign dates to rounds
     */
    protected function assignDatesToRounds(
        array $rounds,
        Carbon $startDate,
        array $timeSlots,
        array $matchDays,
        ?string $venue,
        int $matchesPerDay
    ): array {
        $currentDate = $startDate->copy();
        
        // Find next match day
        while (!in_array($currentDate->dayOfWeek, $matchDays)) {
            $currentDate->addDay();
        }

        foreach ($rounds as &$round) {
            $matchIndex = 0;
            $roundStartDate = null;
            $roundEndDate = null;
            
            foreach ($round['matches'] as &$match) {
                // Move to next day if reached max matches per day
                if ($matchIndex > 0 && $matchIndex % $matchesPerDay === 0) {
                    $currentDate->addDay();
                    // Find next match day
                    while (!in_array($currentDate->dayOfWeek, $matchDays)) {
                        $currentDate->addDay();
                    }
                }
                
                $timeSlotIndex = $matchIndex % count($timeSlots);
                $matchDateTime = $currentDate->copy()->setTimeFromTimeString($timeSlots[$timeSlotIndex]);
                
                $match['match_date'] = $matchDateTime;
                $match['venue'] = $venue ?? $this->getTeamVenue($match['home_team_id']);
                
                if ($roundStartDate === null) {
                    $roundStartDate = $currentDate->copy();
                }
                $roundEndDate = $currentDate->copy();
                
                $matchIndex++;
            }
            
            $round['start_date'] = $roundStartDate?->toDateString();
            $round['end_date'] = $roundEndDate?->toDateString();
            
            // Move to next week for next round
            $currentDate->addWeek();
            while (!in_array($currentDate->dayOfWeek, $matchDays)) {
                $currentDate->addDay();
            }
        }

        return $rounds;
    }

    /**
     * Get team's home venue
     */
    protected function getTeamVenue(int $teamId): ?string
    {
        return Team::find($teamId)?->stadium;
    }

    /**
     * Save generated schedule to database
     */
    public function saveSchedule(Season $season, array $rounds): array
    {
        $createdRounds = [];
        $createdMatches = [];

        DB::transaction(function () use ($season, $rounds, &$createdRounds, &$createdMatches) {
            foreach ($rounds as $roundData) {
                // Create round
                $round = Round::create([
                    'season_id' => $season->id,
                    'name' => $roundData['name'],
                    'round_number' => $roundData['round_number'],
                    'start_date' => $roundData['start_date'],
                    'end_date' => $roundData['end_date'],
                    'is_current' => false,
                ]);
                
                $createdRounds[] = $round;

                // Create matches
                foreach ($roundData['matches'] as $matchData) {
                    $match = FootballMatch::create([
                        'round_id' => $round->id,
                        'home_team_id' => $matchData['home_team_id'],
                        'away_team_id' => $matchData['away_team_id'],
                        'match_date' => $matchData['match_date'],
                        'venue' => $matchData['venue'],
                        'status' => 'scheduled',
                    ]);
                    
                    $createdMatches[] = $match;
                }
            }

            // Set first round as current
            if (!empty($createdRounds)) {
                $createdRounds[0]->update(['is_current' => true]);
            }
        });

        return [
            'rounds' => $createdRounds,
            'matches' => $createdMatches,
            'summary' => [
                'total_rounds' => count($createdRounds),
                'total_matches' => count($createdMatches),
            ],
        ];
    }

    /**
     * Create a single match manually
     */
    public function createMatch(array $data): FootballMatch
    {
        return FootballMatch::create([
            'round_id' => $data['round_id'],
            'home_team_id' => $data['home_team_id'],
            'away_team_id' => $data['away_team_id'],
            'match_date' => $data['match_date'],
            'venue' => $data['venue'] ?? null,
            'status' => $data['status'] ?? 'scheduled',
        ]);
    }

    /**
     * Update match schedule
     */
    public function updateMatchSchedule(FootballMatch $match, array $data): FootballMatch
    {
        $match->update([
            'match_date' => $data['match_date'] ?? $match->match_date,
            'venue' => $data['venue'] ?? $match->venue,
            'round_id' => $data['round_id'] ?? $match->round_id,
        ]);

        return $match->fresh();
    }

    /**
     * Reschedule a match
     */
    public function rescheduleMatch(FootballMatch $match, Carbon $newDate, ?string $reason = null): FootballMatch
    {
        $oldDate = $match->match_date;
        
        $match->update([
            'match_date' => $newDate,
        ]);

        // Log the reschedule (could add to a match_changes table)
        activity()
            ->performedOn($match)
            ->withProperties([
                'old_date' => $oldDate,
                'new_date' => $newDate,
                'reason' => $reason,
            ])
            ->log('Match rescheduled');

        return $match->fresh();
    }

    /**
     * Swap home/away for a match
     */
    public function swapHomeAway(FootballMatch $match): FootballMatch
    {
        $homeTeamId = $match->home_team_id;
        $awayTeamId = $match->away_team_id;
        
        $match->update([
            'home_team_id' => $awayTeamId,
            'away_team_id' => $homeTeamId,
            'venue' => $this->getTeamVenue($awayTeamId),
        ]);

        return $match->fresh();
    }

    /**
     * Get scheduling conflicts for a season
     */
    public function getSchedulingConflicts(Season $season): array
    {
        $conflicts = [];
        $matches = FootballMatch::whereHas('round', function ($q) use ($season) {
            $q->where('season_id', $season->id);
        })->with(['homeTeam', 'awayTeam', 'round'])->get();

        // Check for same team playing multiple matches on same day
        $matchesByDate = $matches->groupBy(fn($m) => $m->match_date->toDateString());
        
        foreach ($matchesByDate as $date => $dayMatches) {
            $teamsOnDay = [];
            
            foreach ($dayMatches as $match) {
                if (isset($teamsOnDay[$match->home_team_id])) {
                    $conflicts[] = [
                        'type' => 'double_booking',
                        'date' => $date,
                        'team_id' => $match->home_team_id,
                        'team_name' => $match->homeTeam->name,
                        'matches' => [$teamsOnDay[$match->home_team_id]->id, $match->id],
                    ];
                }
                if (isset($teamsOnDay[$match->away_team_id])) {
                    $conflicts[] = [
                        'type' => 'double_booking',
                        'date' => $date,
                        'team_id' => $match->away_team_id,
                        'team_name' => $match->awayTeam->name,
                        'matches' => [$teamsOnDay[$match->away_team_id]->id, $match->id],
                    ];
                }
                
                $teamsOnDay[$match->home_team_id] = $match;
                $teamsOnDay[$match->away_team_id] = $match;
            }
        }

        // Check for consecutive home/away games (more than 3)
        $teamMatches = [];
        foreach ($matches->sortBy('match_date') as $match) {
            $teamMatches[$match->home_team_id][] = ['type' => 'home', 'match' => $match];
            $teamMatches[$match->away_team_id][] = ['type' => 'away', 'match' => $match];
        }

        foreach ($teamMatches as $teamId => $teamMatchList) {
            $consecutiveHome = 0;
            $consecutiveAway = 0;
            
            foreach ($teamMatchList as $item) {
                if ($item['type'] === 'home') {
                    $consecutiveHome++;
                    $consecutiveAway = 0;
                } else {
                    $consecutiveAway++;
                    $consecutiveHome = 0;
                }
                
                if ($consecutiveHome > 3) {
                    $team = Team::find($teamId);
                    $conflicts[] = [
                        'type' => 'consecutive_home',
                        'team_id' => $teamId,
                        'team_name' => $team?->name,
                        'count' => $consecutiveHome,
                    ];
                }
                if ($consecutiveAway > 3) {
                    $team = Team::find($teamId);
                    $conflicts[] = [
                        'type' => 'consecutive_away',
                        'team_id' => $teamId,
                        'team_name' => $team?->name,
                        'count' => $consecutiveAway,
                    ];
                }
            }
        }

        return $conflicts;
    }

    /**
     * Preview schedule without saving
     */
    public function previewSchedule(Season $season, string $type, array $options = []): array
    {
        $schedule = $this->generateSchedule($season, $type, $options);
        
        // Enrich with team names
        $teamIds = [];
        foreach ($schedule as $round) {
            foreach ($round['matches'] as $match) {
                $teamIds[] = $match['home_team_id'];
                $teamIds[] = $match['away_team_id'];
            }
        }
        
        $teams = Team::whereIn('id', array_unique($teamIds))->get()->keyBy('id');
        
        foreach ($schedule as &$round) {
            foreach ($round['matches'] as &$match) {
                $match['home_team_name'] = $teams[$match['home_team_id']]?->name ?? 'Unknown';
                $match['away_team_name'] = $teams[$match['away_team_id']]?->name ?? 'Unknown';
                $match['home_team_logo'] = $teams[$match['home_team_id']]?->logo_url ?? null;
                $match['away_team_logo'] = $teams[$match['away_team_id']]?->logo_url ?? null;
                $match['match_date_formatted'] = $match['match_date']->format('d/m/Y H:i');
            }
        }

        return $schedule;
    }

    /**
     * Clear all matches for a season
     */
    public function clearSeasonSchedule(Season $season): int
    {
        $deletedCount = 0;
        
        DB::transaction(function () use ($season, &$deletedCount) {
            $rounds = Round::where('season_id', $season->id)->get();
            
            foreach ($rounds as $round) {
                $deletedCount += FootballMatch::where('round_id', $round->id)->delete();
            }
            
            Round::where('season_id', $season->id)->delete();
        });

        return $deletedCount;
    }
}
