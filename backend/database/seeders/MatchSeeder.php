<?php

namespace Database\Seeders;

use App\Models\Competition;
use App\Models\FootballMatch;
use App\Models\Round;
use App\Models\Team;
use App\Enums\MatchStatus;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class MatchSeeder extends Seeder
{
    public function run(): void
    {
        $premierLeague = Competition::where('short_name', 'EPL')->first();
        if (!$premierLeague) return;

        $season = $premierLeague->seasons()->where('is_current', true)->first();
        if (!$season) return;

        $teams = Team::where('country', 'England')->get();
        if ($teams->count() < 2) return;

        // Generate matches for rounds around Dec 2025 (Rounds 14-20)
        // Also include some early rounds for history (1-3)
        $rounds = Round::where('season_id', $season->id)
            ->where(function($q) {
                $q->whereBetween('round_number', [14, 20])
                  ->orWhereBetween('round_number', [1, 3]);
            })
            ->orderBy('round_number')
            ->get();

        $teamIds = $teams->pluck('id')->toArray();
        shuffle($teamIds);

        $currentDate = Carbon::parse('2025-12-02');

        foreach ($rounds as $round) {
            $matchDate = Carbon::parse($round->start_date);
            $usedTeams = [];

            // Create 10 matches per round (20 teams)
            for ($i = 0; $i < min(10, floor(count($teamIds) / 2)); $i++) {
                $availableTeams = array_diff($teamIds, $usedTeams);
                if (count($availableTeams) < 2) break;

                $matchTeams = array_slice(array_values($availableTeams), 0, 2);
                $usedTeams = array_merge($usedTeams, $matchTeams);

                // Determine status based on simulated current date
                $isPast = $matchDate->lt($currentDate);
                $isToday = $matchDate->isSameDay($currentDate);
                
                if ($isPast) {
                    $status = MatchStatus::FINISHED;
                    $homeScore = rand(0, 4);
                    $awayScore = rand(0, 3);
                } elseif ($isToday) {
                    $status = MatchStatus::LIVE; // Simulate live matches for today
                    $homeScore = rand(0, 2);
                    $awayScore = rand(0, 2);
                } else {
                    $status = MatchStatus::SCHEDULED;
                    $homeScore = null;
                    $awayScore = null;
                }

                FootballMatch::create([
                    'round_id' => $round->id,
                    'home_team_id' => $matchTeams[0],
                    'away_team_id' => $matchTeams[1],
                    'match_date' => $matchDate->copy()->addHours(rand(12, 21)),
                    'venue' => Team::find($matchTeams[0])->stadium,
                    'status' => $status,
                    'home_score' => $homeScore,
                    'away_score' => $awayScore,
                ]);

                // Spread matches over the weekend
                if ($i % 3 == 0) {
                    $matchDate->addHours(2);
                }
            }
            shuffle($teamIds);
        }

        // V.League matches
        $vleague = Competition::where('short_name', 'VL1')->first();
        if (!$vleague) return;

        $vleagueSeason = $vleague->seasons()->where('is_current', true)->first();
        if (!$vleagueSeason) return;

        $vteams = Team::where('country', 'Vietnam')->get();
        $vteamIds = $vteams->pluck('id')->toArray();

        // Generate matches for rounds around Dec 2025 (Rounds 10-15)
        $vleagueRounds = Round::where('season_id', $vleagueSeason->id)
            ->whereBetween('round_number', [10, 15])
            ->orderBy('round_number')
            ->get();

        foreach ($vleagueRounds as $round) {
            $matchDate = Carbon::parse($round->start_date);
            shuffle($vteamIds);
            $usedTeams = [];

            for ($i = 0; $i < min(7, floor(count($vteamIds) / 2)); $i++) {
                $availableTeams = array_diff($vteamIds, $usedTeams);
                if (count($availableTeams) < 2) break;

                $matchTeams = array_slice(array_values($availableTeams), 0, 2);
                $usedTeams = array_merge($usedTeams, $matchTeams);

                $isPast = $matchDate->lt($currentDate);
                
                if ($isPast) {
                    $status = MatchStatus::FINISHED;
                    $homeScore = rand(0, 3);
                    $awayScore = rand(0, 2);
                } else {
                    $status = MatchStatus::SCHEDULED;
                    $homeScore = null;
                    $awayScore = null;
                }

                FootballMatch::create([
                    'round_id' => $round->id,
                    'home_team_id' => $matchTeams[0],
                    'away_team_id' => $matchTeams[1],
                    'match_date' => $matchDate->copy()->addHours(rand(17, 19)),
                    'venue' => Team::find($matchTeams[0])->stadium ?? 'TBD',
                    'status' => $status,
                    'home_score' => $homeScore,
                    'away_score' => $awayScore,
                ]);

                // Spread matches: 3 matches per day
                if (($i + 1) % 3 == 0) {
                    $matchDate->addDay();
                }
            }
        }
    }
}
