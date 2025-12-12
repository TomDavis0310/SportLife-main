// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
      id: (json['id'] as num).toInt(),
      homeTeamId: (json['home_team_id'] as num?)?.toInt(),
      awayTeamId: (json['away_team_id'] as num?)?.toInt(),
      competitionId: (json['competition_id'] as num?)?.toInt(),
      homeTeam: json['home_team'] == null
          ? null
          : Team.fromJson(json['home_team'] as Map<String, dynamic>),
      awayTeam: json['away_team'] == null
          ? null
          : Team.fromJson(json['away_team'] as Map<String, dynamic>),
      competition: json['competition'] == null
          ? null
          : Competition.fromJson(json['competition'] as Map<String, dynamic>),
      homeScore: (json['home_score'] as num?)?.toInt(),
      awayScore: (json['away_score'] as num?)?.toInt(),
      halftimeHomeScore: (json['halftime_home_score'] as num?)?.toInt(),
      halftimeAwayScore: (json['halftime_away_score'] as num?)?.toInt(),
      status: $enumDecode(_$MatchStatusEnumMap, json['status']),
      matchTime: json['match_time'] as String,
      minute: (json['minute'] as num?)?.toInt(),
      roundId: (json['round_id'] as num?)?.toInt(),
      competitionName: json['competition_name'] as String?,
      roundName: json['round_name'] as String?,
      predictionsCount: (json['predictions_count'] as num?)?.toInt(),
      userPrediction: json['user_prediction'],
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeLineup: json['home_lineup'] as List<dynamic>?,
      awayLineup: json['away_lineup'] as List<dynamic>?,
      homeFormation: json['home_formation'] as String?,
      awayFormation: json['away_formation'] as String?,
      statistics: json['statistics'] as Map<String, dynamic>?,
      canPredictField: json['can_predict'] as bool?,
      venue: json['venue'] as String?,
      homeForm: (json['home_form'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      awayForm: (json['away_form'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'home_team_id': instance.homeTeamId,
      'away_team_id': instance.awayTeamId,
      'competition_id': instance.competitionId,
      'home_team': instance.homeTeam,
      'away_team': instance.awayTeam,
      'competition': instance.competition,
      'home_score': instance.homeScore,
      'away_score': instance.awayScore,
      'halftime_home_score': instance.halftimeHomeScore,
      'halftime_away_score': instance.halftimeAwayScore,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'match_time': instance.matchTime,
      'minute': instance.minute,
      'round_id': instance.roundId,
      'competition_name': instance.competitionName,
      'round_name': instance.roundName,
      'predictions_count': instance.predictionsCount,
      'user_prediction': instance.userPrediction,
      'events': instance.events,
      'home_lineup': instance.homeLineup,
      'away_lineup': instance.awayLineup,
      'home_formation': instance.homeFormation,
      'away_formation': instance.awayFormation,
      'statistics': instance.statistics,
      'can_predict': instance.canPredictField,
      'venue': instance.venue,
      'home_form': instance.homeForm,
      'away_form': instance.awayForm,
    };

const _$MatchStatusEnumMap = {
  MatchStatus.scheduled: 'scheduled',
  MatchStatus.live: 'live',
  MatchStatus.halftime: 'halftime',
  MatchStatus.finished: 'finished',
  MatchStatus.postponed: 'postponed',
  MatchStatus.cancelled: 'cancelled',
};
