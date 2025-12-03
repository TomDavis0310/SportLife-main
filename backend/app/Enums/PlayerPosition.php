<?php

namespace App\Enums;

enum PlayerPosition: string
{
    case GOALKEEPER = 'goalkeeper';
    case DEFENDER = 'defender';
    case MIDFIELDER = 'midfielder';
    case FORWARD = 'forward';

    public function label(): string
    {
        return match ($this) {
            self::GOALKEEPER => 'Thủ môn',
            self::DEFENDER => 'Hậu vệ',
            self::MIDFIELDER => 'Tiền vệ',
            self::FORWARD => 'Tiền đạo',
        };
    }

    public function shortLabel(): string
    {
        return match ($this) {
            self::GOALKEEPER => 'GK',
            self::DEFENDER => 'DF',
            self::MIDFIELDER => 'MF',
            self::FORWARD => 'FW',
        };
    }
}
