import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final int id;
  final String name;
  final String? position;
  @JsonKey(name: 'jersey_number')
  final int? jerseyNumber;
  final String? avatar;
  final String? nationality;
  final int? height;
  final int? weight;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @JsonKey(name: 'market_value', fromJson: _stringToInt)
  final int? marketValue;
  @JsonKey(name: 'contract_until')
  final String? contractUntil;
  @JsonKey(name: 'is_captain')
  final bool? isCaptain;

  Player({
    required this.id,
    required this.name,
    this.position,
    this.jerseyNumber,
    this.avatar,
    this.nationality,
    this.height,
    this.weight,
    this.birthDate,
    this.marketValue,
    this.contractUntil,
    this.isCaptain,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

int? _stringToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return double.tryParse(value)?.toInt();
  }
  return null;
}
