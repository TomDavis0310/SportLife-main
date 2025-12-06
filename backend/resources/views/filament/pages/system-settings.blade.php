<x-filament-panels::page>
    <div class="space-y-6">
        {{-- System Statistics --}}
        <x-filament::section>
            <x-slot name="heading">
                <div class="flex items-center gap-2">
                    <x-heroicon-o-chart-bar class="h-5 w-5 text-primary-500" />
                    <span>Thống kê hệ thống</span>
                </div>
            </x-slot>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div class="bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-xl p-4 text-white">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-emerald-100 text-sm">Tổng người dùng</p>
                            <p class="text-3xl font-bold">{{ number_format($stats['total_users']) }}</p>
                        </div>
                        <x-heroicon-o-users class="h-12 w-12 text-emerald-200/50" />
                    </div>
                </div>

                <div class="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-4 text-white">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-blue-100 text-sm">Dự đoán hôm nay</p>
                            <p class="text-3xl font-bold">{{ number_format($stats['predictions_today']) }}</p>
                        </div>
                        <x-heroicon-o-chart-bar class="h-12 w-12 text-blue-200/50" />
                    </div>
                </div>

                <div class="bg-gradient-to-br from-amber-500 to-amber-600 rounded-xl p-4 text-white">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-amber-100 text-sm">Chờ duyệt đổi thưởng</p>
                            <p class="text-3xl font-bold">{{ $stats['pending_redemptions'] }}</p>
                        </div>
                        <x-heroicon-o-gift class="h-12 w-12 text-amber-200/50" />
                    </div>
                </div>

                <div class="bg-gradient-to-br from-rose-500 to-rose-600 rounded-xl p-4 text-white">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-rose-100 text-sm">Trận đấu trực tiếp</p>
                            <p class="text-3xl font-bold">{{ $stats['live_matches'] }}</p>
                        </div>
                        <x-heroicon-o-play class="h-12 w-12 text-rose-200/50" />
                    </div>
                </div>
            </div>
        </x-filament::section>

        {{-- Quick Actions --}}
        <x-filament::section>
            <x-slot name="heading">
                <div class="flex items-center gap-2">
                    <x-heroicon-o-bolt class="h-5 w-5 text-warning-500" />
                    <span>Thao tác nhanh</span>
                </div>
            </x-slot>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <a href="{{ route('filament.admin.resources.users.index') }}" 
                   class="flex items-center gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700 transition group">
                    <div class="p-3 bg-emerald-100 dark:bg-emerald-500/20 rounded-lg group-hover:scale-110 transition">
                        <x-heroicon-o-users class="h-6 w-6 text-emerald-600 dark:text-emerald-400" />
                    </div>
                    <div>
                        <p class="font-semibold text-gray-900 dark:text-white">Quản lý người dùng</p>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Xem và chỉnh sửa thông tin</p>
                    </div>
                </a>

                <a href="{{ route('filament.admin.resources.reward-redemptions.index') }}" 
                   class="flex items-center gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700 transition group">
                    <div class="p-3 bg-amber-100 dark:bg-amber-500/20 rounded-lg group-hover:scale-110 transition">
                        <x-heroicon-o-gift class="h-6 w-6 text-amber-600 dark:text-amber-400" />
                    </div>
                    <div>
                        <p class="font-semibold text-gray-900 dark:text-white">Duyệt đổi thưởng</p>
                        <p class="text-sm text-gray-500 dark:text-gray-400">{{ $stats['pending_redemptions'] }} yêu cầu chờ</p>
                    </div>
                </a>

                <a href="#" 
                   class="flex items-center gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700 transition group">
                    <div class="p-3 bg-blue-100 dark:bg-blue-500/20 rounded-lg group-hover:scale-110 transition">
                        <x-heroicon-o-document-chart-bar class="h-6 w-6 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                        <p class="font-semibold text-gray-900 dark:text-white">Báo cáo</p>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Xem thống kê chi tiết</p>
                    </div>
                </a>
            </div>
        </x-filament::section>

        {{-- System Info --}}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <x-filament::section>
                <x-slot name="heading">
                    <div class="flex items-center gap-2">
                        <x-heroicon-o-server class="h-5 w-5 text-info-500" />
                        <span>Thông tin hệ thống</span>
                    </div>
                </x-slot>

                <div class="space-y-3">
                    <div class="flex justify-between items-center py-2 border-b border-gray-200 dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">Phiên bản PHP</span>
                        <span class="font-medium text-gray-900 dark:text-white">{{ PHP_VERSION }}</span>
                    </div>
                    <div class="flex justify-between items-center py-2 border-b border-gray-200 dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">Laravel Version</span>
                        <span class="font-medium text-gray-900 dark:text-white">{{ app()->version() }}</span>
                    </div>
                    <div class="flex justify-between items-center py-2 border-b border-gray-200 dark:border-gray-700">
                        <span class="text-gray-600 dark:text-gray-400">Môi trường</span>
                        <span class="px-2 py-1 text-xs font-medium rounded-full {{ config('app.env') === 'production' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700' }}">
                            {{ config('app.env') }}
                        </span>
                    </div>
                    <div class="flex justify-between items-center py-2">
                        <span class="text-gray-600 dark:text-gray-400">Debug Mode</span>
                        <span class="px-2 py-1 text-xs font-medium rounded-full {{ config('app.debug') ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700' }}">
                            {{ config('app.debug') ? 'Bật' : 'Tắt' }}
                        </span>
                    </div>
                </div>
            </x-filament::section>

            <x-filament::section>
                <x-slot name="heading">
                    <div class="flex items-center gap-2">
                        <x-heroicon-o-clock class="h-5 w-5 text-success-500" />
                        <span>Người dùng mới nhất</span>
                    </div>
                </x-slot>

                <div class="space-y-3">
                    @foreach($recentActivity['new_users'] as $user)
                        <div class="flex items-center gap-3 py-2 border-b border-gray-200 dark:border-gray-700 last:border-0">
                            <img src="{{ $user->avatar ? asset('storage/' . $user->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode($user->name) . '&background=10b981&color=fff' }}" 
                                 alt="{{ $user->name }}" 
                                 class="h-10 w-10 rounded-full object-cover">
                            <div class="flex-1 min-w-0">
                                <p class="font-medium text-gray-900 dark:text-white truncate">{{ $user->name }}</p>
                                <p class="text-sm text-gray-500 dark:text-gray-400 truncate">{{ $user->email }}</p>
                            </div>
                            <span class="text-xs text-gray-400">{{ $user->created_at->diffForHumans() }}</span>
                        </div>
                    @endforeach
                </div>
            </x-filament::section>
        </div>
    </div>
</x-filament-panels::page>
