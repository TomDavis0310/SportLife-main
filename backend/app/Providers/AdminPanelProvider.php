<?php

namespace App\Providers;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationBuilder;
use Filament\Navigation\NavigationGroup;
use Filament\Navigation\NavigationItem;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->colors([
                'primary' => Color::Green,
                'danger' => Color::Red,
                'warning' => Color::Amber,
                'success' => Color::Emerald,
            ])
            ->darkMode(true)
            ->brandName('SportLife Admin')
            ->brandLogo(asset('images/logo.png'))
            ->favicon(asset('favicon.ico'))
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
                \App\Filament\Widgets\StatsOverview::class,
                \App\Filament\Widgets\LatestPredictions::class,
                \App\Filament\Widgets\TodayMatches::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ])
            ->authGuard('web')
            ->navigation(function (NavigationBuilder $builder): NavigationBuilder {
                return $builder->groups([
                    NavigationGroup::make()
                        ->label('Football')
                        ->items([
                            NavigationItem::make('Competitions')
                                ->icon('heroicon-o-trophy')
                                ->url('/admin/competitions'),
                            NavigationItem::make('Teams')
                                ->icon('heroicon-o-user-group')
                                ->url('/admin/teams'),
                            NavigationItem::make('Matches')
                                ->icon('heroicon-o-play')
                                ->url('/admin/matches'),
                        ]),
                    NavigationGroup::make()
                        ->label('Users & Engagement')
                        ->items([
                            NavigationItem::make('Users')
                                ->icon('heroicon-o-users')
                                ->url('/admin/users'),
                            NavigationItem::make('Predictions')
                                ->icon('heroicon-o-chart-bar')
                                ->url('/admin/predictions'),
                            NavigationItem::make('Leaderboard')
                                ->icon('heroicon-o-star')
                                ->url('/admin/leaderboards'),
                        ]),
                    NavigationGroup::make()
                        ->label('Content')
                        ->items([
                            NavigationItem::make('News')
                                ->icon('heroicon-o-newspaper')
                                ->url('/admin/news'),
                            NavigationItem::make('Badges')
                                ->icon('heroicon-o-academic-cap')
                                ->url('/admin/badges'),
                            NavigationItem::make('Missions')
                                ->icon('heroicon-o-flag')
                                ->url('/admin/missions'),
                        ]),
                    NavigationGroup::make()
                        ->label('Sponsors & Rewards')
                        ->items([
                            NavigationItem::make('Sponsors')
                                ->icon('heroicon-o-building-office')
                                ->url('/admin/sponsors'),
                            NavigationItem::make('Campaigns')
                                ->icon('heroicon-o-megaphone')
                                ->url('/admin/campaigns'),
                            NavigationItem::make('Rewards')
                                ->icon('heroicon-o-gift')
                                ->url('/admin/rewards'),
                            NavigationItem::make('Redemptions')
                                ->icon('heroicon-o-shopping-cart')
                                ->url('/admin/redemptions'),
                        ]),
                ]);
            });
    }
}