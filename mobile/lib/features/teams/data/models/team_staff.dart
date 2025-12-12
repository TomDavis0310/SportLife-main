import 'package:json_annotation/json_annotation.dart';

part 'team_staff.g.dart';

@JsonSerializable()
class TeamStaff {
  final int id;
  final String name;
  final String role;
  final String? nationality;
  final String? avatar;
  @JsonKey(name: 'joined_date')
  final String? joinedDate;

  TeamStaff({
    required this.id,
    required this.name,
    required this.role,
    this.nationality,
    this.avatar,
    this.joinedDate,
  });

  factory TeamStaff.fromJson(Map<String, dynamic> json) => _$TeamStaffFromJson(json);
  Map<String, dynamic> toJson() => _$TeamStaffToJson(this);
}
