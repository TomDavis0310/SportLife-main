import 'package:json_annotation/json_annotation.dart';
import 'player.dart';
import 'team_staff.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  final int id;
  final String name;
  @JsonKey(name: 'short_name')
  final String? shortName;
  final String? code;
  final String? logo;
  final String? city;
  final String? country;
  final String? stadium;
  @JsonKey(name: 'stadium_capacity')
  final int? stadiumCapacity;
  final int? founded;
  final String? manager;
  @JsonKey(name: 'primary_color')
  final String? primaryColor;
  @JsonKey(name: 'secondary_color')
  final String? secondaryColor;
  @JsonKey(name: 'competition_id')
  final int? competitionId;
  @JsonKey(defaultValue: [])
  final List<Player> players;
  @JsonKey(defaultValue: [])
  final List<TeamStaff> staff;
  final Map<String, dynamic>? pivot;

  Team({
    required this.id,
    required this.name,
    this.shortName,
    this.code,
    this.logo,
    this.city,
    this.country,
    this.stadium,
    this.stadiumCapacity,
    this.founded,
    this.manager,
    this.primaryColor,
    this.secondaryColor,
    this.competitionId,
    this.players = const [],
    this.staff = const [],
    this.pivot,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  // Alias for logo to match UI usage
  String? get logoUrl => logo;
}

