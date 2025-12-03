// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reward _$RewardFromJson(Map<String, dynamic> json) => Reward(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      imageUrl: json['image_url'] as String?,
      pointsCost: (json['points_cost'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      isPhysical: json['is_physical'] as bool? ?? false,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      terms: json['terms'] as String?,
      sponsorId: (json['sponsor_id'] as num?)?.toInt(),
      sponsor: json['sponsor'] == null
          ? null
          : Sponsor.fromJson(json['sponsor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'image_url': instance.imageUrl,
      'points_cost': instance.pointsCost,
      'quantity': instance.quantity,
      'is_active': instance.isActive,
      'is_physical': instance.isPhysical,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'terms': instance.terms,
      'sponsor_id': instance.sponsorId,
      'sponsor': instance.sponsor,
    };
