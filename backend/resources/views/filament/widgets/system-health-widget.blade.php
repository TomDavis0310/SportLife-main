<x-filament-widgets::widget>
    <x-filament::section>
        <x-slot name="heading">
            <div class="flex items-center gap-2">
                <x-heroicon-o-heart class="h-5 w-5 text-danger-500" />
                <span>Tình trạng hệ thống</span>
            </div>
        </x-slot>

        <div class="space-y-3">
            @foreach($this->getHealthData() as $item)
                <div class="flex items-center justify-between p-3 rounded-lg bg-gray-50 dark:bg-gray-800/50 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                    <div class="flex items-center gap-3">
                        <div class="p-2 rounded-lg {{ $item['status'] === 'healthy' ? 'bg-success-100 dark:bg-success-500/20' : 'bg-danger-100 dark:bg-danger-500/20' }}">
                            <x-dynamic-component 
                                :component="$item['icon']" 
                                class="h-5 w-5 {{ $item['status'] === 'healthy' ? 'text-success-600 dark:text-success-400' : 'text-danger-600 dark:text-danger-400' }}" 
                            />
                        </div>
                        <span class="font-medium text-gray-700 dark:text-gray-200">{{ $item['name'] }}</span>
                    </div>
                    <div class="flex items-center gap-2">
                        @if($item['status'] === 'healthy')
                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-success-100 text-success-700 dark:bg-success-500/20 dark:text-success-400">
                                <x-heroicon-s-check-circle class="h-3.5 w-3.5" />
                                Hoạt động
                            </span>
                        @else
                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-danger-100 text-danger-700 dark:bg-danger-500/20 dark:text-danger-400">
                                <x-heroicon-s-x-circle class="h-3.5 w-3.5" />
                                Lỗi
                            </span>
                        @endif
                    </div>
                </div>
            @endforeach
        </div>

        <div class="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
            <div class="flex items-center justify-between text-sm text-gray-500 dark:text-gray-400">
                <span>Cập nhật lần cuối</span>
                <span>{{ now()->format('H:i:s d/m/Y') }}</span>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
