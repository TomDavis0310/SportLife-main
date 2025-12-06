<?php

namespace App\Filament\Pages;

use Filament\Pages\Page;
use App\Models\User;
use App\Models\Prediction;
use App\Models\RewardRedemption;
use App\Models\FootballMatch;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class SystemSettings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string $view = 'filament.pages.system-settings';

    protected static ?string $navigationLabel = 'Cài đặt hệ thống';

    protected static ?string $title = 'Cài đặt hệ thống';

    protected static ?string $navigationGroup = 'Hệ thống';

    protected static ?int $navigationSort = 100;

    public function getViewData(): array
    {
        return [
            'stats' => $this->getSystemStats(),
            'recentActivity' => $this->getRecentActivity(),
        ];
    }

    protected function getSystemStats(): array
    {
        return [
            'total_users' => User::count(),
            'active_users_today' => User::whereDate('updated_at', today())->count(),
            'total_predictions' => Prediction::count(),
            'predictions_today' => Prediction::whereDate('created_at', today())->count(),
            'pending_redemptions' => RewardRedemption::where('status', 'pending')->count(),
            'total_matches' => FootballMatch::count(),
            'live_matches' => FootballMatch::live()->count(),
        ];
    }

    protected function getRecentActivity(): array
    {
        return [
            'new_users' => User::latest()->take(5)->get(),
            'recent_redemptions' => RewardRedemption::with(['user', 'reward'])->latest()->take(5)->get(),
        ];
    }
}
