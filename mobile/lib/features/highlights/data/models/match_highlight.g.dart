// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_highlight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchHighlight _$MatchHighlightFromJson(Map<String, dynamic> json) =>
    MatchHighlight(
      id: (json['id'] as num).toInt(),
      matchId: (json['match_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      provider: json['provider'] as String?,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      publishedAt: json['published_at'] as String?,
      isFeatured: json['is_featured'] as bool?,
      viewCount: (json['view_count'] as num?)?.toInt(),
      meta: json['meta'] as Map<String, dynamic>?,
      match: json['match'] == null
          ? null
          : HighlightMatchSummary.fromJson(
              json['match'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MatchHighlightToJson(MatchHighlight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'match_id': instance.matchId,
      'title': instance.title,
      'description': instance.description,
      'provider': instance.provider,
      'video_url': instance.videoUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'duration_seconds': instance.durationSeconds,
      'published_at': instance.publishedAt,
      'is_featured': instance.isFeatured,
      'view_count': instance.viewCount,
      'meta': instance.meta,
      'match': instance.match,
    };

HighlightMatchSummary _$HighlightMatchSummaryFromJson(
        Map<String, dynamic> json) =>
    HighlightMatchSummary(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String?,
      matchTime: json['match_time'] as String?,
      competitionName: json['competition_name'] as String?,
      homeTeam: json['home_team'] == null
          ? null
          : Team.fromJson(json['home_team'] as Map<String, dynamic>),
      awayTeam: json['away_team'] == null
          ? null
          : Team.fromJson(json['away_team'] as Map<String, dynamic>),
      score: json['score'] == null
          ? null
          : HighlightScore.fromJson(json['score'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HighlightMatchSummaryToJson(
        HighlightMatchSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'match_time': instance.matchTime,
      'competition_name': instance.competitionName,
      'home_team': instance.homeTeam,
      'away_team': instance.awayTeam,
      'score': instance.score,
    };

HighlightScore _$HighlightScoreFromJson(Map<String, dynamic> json) =>
    HighlightScore(
      home: (json['home'] as num?)?.toInt(),
      away: (json['away'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HighlightScoreToJson(HighlightScore instance) =>
    <String, dynamic>{
      'home': instance.home,
      'away': instance.away,
    };
