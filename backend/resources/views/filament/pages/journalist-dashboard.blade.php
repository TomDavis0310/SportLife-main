<x-filament-panels::page>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {{-- Stats Cards --}}
        @php
            $user = auth()->user();
            $totalArticles = \App\Models\News::where('author_id', $user->id)->count();
            $publishedArticles = \App\Models\News::where('author_id', $user->id)->where('is_published', true)->count();
            $draftArticles = \App\Models\News::where('author_id', $user->id)->where('is_published', false)->count();
            $totalViews = \App\Models\News::where('author_id', $user->id)->sum('views_count');
            $autoFetchedToday = \App\Models\News::where('is_auto_fetched', true)->whereDate('fetched_at', today())->count();
        @endphp

        <x-filament::section>
            <div class="text-center">
                <div class="text-3xl font-bold text-primary-600">{{ number_format($totalArticles) }}</div>
                <div class="text-sm text-gray-500">Tổng bài viết</div>
            </div>
        </x-filament::section>

        <x-filament::section>
            <div class="text-center">
                <div class="text-3xl font-bold text-success-600">{{ number_format($publishedArticles) }}</div>
                <div class="text-sm text-gray-500">Đã xuất bản</div>
            </div>
        </x-filament::section>

        <x-filament::section>
            <div class="text-center">
                <div class="text-3xl font-bold text-warning-600">{{ number_format($draftArticles) }}</div>
                <div class="text-sm text-gray-500">Bản nháp</div>
            </div>
        </x-filament::section>

        <x-filament::section>
            <div class="text-center">
                <div class="text-3xl font-bold text-info-600">{{ number_format($totalViews) }}</div>
                <div class="text-sm text-gray-500">Tổng lượt xem</div>
            </div>
        </x-filament::section>
    </div>

    {{-- Auto-fetch Status --}}
    <x-filament::section>
        <x-slot name="heading">
            <div class="flex items-center gap-2">
                <x-heroicon-o-arrow-path class="w-5 h-5 text-primary-500" />
                <span>Tin tức tự động</span>
            </div>
        </x-slot>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                <div class="text-2xl font-bold text-primary-600">{{ $autoFetchedToday }}</div>
                <div class="text-sm text-gray-500">Tin fetch hôm nay</div>
            </div>
            <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                <div class="text-2xl font-bold text-primary-600">
                    {{ \App\Models\News::where('is_auto_fetched', true)->count() }}
                </div>
                <div class="text-sm text-gray-500">Tổng tin auto-fetch</div>
            </div>
            <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                <div class="text-2xl font-bold text-primary-600">5</div>
                <div class="text-sm text-gray-500">Nguồn tin hoạt động</div>
            </div>
        </div>

        <div class="mt-4">
            <h4 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Nguồn tin đang sử dụng:</h4>
            <div class="flex flex-wrap gap-2">
                <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm">VnExpress</span>
                <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm">Thanh Niên</span>
                <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm">Tuổi Trẻ</span>
                <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm">Bóng Đá Plus</span>
                <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm">Bongda24h</span>
            </div>
        </div>
    </x-filament::section>

    {{-- Recent Articles --}}
    <x-filament::section class="mt-6">
        <x-slot name="heading">
            <div class="flex items-center gap-2">
                <x-heroicon-o-document-text class="w-5 h-5 text-primary-500" />
                <span>Bài viết gần đây của bạn</span>
            </div>
        </x-slot>

        @php
            $recentNews = \App\Models\News::where('author_id', $user->id)
                ->orderByDesc('created_at')
                ->limit(5)
                ->get();
        @endphp

        @if($recentNews->count() > 0)
            <div class="space-y-3">
                @foreach($recentNews as $news)
                    <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                        <div class="flex-1">
                            <a href="{{ route('filament.admin.resources.news.edit', $news) }}" class="font-medium text-gray-900 dark:text-white hover:text-primary-600">
                                {{ \Illuminate\Support\Str::limit($news->title, 60) }}
                            </a>
                            <div class="flex items-center gap-3 mt-1 text-sm text-gray-500">
                                <span>{{ $news->created_at->diffForHumans() }}</span>
                                <span class="px-2 py-0.5 rounded text-xs {{ $news->is_published ? 'bg-success-100 text-success-700' : 'bg-warning-100 text-warning-700' }}">
                                    {{ $news->is_published ? 'Đã xuất bản' : 'Bản nháp' }}
                                </span>
                                <span>{{ number_format($news->views_count) }} lượt xem</span>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-8 text-gray-500">
                <x-heroicon-o-document class="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>Bạn chưa có bài viết nào</p>
            </div>
        @endif
    </x-filament::section>

    {{-- Auto-fetched News Today --}}
    <x-filament::section class="mt-6">
        <x-slot name="heading">
            <div class="flex items-center gap-2">
                <x-heroicon-o-globe-alt class="w-5 h-5 text-primary-500" />
                <span>Tin tức tự động hôm nay</span>
            </div>
        </x-slot>

        @php
            $autoFetchedNews = \App\Models\News::where('is_auto_fetched', true)
                ->whereDate('fetched_at', today())
                ->orderByDesc('fetched_at')
                ->limit(10)
                ->get();
        @endphp

        @if($autoFetchedNews->count() > 0)
            <div class="space-y-3">
                @foreach($autoFetchedNews as $news)
                    <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                        <div class="flex-1">
                            <div class="font-medium text-gray-900 dark:text-white">
                                {{ \Illuminate\Support\Str::limit($news->title, 70) }}
                            </div>
                            <div class="flex items-center gap-3 mt-1 text-sm text-gray-500">
                                <span class="px-2 py-0.5 rounded bg-blue-100 text-blue-700 text-xs">
                                    {{ $news->source_name }}
                                </span>
                                <span>{{ $news->fetched_at->diffForHumans() }}</span>
                            </div>
                        </div>
                        <a href="{{ $news->original_url }}" target="_blank" class="text-primary-600 hover:text-primary-800">
                            <x-heroicon-o-arrow-top-right-on-square class="w-5 h-5" />
                        </a>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-8 text-gray-500">
                <x-heroicon-o-globe-alt class="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>Chưa có tin tức tự động hôm nay</p>
                <p class="text-sm">Nhấn nút "Fetch tất cả tin tức" để lấy tin mới</p>
            </div>
        @endif
    </x-filament::section>
</x-filament-panels::page>
