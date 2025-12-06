<?php

namespace App\Providers;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
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
            ->profile()
            ->colors([
                'primary' => Color::Emerald,
                'danger' => Color::Rose,
                'warning' => Color::Amber,
                'success' => Color::Green,
                'info' => Color::Sky,
                'gray' => Color::Slate,
            ])
            ->darkMode(true)
            ->brandName('SportLife Admin')
            ->brandLogo(asset('images/logo.png'))
            ->darkModeBrandLogo(asset('images/logo-dark.png'))
            ->favicon(asset('favicon.ico'))
            ->font('Inter')
            ->sidebarCollapsibleOnDesktop()
            ->sidebarFullyCollapsibleOnDesktop()
            ->maxContentWidth('full')
            ->globalSearchKeyBindings(['command+k', 'ctrl+k'])
            ->globalSearchFieldKeyBindingSuffix()
            ->navigationGroups([
                NavigationGroup::make()
                    ->label('Quản trị')
                    ->icon('heroicon-o-cog-6-tooth')
                    ->collapsed(false),
                NavigationGroup::make()
                    ->label('Người dùng')
                    ->icon('heroicon-o-users')
                    ->collapsed(false),
                NavigationGroup::make()
                    ->label('Đổi thưởng')
                    ->icon('heroicon-o-gift')
                    ->collapsed(false),
                NavigationGroup::make()
                    ->label('Hệ thống')
                    ->icon('heroicon-o-server-stack')
                    ->collapsed(true),
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                \App\Filament\Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                // Widgets được load qua Dashboard page
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
            ->databaseNotifications()
            ->databaseNotificationsPolling('30s')
            ->spa()
            ->topNavigation(false)
            ->breadcrumbs(true)
            ->renderHook(
                'panels::body.end',
                fn () => view('filament.components.footer'),
            );
    }
}