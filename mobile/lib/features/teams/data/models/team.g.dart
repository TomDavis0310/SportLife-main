// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      code: json['code'] as String?,
      logo: json['logo'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      stadium: json['stadium'] as String?,
      stadiumCapacity: (json['stadium_capacity'] as num?)?.toInt(),
      founded: (json['founded'] as num?)?.toInt(),
      manager: json['manager'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      competitionId: (json['competition_id'] as num?)?.toInt(),
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staff: (json['staff'] as List<dynamic>?)
              ?.map((e) => TeamStaff.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pivot: json['pivot'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'short_name': instance.shortName,
      'code': instance.code,
      'logo': instance.logo,
      'city': instance.city,
      'country': instance.country,
      'stadium': instance.stadium,
      'stadium_capacity': instance.stadiumCapacity,
      'founded': instance.founded,
      'manager': instance.manager,
      'primary_color': instance.primaryColor,
      'secondary_color': instance.secondaryColor,
      'competition_id': instance.competitionId,
      'players': instance.players,
      'staff': instance.staff,
      'pivot': instance.pivot,
    };
