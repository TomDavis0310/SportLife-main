// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competition _$CompetitionFromJson(Map<String, dynamic> json) => Competition(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String?,
      type: json['type'] as String?,
      logo: json['logo'] as String?,
      flag: json['flag'] as String?,
      country: json['country'] as String?,
      currentSeason: json['current_season'] == null
          ? null
          : Season.fromJson(json['current_season'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompetitionToJson(Competition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'type': instance.type,
      'logo': instance.logo,
      'flag': instance.flag,
      'country': instance.country,
      'current_season': instance.currentSeason,
    };

Season _$SeasonFromJson(Map<String, dynamic> json) => Season(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
    );

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'is_current': instance.isCurrent,
    };
