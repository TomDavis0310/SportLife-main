import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

@JsonSerializable()
class News {
  final int id;
  final String title;
  final String? excerpt;
  final String? content;
  final String? image;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  final String category;
  @JsonKey(name: 'team_id')
  final int? teamId;
  @JsonKey(name: 'match_id')
  final int? matchId;
  final int views;
  @JsonKey(name: 'likes_count')
  final int? likesCount;
  @JsonKey(name: 'comments_count')
  final int? commentsCount;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  @JsonKey(name: 'is_liked')
  final bool? isLiked;
  final String? author;
  final List<String>? tags;

  News({
    required this.id,
    required this.title,
    this.excerpt,
    this.content,
    this.image,
    this.videoUrl,
    required this.category,
    this.teamId,
    this.matchId,
    this.views = 0,
    this.likesCount,
    this.commentsCount,
    this.isFeatured = false,
    this.publishedAt,
    this.isLiked,
    this.author,
    this.tags,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);

  // Alias for views
  int? get viewCount => views;
}

