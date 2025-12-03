<?php

namespace App\Enums;

enum MatchEventType: string
{
    case GOAL = 'goal';
    case YELLOW_CARD = 'yellow_card';
    case RED_CARD = 'red_card';
    case SUBSTITUTION = 'substitution';
    case PENALTY = 'penalty';
    case OWN_GOAL = 'own_goal';
    case PENALTY_MISS = 'penalty_miss';
    case VAR = 'var';

    public function label(): string
    {
        return match ($this) {
            self::GOAL => 'Bàn thắng',
            self::YELLOW_CARD => 'Thẻ vàng',
            self::RED_CARD => 'Thẻ đỏ',
            self::SUBSTITUTION => 'Thay người',
            self::PENALTY => 'Phạt đền',
            self::OWN_GOAL => 'Phản lưới',
            self::PENALTY_MISS => 'Hỏng phạt đền',
            self::VAR => 'VAR',
        };
    }

    public function icon(): string
    {
        return match ($this) {
            self::GOAL => '⚽',
            self::YELLOW_CARD => '🟨',
            self::RED_CARD => '🟥',
            self::SUBSTITUTION => '🔄',
            self::PENALTY => '⚽(P)',
            self::OWN_GOAL => '⚽(OG)',
            self::PENALTY_MISS => '❌(P)',
            self::VAR => '📺',
        };
    }
}
