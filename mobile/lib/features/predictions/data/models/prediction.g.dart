// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prediction _$PredictionFromJson(Map<String, dynamic> json) => Prediction(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      matchId: (json['match_id'] as num).toInt(),
      match: json['match'] == null
          ? null
          : Match.fromJson(json['match'] as Map<String, dynamic>),
      predictedOutcome: json['predicted_outcome'] as String,
      predictedOutcomeLabel: json['predicted_outcome_label'] as String?,
      pointsEarned: (json['points_earned'] as num?)?.toInt(),
      isCorrectOutcome: json['is_correct_outcome'] as bool?,
      isCorrect: json['is_correct'] as bool?,
      streakMultiplier: (json['streak_multiplier'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'match_id': instance.matchId,
      'match': instance.match?.toJson(),
      'predicted_outcome': instance.predictedOutcome,
      'predicted_outcome_label': instance.predictedOutcomeLabel,
      'points_earned': instance.pointsEarned,
      'is_correct_outcome': instance.isCorrectOutcome,
      'is_correct': instance.isCorrect,
      'streak_multiplier': instance.streakMultiplier,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'status': instance.status,
    };
