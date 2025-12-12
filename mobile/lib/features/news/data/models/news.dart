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
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  @JsonKey(name: 'is_liked')
  final bool? isLiked;
  final String? author;
  @JsonKey(name: 'author_id')
  final int? authorId;
  final List<String>? tags;
  
  // New fields for auto-fetched news
  @JsonKey(name: 'source_name')
  final String? sourceName;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @JsonKey(name: 'original_url')
  final String? originalUrl;
  @JsonKey(name: 'is_auto_fetched')
  final bool? isAutoFetched;
  @JsonKey(name: 'fetched_at')
  final String? fetchedAt;

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
    this.isPublished = false,
    this.publishedAt,
    this.isLiked,
    this.author,
    this.authorId,
    this.tags,
    this.sourceName,
    this.sourceUrl,
    this.originalUrl,
    this.isAutoFetched,
    this.fetchedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);

  // Alias for views
  int? get viewCount => views;
  
  // Check if news is from external source
  bool get isFromExternalSource => isAutoFetched == true || sourceName != null;
  
  // Get display source name
  String? get displaySource => sourceName ?? (sourceUrl != null ? Uri.parse(sourceUrl!).host : null);
}

