import 'package:json_annotation/json_annotation.dart';

part 'competition.g.dart';

@JsonSerializable()
class Competition {
  final int id;
  final String name;
  final String? code;
  final String? type;
  final String? logo;
  final String? flag;
  final String? country;
  @JsonKey(name: 'current_season')
  final Season? currentSeason;

  Competition({
    required this.id,
    required this.name,
    this.code,
    this.type,
    this.logo,
    this.flag,
    this.country,
    this.currentSeason,
  });

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);
  Map<String, dynamic> toJson() => _$CompetitionToJson(this);
}

@JsonSerializable()
class Season {
  final int id;
  final String name;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'is_current')
  final bool isCurrent;

  Season({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonToJson(this);
}

