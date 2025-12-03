import 'package:json_annotation/json_annotation.dart';

import '../../../teams/data/models/team.dart';

part 'match_highlight.g.dart';

@JsonSerializable()
class MatchHighlight {
  final int id;
  @JsonKey(name: 'match_id')
  final int matchId;
  final String title;
  final String? description;
  final String? provider;
  @JsonKey(name: 'video_url')
  final String videoUrl;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  @JsonKey(name: 'view_count')
  final int? viewCount;
  final Map<String, dynamic>? meta;
  final HighlightMatchSummary? match;

  MatchHighlight({
    required this.id,
    required this.matchId,
    required this.title,
    this.description,
    this.provider,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.publishedAt,
    this.isFeatured,
    this.viewCount,
    this.meta,
    this.match,
  });

  factory MatchHighlight.fromJson(Map<String, dynamic> json) =>
      _$MatchHighlightFromJson(json);
  Map<String, dynamic> toJson() => _$MatchHighlightToJson(this);
}

@JsonSerializable()
class HighlightMatchSummary {
  final int id;
  final String? status;
  @JsonKey(name: 'match_time')
  final String? matchTime;
  @JsonKey(name: 'competition_name')
  final String? competitionName;
  @JsonKey(name: 'home_team')
  final Team? homeTeam;
  @JsonKey(name: 'away_team')
  final Team? awayTeam;
  final HighlightScore? score;

  HighlightMatchSummary({
    required this.id,
    this.status,
    this.matchTime,
    this.competitionName,
    this.homeTeam,
    this.awayTeam,
    this.score,
  });

  factory HighlightMatchSummary.fromJson(Map<String, dynamic> json) =>
      _$HighlightMatchSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$HighlightMatchSummaryToJson(this);
}

@JsonSerializable()
class HighlightScore {
  final int? home;
  final int? away;

  HighlightScore({this.home, this.away});

  factory HighlightScore.fromJson(Map<String, dynamic> json) =>
      _$HighlightScoreFromJson(json);
  Map<String, dynamic> toJson() => _$HighlightScoreToJson(this);
}
