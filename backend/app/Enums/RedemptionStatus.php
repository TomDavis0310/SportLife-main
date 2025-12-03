<?php

namespace App\Enums;

enum RedemptionStatus: string
{
    case PENDING = 'pending';
    case APPROVED = 'approved';
    case SHIPPED = 'shipped';
    case DELIVERED = 'delivered';
    case CANCELLED = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::PENDING => 'Chờ xử lý',
            self::APPROVED => 'Đã duyệt',
            self::SHIPPED => 'Đang giao',
            self::DELIVERED => 'Đã giao',
            self::CANCELLED => 'Đã hủy',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::PENDING => 'warning',
            self::APPROVED => 'info',
            self::SHIPPED => 'primary',
            self::DELIVERED => 'success',
            self::CANCELLED => 'danger',
        };
    }
}
