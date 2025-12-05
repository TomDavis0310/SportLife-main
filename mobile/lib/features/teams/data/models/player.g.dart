// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      position: json['position'] as String?,
      jerseyNumber: (json['jersey_number'] as num?)?.toInt(),
      avatar: json['avatar'] as String?,
      nationality: json['nationality'] as String?,
      height: (json['height'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      birthDate: json['birth_date'] as String?,
      marketValue: _stringToInt(json['market_value']),
      contractUntil: json['contract_until'] as String?,
      isCaptain: json['is_captain'] as bool?,
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'position': instance.position,
      'jersey_number': instance.jerseyNumber,
      'avatar': instance.avatar,
      'nationality': instance.nationality,
      'height': instance.height,
      'weight': instance.weight,
      'birth_date': instance.birthDate,
      'market_value': instance.marketValue,
      'contract_until': instance.contractUntil,
      'is_captain': instance.isCaptain,
    };
