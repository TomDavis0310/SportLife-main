// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) => MatchEvent(
      id: (json['id'] as num).toInt(),
      matchId: (json['match_id'] as num).toInt(),
      eventType: json['event_type'] as String,
      teamSide: json['team_side'] as String?,
      minute: (json['minute'] as num).toInt(),
      extraMinute: (json['extra_minute'] as num?)?.toInt(),
      playerId: (json['player_id'] as num?)?.toInt(),
      playerName: json['player_name'] as String?,
      assistPlayerId: (json['assist_player_id'] as num?)?.toInt(),
      assistPlayerName: json['assist_player_name'] as String?,
      secondaryPlayerId: (json['secondary_player_id'] as num?)?.toInt(),
      secondaryPlayerName: json['secondary_player_name'] as String?,
      substitutePlayerId: (json['substitute_player_id'] as num?)?.toInt(),
      substitutePlayerName: json['substitute_player_name'] as String?,
      teamId: (json['team_id'] as num?)?.toInt(),
      description: json['description'] as String?,
      displayMinute: json['display_minute'] as String?,
      icon: json['icon'] as String?,
      typeLabel: json['type_label'] as String?,
    );

Map<String, dynamic> _$MatchEventToJson(MatchEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'match_id': instance.matchId,
      'event_type': instance.eventType,
      'team_side': instance.teamSide,
      'minute': instance.minute,
      'extra_minute': instance.extraMinute,
      'player_id': instance.playerId,
      'player_name': instance.playerName,
      'assist_player_id': instance.assistPlayerId,
      'assist_player_name': instance.assistPlayerName,
      'secondary_player_id': instance.secondaryPlayerId,
      'secondary_player_name': instance.secondaryPlayerName,
      'substitute_player_id': instance.substitutePlayerId,
      'substitute_player_name': instance.substitutePlayerName,
      'team_id': instance.teamId,
      'description': instance.description,
      'display_minute': instance.displayMinute,
      'icon': instance.icon,
      'type_label': instance.typeLabel,
    };
