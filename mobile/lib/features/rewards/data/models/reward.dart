import 'package:json_annotation/json_annotation.dart';
import 'sponsor.dart';

part 'reward.g.dart';

@JsonSerializable()
class Reward {
  final int id;
  final String name;
  final String? description;
  final String type;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'points_cost')
  final int pointsCost;
  final int? quantity;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_physical')
  final bool isPhysical;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  final String? terms;
  @JsonKey(name: 'sponsor_id')
  final int? sponsorId;
  final Sponsor? sponsor;

  Reward({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.imageUrl,
    required this.pointsCost,
    this.quantity,
    this.isActive = true,
    this.isPhysical = false,
    this.expiresAt,
    this.terms,
    this.sponsorId,
    this.sponsor,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
  Map<String, dynamic> toJson() => _$RewardToJson(this);

  bool get isAvailable => isActive && (quantity == null || quantity! > 0);

  // Legacy getters to keep older UI code working until fully migrated.
  String? get image => imageUrl;
  int get pointsRequired => pointsCost;
}

