// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      favoriteTeamId: (json['favorite_team_id'] as num?)?.toInt(),
      sportPoints: (json['sport_points'] as num?)?.toInt() ?? 0,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      predictionsCount: (json['predictions_count'] as num?)?.toInt() ?? 0,
      correctPredictions: (json['correct_predictions'] as num?)?.toInt() ?? 0,
      exactPredictions: (json['exact_predictions'] as num?)?.toInt() ?? 0,
      currentStreak: (json['prediction_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['max_prediction_streak'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatar': instance.avatar,
      'phone': instance.phone,
      'date_of_birth': instance.dateOfBirth,
      'favorite_team_id': instance.favoriteTeamId,
      'sport_points': instance.sportPoints,
      'total_points': instance.totalPoints,
      'predictions_count': instance.predictionsCount,
      'correct_predictions': instance.correctPredictions,
      'exact_predictions': instance.exactPredictions,
      'prediction_streak': instance.currentStreak,
      'max_prediction_streak': instance.bestStreak,
      'created_at': instance.createdAt,
      'roles': instance.roles,
    };
