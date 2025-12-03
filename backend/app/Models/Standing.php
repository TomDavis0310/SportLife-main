<?php

namespace App\Models;

use App\Enums\MatchStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Standing extends Model
{
    use HasFactory;

    protected $fillable = [
        'season_id',
        'team_id',
        'position',
        'played',
        'won',
        'drawn',
        'lost',
        'goals_for',
        'goals_against',
        'goal_difference',
        'points',
        'form',
    ];

    protected $casts = [
        'position' => 'integer',
        'played' => 'integer',
        'won' => 'integer',
        'drawn' => 'integer',
        'lost' => 'integer',
        'goals_for' => 'integer',
        'goals_against' => 'integer',
        'goal_difference' => 'integer',
        'points' => 'integer',
    ];

    /**
     * Standing's season
     */
    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    /**
     * Standing's team
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get form array (last 5 results)
     */
    public function getFormArrayAttribute(): array
    {
        return $this->form ? str_split($this->form) : [];
    }

    /**
     * Update standing after match
     */
    public static function updateAfterMatch(FootballMatch $match): void
    {
        if ($match->status !== MatchStatus::FINISHED) {
            return;
        }

        $season = $match->round->season;

        // Update home team standing
        $homeStanding = self::firstOrCreate([
            'season_id' => $season->id,
            'team_id' => $match->home_team_id,
        ]);

        $awayStanding = self::firstOrCreate([
            'season_id' => $season->id,
            'team_id' => $match->away_team_id,
        ]);

        // Calculate results
        $homeWin = $match->home_score > $match->away_score;
        $awayWin = $match->away_score > $match->home_score;
        $draw = $match->home_score === $match->away_score;

        // Update home team
        $homeStanding->played++;
        $homeStanding->goals_for += $match->home_score;
        $homeStanding->goals_against += $match->away_score;
        $homeStanding->goal_difference = $homeStanding->goals_for - $homeStanding->goals_against;

        if ($homeWin) {
            $homeStanding->won++;
            $homeStanding->points += 3;
            $homeStanding->form = self::updateForm($homeStanding->form, 'W');
        } elseif ($draw) {
            $homeStanding->drawn++;
            $homeStanding->points += 1;
            $homeStanding->form = self::updateForm($homeStanding->form, 'D');
        } else {
            $homeStanding->lost++;
            $homeStanding->form = self::updateForm($homeStanding->form, 'L');
        }
        $homeStanding->save();

        // Update away team
        $awayStanding->played++;
        $awayStanding->goals_for += $match->away_score;
        $awayStanding->goals_against += $match->home_score;
        $awayStanding->goal_difference = $awayStanding->goals_for - $awayStanding->goals_against;

        if ($awayWin) {
            $awayStanding->won++;
            $awayStanding->points += 3;
            $awayStanding->form = self::updateForm($awayStanding->form, 'W');
        } elseif ($draw) {
            $awayStanding->drawn++;
            $awayStanding->points += 1;
            $awayStanding->form = self::updateForm($awayStanding->form, 'D');
        } else {
            $awayStanding->lost++;
            $awayStanding->form = self::updateForm($awayStanding->form, 'L');
        }
        $awayStanding->save();

        // Recalculate positions
        self::recalculatePositions($season->id);
    }

    /**
     * Update form string (keep last 5)
     */
    private static function updateForm(?string $form, string $result): string
    {
        $form = ($form ?? '') . $result;
        return substr($form, -5);
    }

    /**
     * Recalculate positions for a season
     */
    public static function recalculatePositions(int $seasonId): void
    {
        $standings = self::where('season_id', $seasonId)
            ->orderByDesc('points')
            ->orderByDesc('goal_difference')
            ->orderByDesc('goals_for')
            ->get();

        $position = 1;
        foreach ($standings as $standing) {
            $standing->position = $position++;
            $standing->save();
        }
    }
}
