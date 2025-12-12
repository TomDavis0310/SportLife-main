<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NewsResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // Hiển thị content cho trang chi tiết hoặc API journalist
        $isDetailRoute = $request->routeIs('news.show') || 
                         str_contains($request->path(), 'journalist');
        
        return [
            'id' => $this->id,
            'title' => $this->sanitize($this->title),
            'slug' => $this->slug,
            'excerpt' => $this->sanitize($this->excerpt ?? substr(strip_tags($this->content), 0, 200)),
            'content' => $this->when($isDetailRoute, $this->sanitize($this->content)),
            'thumbnail' => $this->thumbnail_url,
            'image' => $this->thumbnail_url,
            'category' => $this->category,
            'views' => $this->views_count ?? 0,
            'is_featured' => $this->is_featured,
            'is_published' => $this->is_published ?? false,
            'author' => $this->when(
                $this->relationLoaded('author'),
                fn() => $this->author?->name
            ),
            'author_id' => $this->author_id,
            'team' => $this->when(
                $this->relationLoaded('team'),
                new TeamResource($this->team)
            ),
            'video_url' => $this->video_url,
            'comments_count' => $this->comments_count ?? 0,
            'likes_count' => $this->likes_count ?? 0,
            'is_liked' => $this->is_liked ?? false,
            'published_at' => $this->published_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
            
            // Auto-fetch fields
            'source_name' => $this->source_name,
            'source_url' => $this->source_url,
            'original_url' => $this->original_url,
            'is_auto_fetched' => $this->is_auto_fetched ?? false,
            'fetched_at' => $this->fetched_at?->toISOString(),
            'tags' => $this->tags ?? [],
        ];
    }

    private function sanitize($value)
    {
        if (is_string($value)) {
            return mb_convert_encoding($value, 'UTF-8', 'UTF-8');
        }
        return $value;
    }
}
