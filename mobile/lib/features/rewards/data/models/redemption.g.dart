// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Redemption _$RedemptionFromJson(Map<String, dynamic> json) => Redemption(
      id: (json['id'] as num).toInt(),
      rewardId: (json['reward_id'] as num?)?.toInt(),
      status: json['status'] as String,
      voucherCode: json['voucher_code'] as String?,
      pointsSpent: (json['points_spent'] as num?)?.toInt(),
      shippingName: json['shipping_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      reward: json['reward'] == null
          ? null
          : Reward.fromJson(json['reward'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RedemptionToJson(Redemption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reward_id': instance.rewardId,
      'status': instance.status,
      'voucher_code': instance.voucherCode,
      'points_spent': instance.pointsSpent,
      'shipping_name': instance.shippingName,
      'shipping_phone': instance.shippingPhone,
      'shipping_address': instance.shippingAddress,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
      'reward': instance.reward,
    };
