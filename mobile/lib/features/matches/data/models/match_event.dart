import 'package:json_annotation/json_annotation.dart';

part 'match_event.g.dart';

@JsonSerializable()
class MatchEvent {
  final int id;
  @JsonKey(name: 'match_id')
  final int matchId;
  @JsonKey(name: 'event_type')
  final String eventType;
  @JsonKey(name: 'team_side')
  final String? teamSide;
  final int minute;
  @JsonKey(name: 'extra_minute')
  final int? extraMinute;
  @JsonKey(name: 'player_id')
  final int? playerId;
  @JsonKey(name: 'player_name')
  final String? playerName;
  @JsonKey(name: 'assist_player_id')
  final int? assistPlayerId;
  @JsonKey(name: 'assist_player_name')
  final String? assistPlayerName;
  @JsonKey(name: 'secondary_player_id')
  final int? secondaryPlayerId;
  @JsonKey(name: 'secondary_player_name')
  final String? secondaryPlayerName;
  @JsonKey(name: 'substitute_player_id')
  final int? substitutePlayerId;
  @JsonKey(name: 'substitute_player_name')
  final String? substitutePlayerName;
  @JsonKey(name: 'team_id')
  final int? teamId;
  final String? description;
  @JsonKey(name: 'display_minute')
  final String? displayMinute;
  final String? icon;
  @JsonKey(name: 'type_label')
  final String? typeLabel;

  MatchEvent({
    required this.id,
    required this.matchId,
    required this.eventType,
    this.teamSide,
    required this.minute,
    this.extraMinute,
    this.playerId,
    this.playerName,
    this.assistPlayerId,
    this.assistPlayerName,
    this.secondaryPlayerId,
    this.secondaryPlayerName,
    this.substitutePlayerId,
    this.substitutePlayerName,
    this.teamId,
    this.description,
    this.displayMinute,
    this.icon,
    this.typeLabel,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) =>
      _$MatchEventFromJson(json);
  Map<String, dynamic> toJson() => _$MatchEventToJson(this);

  String get displayTime =>
      displayMinute ?? (extraMinute != null && extraMinute! > 0 ? "$minute'+$extraMinute" : "$minute'");

  bool get isGoal => eventType == 'goal' || eventType == 'penalty';
  bool get isCard => eventType == 'yellow_card' || eventType == 'red_card';
  bool get isSubstitution => eventType == 'substitution';

  bool get isHomeSide => teamSide == 'home';

  String? get substitutionLabel {
    if (!isSubstitution) return null;
    if (playerName == null && substitutePlayerName == null) return null;
    if (playerName != null && substitutePlayerName != null) {
      return '${playerName!} → ${substitutePlayerName!}';
    }
    return playerName ?? substitutePlayerName;
  }
}

