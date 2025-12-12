<x-filament-panels::page>
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {{-- Left sidebar: Season & Round selection --}}
        <div class="lg:col-span-1 space-y-4">
            {{-- Season Selection --}}
            <x-filament::section>
                <x-slot name="heading">
                    <div class="flex items-center gap-2">
                        <x-heroicon-o-trophy class="w-5 h-5" />
                        Mùa giải
                    </div>
                </x-slot>
                
                <div class="space-y-2">
                    @foreach($this->getSeasons() as $season)
                        <button
                            wire:click="selectSeason({{ $season->id }})"
                            class="w-full text-left px-3 py-2 rounded-lg transition-colors {{ $selectedSeasonId === $season->id ? 'bg-primary-500 text-white' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }}"
                        >
                            <div class="font-medium text-sm">{{ $season->name }}</div>
                            <div class="text-xs {{ $selectedSeasonId === $season->id ? 'text-primary-100' : 'text-gray-500' }}">
                                {{ $season->competition?->name }} • {{ $season->teams_count }} đội
                            </div>
                            @if($season->rounds_count > 0)
                                <div class="text-xs {{ $selectedSeasonId === $season->id ? 'text-primary-100' : 'text-gray-400' }}">
                                    {{ $season->rounds_count }} vòng đấu
                                </div>
                            @endif
                        </button>
                    @endforeach
                </div>
            </x-filament::section>

            {{-- Round Selection --}}
            @if($selectedSeasonId)
                <x-filament::section>
                    <x-slot name="heading">
                        <div class="flex items-center gap-2">
                            <x-heroicon-o-calendar class="w-5 h-5" />
                            Vòng đấu
                        </div>
                    </x-slot>

                    <div class="space-y-2">
                        <button
                            wire:click="selectRound(null)"
                            class="w-full text-left px-3 py-2 rounded-lg transition-colors {{ $selectedRoundId === null ? 'bg-primary-500 text-white' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }}"
                        >
                            <div class="font-medium text-sm">Tất cả vòng</div>
                        </button>
                        
                        @foreach($this->getRounds() as $round)
                            <button
                                wire:click="selectRound({{ $round->id }})"
                                class="w-full text-left px-3 py-2 rounded-lg transition-colors {{ $selectedRoundId === $round->id ? 'bg-primary-500 text-white' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }}"
                            >
                                <div class="font-medium text-sm">{{ $round->name }}</div>
                                <div class="text-xs {{ $selectedRoundId === $round->id ? 'text-primary-100' : 'text-gray-500' }}">
                                    {{ $round->matches_count }} trận
                                    @if($round->is_current)
                                        <span class="ml-1 px-1 py-0.5 bg-green-100 text-green-700 rounded text-xs">Đang diễn ra</span>
                                    @endif
                                </div>
                            </button>
                        @endforeach
                    </div>

                    @if($this->getRounds()->isEmpty())
                        <div class="text-center py-4 text-gray-500">
                            <x-heroicon-o-calendar class="w-8 h-8 mx-auto mb-2 opacity-50" />
                            <p class="text-sm">Chưa có vòng đấu</p>
                            <p class="text-xs">Sử dụng "Tự động xếp lịch" để tạo</p>
                        </div>
                    @endif
                </x-filament::section>

                {{-- Quick Actions --}}
                <x-filament::section>
                    <x-slot name="heading">
                        Thao tác nhanh
                    </x-slot>
                    
                    <div class="space-y-2">
                        <x-filament::button
                            wire:click="checkConflicts"
                            color="warning"
                            icon="heroicon-o-exclamation-triangle"
                            class="w-full"
                            size="sm"
                        >
                            Kiểm tra xung đột
                        </x-filament::button>
                        
                        <x-filament::button
                            wire:click="clearSeasonSchedule"
                            wire:confirm="Bạn có chắc muốn xóa toàn bộ lịch thi đấu của mùa giải này?"
                            color="danger"
                            icon="heroicon-o-trash"
                            class="w-full"
                            size="sm"
                        >
                            Xóa lịch mùa giải
                        </x-filament::button>
                    </div>
                </x-filament::section>
            @endif
        </div>

        {{-- Main content: Match list --}}
        <div class="lg:col-span-3">
            @if($selectedSeasonId)
                {{ $this->table }}
            @else
                <x-filament::section>
                    <div class="text-center py-12">
                        <x-heroicon-o-calendar-days class="w-16 h-16 mx-auto mb-4 text-gray-400" />
                        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">Chọn mùa giải</h3>
                        <p class="text-gray-500 mt-2">Vui lòng chọn một mùa giải từ danh sách bên trái để xem và quản lý lịch thi đấu</p>
                    </div>
                </x-filament::section>
            @endif
        </div>
    </div>

    {{-- Legend --}}
    <div class="mt-6">
        <x-filament::section collapsible collapsed>
            <x-slot name="heading">
                Hướng dẫn sử dụng
            </x-slot>

            <div class="prose dark:prose-invert max-w-none text-sm">
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <h4 class="font-medium">Tự động xếp lịch</h4>
                        <ul class="text-sm text-gray-600 dark:text-gray-400">
                            <li><strong>Vòng tròn 1 lượt:</strong> Mỗi đội đấu với đội khác 1 trận</li>
                            <li><strong>Vòng tròn 2 lượt:</strong> Mỗi đội đấu sân nhà và sân khách</li>
                            <li><strong>Loại trực tiếp:</strong> Knockout, đội thua bị loại</li>
                            <li><strong>Vòng bảng:</strong> Chia nhóm, đấu vòng tròn trong nhóm</li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="font-medium">Thao tác với trận đấu</h4>
                        <ul class="text-sm text-gray-600 dark:text-gray-400">
                            <li><strong>Dời lịch:</strong> Thay đổi ngày giờ thi đấu</li>
                            <li><strong>Đổi sân:</strong> Hoán đổi đội nhà và đội khách</li>
                            <li><strong>Xóa:</strong> Xóa trận đấu khỏi lịch</li>
                        </ul>
                    </div>
                </div>
            </div>
        </x-filament::section>
    </div>
</x-filament-panels::page>
