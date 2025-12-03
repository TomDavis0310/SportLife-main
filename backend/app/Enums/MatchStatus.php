<?php

namespace App\Enums;

enum MatchStatus: string
{
    case SCHEDULED = 'scheduled';
    case LIVE = 'live';
    case FIRST_HALF = 'first_half';
    case HALFTIME = 'halftime';
    case SECOND_HALF = 'second_half';
    case EXTRA_TIME = 'extra_time';
    case PENALTIES = 'penalties';
    case FINISHED = 'finished';
    case POSTPONED = 'postponed';
    case CANCELLED = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::SCHEDULED => 'Sắp diễn ra',
            self::LIVE, self::FIRST_HALF, self::SECOND_HALF => 'Đang diễn ra',
            self::HALFTIME => 'Nghỉ giữa hiệp',
            self::EXTRA_TIME => 'Hiệp phụ',
            self::PENALTIES => 'Luân lưu',
            self::FINISHED => 'Kết thúc',
            self::POSTPONED => 'Hoãn',
            self::CANCELLED => 'Hủy',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::SCHEDULED => 'gray',
            self::LIVE, self::FIRST_HALF, self::SECOND_HALF => 'danger',
            self::EXTRA_TIME, self::PENALTIES => 'primary',
            self::HALFTIME => 'warning',
            self::FINISHED => 'success',
            self::POSTPONED => 'warning',
            self::CANCELLED => 'danger',
        };
    }

    public static function options(): array
    {
        $options = [];

        foreach (self::cases() as $case) {
            $options[$case->value] = $case->label();
        }

        return $options;
    }

    public static function liveValues(): array
    {
        return array_map(
            fn (self $status) => $status->value,
            [
                self::LIVE,
                self::FIRST_HALF,
                self::HALFTIME,
                self::SECOND_HALF,
                self::EXTRA_TIME,
                self::PENALTIES,
            ]
        );
    }
}
