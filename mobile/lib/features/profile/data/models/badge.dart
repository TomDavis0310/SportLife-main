import 'package:json_annotation/json_annotation.dart';

part 'badge.g.dart';

@JsonSerializable()
class Badge {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  final String type;
  @JsonKey(name: 'requirement_value')
  final int? requirementValue;
  @JsonKey(name: 'points_reward')
  final int pointsReward;
  @JsonKey(name: 'is_active')
  final bool isActive;

  Badge({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.type,
    this.requirementValue,
    this.pointsReward = 0,
    this.isActive = true,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}

@JsonSerializable()
class UserBadge {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'badge_id')
  final int badgeId;
  @JsonKey(name: 'earned_at')
  final DateTime earnedAt;
  final Badge? badge;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
    this.badge,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}

