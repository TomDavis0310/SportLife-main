<?php

namespace App\Models;

use App\Enums\MatchStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class FootballMatch extends Model
{
    use HasFactory;

    protected $table = 'matches';

    protected $fillable = [
        'round_id',
        'group_name',
        'home_team_id',
        'away_team_id',
        'home_score',
        'away_score',
        'home_score_ht',
        'away_score_ht',
        'status',
        'minute',
        'match_date',
        'venue',
        'prediction_locked_at',
        'first_scorer_id',
    ];

    protected $casts = [
        'match_date' => 'datetime',
        'prediction_locked_at' => 'datetime',
        'home_score' => 'integer',
        'away_score' => 'integer',
        'home_score_ht' => 'integer',
        'away_score_ht' => 'integer',
        'minute' => 'integer',
        'status' => MatchStatus::class,
    ];

    public function round(): BelongsTo
    {
        return $this->belongsTo(Round::class);
    }

    public function homeTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function firstScorer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'first_scorer_id');
    }

    public function events(): HasMany
    {
        return $this->hasMany(MatchEvent::class, 'match_id')
            ->orderBy('minute')
            ->orderBy('extra_minute');
    }

    public function statistics(): HasMany
    {
        return $this->hasMany(MatchStatistic::class, 'match_id');
    }

    public function homeStatistics(): HasOne
    {
        return $this->hasOne(MatchStatistic::class, 'match_id')->where('side', 'home');
    }

    public function awayStatistics(): HasOne
    {
        return $this->hasOne(MatchStatistic::class, 'match_id')->where('side', 'away');
    }

    public function goals(): HasMany
    {
        return $this->hasMany(MatchEvent::class, 'match_id')
            ->whereIn('type', ['goal', 'penalty', 'own_goal'])
            ->orderBy('minute');
    }

    public function highlights(): HasMany
    {
        return $this->hasMany(MatchHighlight::class, 'match_id')
            ->orderByDesc('published_at')
            ->orderByDesc('created_at');
    }

    public function predictions(): HasMany
    {
        return $this->hasMany(Prediction::class, 'match_id');
    }

    public function getSeasonAttribute()
    {
        return $this->round?->season;
    }

    public function getCompetitionAttribute()
    {
        return $this->round?->season?->competition;
    }

    public function getCanPredictAttribute(): bool
    {
        if ($this->status !== MatchStatus::SCHEDULED) {
            return false;
        }

        $referenceTime = $this->match_date?->copy();
        $lockTime = $this->prediction_locked_at ?? $referenceTime?->subMinutes(5);

        return $lockTime ? now()->lt($lockTime) : false;
    }

    public function getIsLiveAttribute(): bool
    {
        $status = $this->status instanceof MatchStatus ? $this->status->value : $this->status;

        return in_array($status, MatchStatus::liveValues(), true);
    }

    public function getIsFinishedAttribute(): bool
    {
        return $this->status === MatchStatus::FINISHED;
    }

    public function getWinnerAttribute(): ?string
    {
        if (! $this->is_finished) {
            return null;
        }

        if ($this->home_score > $this->away_score) {
            return 'home';
        }

        if ($this->away_score > $this->home_score) {
            return 'away';
        }

        return 'draw';
    }

    public function getGoalDifferenceAttribute(): ?int
    {
        if ($this->home_score === null || $this->away_score === null) {
            return null;
        }

        return $this->home_score - $this->away_score;
    }

    public function getDisplayScoreAttribute(): string
    {
        if ($this->home_score === null || $this->away_score === null) {
            return '- : -';
        }

        return "{$this->home_score} : {$this->away_score}";
    }

    public function getStatusTextAttribute(): string
    {
        if ($this->status instanceof MatchStatus) {
            return $this->status->label();
        }

        return MatchStatus::tryFrom($this->status ?? '')?->label()
            ?? MatchStatus::SCHEDULED->label();
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', MatchStatus::SCHEDULED->value)
            ->where('match_date', '>', now())
            ->orderBy('match_date');
    }

    public function scopeLive($query)
    {
        return $query->whereIn('status', MatchStatus::liveValues());
    }

    public function scopeFinished($query)
    {
        return $query->where('status', MatchStatus::FINISHED->value)
            ->orderByDesc('match_date');
    }

    public function scopeToday($query)
    {
        return $query->whereDate('match_date', today());
    }
}


