import 'package:json_annotation/json_annotation.dart';
import 'reward.dart';

part 'redemption.g.dart';

@JsonSerializable()
class Redemption {
  final int id;
  @JsonKey(name: 'reward_id')
  final int? rewardId;
  final String status;
  @JsonKey(name: 'voucher_code')
  final String? voucherCode;
  @JsonKey(name: 'points_spent')
  final int? pointsSpent;
  @JsonKey(name: 'shipping_name')
  final String? shippingName;
  @JsonKey(name: 'shipping_phone')
  final String? shippingPhone;
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;
  final Reward? reward;

  Redemption({
    required this.id,
    this.rewardId,
    required this.status,
    this.voucherCode,
    this.pointsSpent,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    this.notes,
    this.createdAt,
    this.processedAt,
    this.reward,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) =>
      _$RedemptionFromJson(json);
  Map<String, dynamic> toJson() => _$RedemptionToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isUsed => status == 'used';
  bool get isExpired => status == 'expired';
  bool get isRejected => status == 'rejected';
}

