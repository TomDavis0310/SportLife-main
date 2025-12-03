<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CommentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'content' => $this->content,
            'user' => $this->when(
                $this->relationLoaded('user'),
                fn() => [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                    'username' => $this->user->username,
                    'avatar' => $this->user->avatar_url,
                ]
            ),
            'replies' => $this->when(
                $this->relationLoaded('replies'),
                CommentResource::collection($this->replies)
            ),
            'replies_count' => $this->replies_count ?? 0,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
