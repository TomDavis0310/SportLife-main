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
      publishedAt: json['published_at'] as String?,
      isLiked: json['is_liked'] as bool?,
      author: json['author'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
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
      'published_at': instance.publishedAt,
      'is_liked': instance.isLiked,
      'author': instance.author,
      'tags': instance.tags,
    };
