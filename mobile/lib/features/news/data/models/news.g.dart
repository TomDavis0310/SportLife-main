// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      excerpt: json['excerpt'] as String?,
      content: json['content'] as String?,
      image: json['image'] as String?,
      videoUrl: json['video_url'] as String?,
      category: json['category'] as String,
      teamId: (json['team_id'] as num?)?.toInt(),
      matchId: (json['match_id'] as num?)?.toInt(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt(),
      commentsCount: (json['comments_count'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      publishedAt: json['published_at'] as String?,
      isLiked: json['is_liked'] as bool?,
      author: json['author'] as String?,
      authorId: (json['author_id'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      originalUrl: json['original_url'] as String?,
      isAutoFetched: json['is_auto_fetched'] as bool?,
      fetchedAt: json['fetched_at'] as String?,
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'content': instance.content,
      'image': instance.image,
      'video_url': instance.videoUrl,
      'category': instance.category,
      'team_id': instance.teamId,
      'match_id': instance.matchId,
      'views': instance.views,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'is_featured': instance.isFeatured,
      'is_published': instance.isPublished,
      'published_at': instance.publishedAt,
      'is_liked': instance.isLiked,
      'author': instance.author,
      'author_id': instance.authorId,
      'tags': instance.tags,
      'source_name': instance.sourceName,
      'source_url': instance.sourceUrl,
      'original_url': instance.originalUrl,
      'is_auto_fetched': instance.isAutoFetched,
      'fetched_at': instance.fetchedAt,
    };
