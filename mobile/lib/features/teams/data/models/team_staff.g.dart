// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamStaff _$TeamStaffFromJson(Map<String, dynamic> json) => TeamStaff(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      role: json['role'] as String,
      nationality: json['nationality'] as String?,
      avatar: json['avatar'] as String?,
      joinedDate: json['joined_date'] as String?,
    );

Map<String, dynamic> _$TeamStaffToJson(TeamStaff instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'nationality': instance.nationality,
      'avatar': instance.avatar,
      'joined_date': instance.joinedDate,
    };
