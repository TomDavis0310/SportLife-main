import 'package:json_annotation/json_annotation.dart';
import '../../../teams/data/models/team.dart';
import 'competition.dart';
import 'match_event.dart';

part 'match.g.dart';

enum MatchStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('live')
  live,
  @JsonValue('halftime')
  halftime,
  @JsonValue('finished')
  finished,
  @JsonValue('postponed')
  postponed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class Match {
  final int id;
  @JsonKey(name: 'home_team_id')
  final int homeTeamId;
  @JsonKey(name: 'away_team_id')
  final int awayTeamId;
  @JsonKey(name: 'competition_id')
  final int? competitionId;
  @JsonKey(name: 'home_team')
  final Team? homeTeam;
  @JsonKey(name: 'away_team')
  final Team? awayTeam;
  final Competition? competition;
  @JsonKey(name: 'home_score')
  final int? homeScore;
  @JsonKey(name: 'away_score')
  final int? awayScore;
  @JsonKey(name: 'halftime_home_score')
  final int? halftimeHomeScore;
  @JsonKey(name: 'halftime_away_score')
  final int? halftimeAwayScore;
  final MatchStatus status;
  @JsonKey(name: 'match_time')
  final String matchTime;
  final int? minute;
  @JsonKey(name: 'round_id')
  final int? roundId;
  @JsonKey(name: 'competition_name')
  final String? competitionName;
  @JsonKey(name: 'round_name')
  final String? roundName;
  @JsonKey(name: 'predictions_count')
  final int? predictionsCount;
  @JsonKey(name: 'user_prediction')
  final dynamic userPrediction;
  // Additional fields for detail view
  final List<MatchEvent>? events;
  @JsonKey(name: 'home_lineup')
  final List<dynamic>? homeLineup;
  @JsonKey(name: 'away_lineup')
  final List<dynamic>? awayLineup;
  @JsonKey(name: 'home_formation')
  final String? homeFormation;
  @JsonKey(name: 'away_formation')
  final String? awayFormation;
  final Map<String, dynamic>? statistics;
  @JsonKey(name: 'can_predict')
  final bool? canPredictField;
  final String? venue;
  @JsonKey(name: 'home_form')
  final List<String>? homeForm;
  @JsonKey(name: 'away_form')
  final List<String>? awayForm;

  Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    this.competitionId,
    this.homeTeam,
    this.awayTeam,
    this.competition,
    this.homeScore,
    this.awayScore,
    this.halftimeHomeScore,
    this.halftimeAwayScore,
    required this.status,
    required this.matchTime,
    this.minute,
    this.roundId,
    this.competitionName,
    this.roundName,
    this.predictionsCount,
    this.userPrediction,
    this.events,
    this.homeLineup,
    this.awayLineup,
    this.homeFormation,
    this.awayFormation,
    this.statistics,
    this.canPredictField,
    this.venue,
    this.homeForm,
    this.awayForm,
  });

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  bool get isLive =>
      status == MatchStatus.live || status == MatchStatus.halftime;
  bool get isFinished => status == MatchStatus.finished;
  bool get isScheduled => status == MatchStatus.scheduled;
  bool get canPredict => canPredictField ?? (status == MatchStatus.scheduled);

  String get scoreDisplay {
    if (homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return 'vs';
  }
}

