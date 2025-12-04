<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NewsResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->sanitize($this->title),
            'slug' => $this->slug,
            'excerpt' => $this->sanitize($this->excerpt ?? substr(strip_tags($this->content), 0, 200)),
            'content' => $this->when($request->routeIs('news.show'), $this->sanitize($this->content)),
            'thumbnail' => $this->thumbnail_url,
            'image' => $this->thumbnail_url,
            'category' => $this->category,
            'views' => $this->views_count ?? 0,
            'is_featured' => $this->is_featured,
            'author' => $this->when(
                $this->relationLoaded('author'),
                fn() => $this->author?->name
            ),
            'team' => $this->when(
                $this->relationLoaded('team'),
                new TeamResource($this->team)
            ),
            'comments_count' => $this->comments_count ?? 0,
            'likes_count' => $this->likes_count ?? 0,
            'is_liked' => $this->is_liked ?? false,
            'published_at' => $this->published_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
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
