<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class News extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'author_id',
        'team_id',
        'title',
        'title_en',
        'slug',
        'content',
        'content_en',
        'thumbnail',
        'category',
        'video_url',
        'is_featured',
        'views_count',
        'is_published',
        'published_at',
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'is_published' => 'boolean',
        'views_count' => 'integer',
        'published_at' => 'datetime',
    ];

    /**
     * Register media collections
     */
    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('thumbnail')
            ->singleFile()
            ->useFallbackUrl('/images/default-news.png');

        $this->addMediaCollection('gallery');
    }

    /**
     * Get the news thumbnail URL
     */
    public function getThumbnailUrlAttribute(): string
    {
        return $this->getFirstMediaUrl('thumbnail') ?: ($this->thumbnail ?? '/images/default-news.png');
    }

    /**
     * Author
     */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    /**
     * Related team
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Comments
     */
    public function comments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable');
    }

    /**
     * Likes
     */
    public function likes(): MorphMany
    {
        return $this->morphMany(Like::class, 'likeable');
    }

    /**
     * Get localized title
     */
    public function getLocalizedTitleAttribute(): string
    {
        $locale = app()->getLocale();
        return $locale === 'en' && $this->title_en ? $this->title_en : $this->title;
    }

    /**
     * Get localized content
     */
    public function getLocalizedContentAttribute(): string
    {
        $locale = app()->getLocale();
        return $locale === 'en' && $this->content_en ? $this->content_en : $this->content;
    }

    /**
     * Get category label
     */
    public function getCategoryLabelAttribute(): string
    {
        return match ($this->category) {
            'hot_news' => __('Tin nóng'),
            'highlight' => __('Highlight'),
            'interview' => __('Phỏng vấn'),
            'team_news' => __('Tin đội bóng'),
            'transfer' => __('Chuyển nhượng'),
            default => $this->category,
        };
    }

    /**
     * Increment view count
     */
    public function incrementViews(): void
    {
        $this->increment('views_count');
    }

    /**
     * Generate slug
     */
    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($news) {
            if (!$news->slug) {
                $news->slug = \Str::slug($news->title) . '-' . time();
            }
        });
    }

    /**
     * Scope for published news
     */
    public function scopePublished($query)
    {
        return $query->where('is_published', true)
            ->where('published_at', '<=', now())
            ->orderByDesc('published_at');
    }

    /**
     * Scope for featured news
     */
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true)->published();
    }
}
