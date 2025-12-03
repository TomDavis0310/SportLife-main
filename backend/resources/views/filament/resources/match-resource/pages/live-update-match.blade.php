<x-filament-panels::page>
    @php
        $statusEnum = \App\Enums\MatchStatus::tryFrom($status ?? 'scheduled') ?? \App\Enums\MatchStatus::SCHEDULED;
        $badgeColors = [
            'gray' => 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200',
            'danger' => 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
            'warning' => 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
            'primary' => 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
            'success' => 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
        ];
        $statusBadgeClass = $badgeColors[$statusEnum->color()] ?? $badgeColors['gray'];
        $goalStatuses = [
            \App\Enums\MatchStatus::LIVE->value,
            \App\Enums\MatchStatus::FIRST_HALF->value,
            \App\Enums\MatchStatus::SECOND_HALF->value,
            \App\Enums\MatchStatus::EXTRA_TIME->value,
            \App\Enums\MatchStatus::PENALTIES->value,
        ];
    @endphp

    <div class="space-y-6">
        {{-- Match Header --}}
        <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="text-center">
                        <img src="{{ $record->homeTeam->logo_url }}" class="w-16 h-16 object-contain" alt="{{ $record->homeTeam->name }}">
                        <p class="font-bold mt-2">{{ $record->homeTeam->short_name }}</p>
                    </div>
                    <div class="text-center px-8">
                        <div class="text-4xl font-bold">
                            {{ $homeScore ?? 0 }} - {{ $awayScore ?? 0 }}
                        </div>
                        <div class="text-sm text-gray-500 mt-1">
                            {{ $minute ?? 0 }}'
                        </div>
                        <div class="mt-2">
                            <span class="px-3 py-1 rounded-full text-sm font-medium {{ $statusBadgeClass }}">
                                {{ $statusEnum->label() }}
                            </span>
                        </div>
                    </div>
                    <div class="text-center">
                        <img src="{{ $record->awayTeam->logo_url }}" class="w-16 h-16 object-contain" alt="{{ $record->awayTeam->name }}">
                        <p class="font-bold mt-2">{{ $record->awayTeam->short_name }}</p>
                    </div>
                </div>
            </div>
        </div>

        {{-- Controls --}}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            {{-- Match Status Controls --}}
            <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow">
                <h3 class="text-lg font-semibold mb-4">Match Status</h3>
                <div class="space-y-3">
                    @if($statusEnum === \App\Enums\MatchStatus::SCHEDULED)
                        <x-filament::button wire:click="startMatch" color="success" class="w-full">
                            ⚽ Start Match
                        </x-filament::button>
                    @elseif($statusEnum === \App\Enums\MatchStatus::FIRST_HALF)
                        <x-filament::button wire:click="halfTime" color="warning" class="w-full">
                            ⏱️ Half Time
                        </x-filament::button>
                    @elseif($statusEnum === \App\Enums\MatchStatus::HALFTIME)
                        <x-filament::button wire:click="startSecondHalf" color="success" class="w-full">
                            ▶️ Start Second Half
                        </x-filament::button>
                    @elseif($statusEnum === \App\Enums\MatchStatus::SECOND_HALF)
                        <div class="space-y-3">
                            <x-filament::button wire:click="startExtraTime" color="primary" class="w-full">
                                ➕ Start Extra Time
                            </x-filament::button>
                            <x-filament::button wire:click="endMatch" color="danger" class="w-full">
                                🏁 End Match
                            </x-filament::button>
                        </div>
                    @elseif($statusEnum === \App\Enums\MatchStatus::EXTRA_TIME)
                        <div class="space-y-3">
                            <x-filament::button wire:click="startPenalties" color="warning" class="w-full">
                                🎯 Start Penalties
                            </x-filament::button>
                            <x-filament::button wire:click="endMatch" color="danger" class="w-full">
                                🏁 End Match
                            </x-filament::button>
                        </div>
                    @elseif($statusEnum === \App\Enums\MatchStatus::PENALTIES)
                        <x-filament::button wire:click="endMatch" color="danger" class="w-full">
                            🏁 End Match
                        </x-filament::button>
                    @endif
                </div>
            </div>

            {{-- Minute Update --}}
            <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow">
                <h3 class="text-lg font-semibold mb-4">Update Minute</h3>
                <div class="flex items-center space-x-4">
                    <x-filament::input.wrapper>
                        <x-filament::input
                            type="number"
                            wire:model="minute"
                            min="0"
                            max="120"
                            class="w-24"
                        />
                    </x-filament::input.wrapper>
                    <x-filament::button wire:click="updateScore" color="primary">
                        Update
                    </x-filament::button>
                </div>
            </div>
        </div>

        {{-- Goal Controls --}}
        @if(in_array($statusEnum->value, $goalStatuses, true))
            <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow">
                <h3 class="text-lg font-semibold mb-4">Add Goal</h3>
                <div class="grid grid-cols-2 gap-4">
                    <x-filament::button wire:click="addGoal('home')" color="success" class="h-20">
                        <span class="text-2xl">⚽</span>
                        <span class="block">{{ $record->homeTeam->short_name }}</span>
                    </x-filament::button>
                    <x-filament::button wire:click="addGoal('away')" color="success" class="h-20">
                        <span class="text-2xl">⚽</span>
                        <span class="block">{{ $record->awayTeam->short_name }}</span>
                    </x-filament::button>
                </div>
            </div>
        @endif

        {{-- Manual Score Override --}}
        <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow">
            <h3 class="text-lg font-semibold mb-4">Manual Score Update</h3>
            <div class="flex items-center justify-center space-x-4">
                <div class="text-center">
                    <label class="block text-sm font-medium mb-1">{{ $record->homeTeam->short_name }}</label>
                    <x-filament::input.wrapper>
                        <x-filament::input
                            type="number"
                            wire:model="homeScore"
                            min="0"
                            class="w-20 text-center text-2xl"
                        />
                    </x-filament::input.wrapper>
                </div>
                <span class="text-2xl font-bold">-</span>
                <div class="text-center">
                    <label class="block text-sm font-medium mb-1">{{ $record->awayTeam->short_name }}</label>
                    <x-filament::input.wrapper>
                        <x-filament::input
                            type="number"
                            wire:model="awayScore"
                            min="0"
                            class="w-20 text-center text-2xl"
                        />
                    </x-filament::input.wrapper>
                </div>
            </div>
            <div class="mt-4 text-center">
                <x-filament::button wire:click="updateScore" color="primary">
                    Save Score
                </x-filament::button>
            </div>
        </div>
    </div>
</x-filament-panels::page>
