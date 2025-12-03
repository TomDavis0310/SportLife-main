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
      predictedHomeScore: (json['predicted_home_score'] as num).toInt(),
      predictedAwayScore: (json['predicted_away_score'] as num).toInt(),
      homeScore: (json['home_score'] as num?)?.toInt(),
      awayScore: (json['away_score'] as num?)?.toInt(),
      firstScorerId: (json['first_scorer_id'] as num?)?.toInt(),
      firstScorer: json['first_scorer'] as Map<String, dynamic>?,
      pointsEarned: (json['points_earned'] as num?)?.toInt(),
      isCorrectScore: json['is_correct_score'] as bool?,
      isCorrectOutcome: json['is_correct_outcome'] as bool?,
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
      'predicted_home_score': instance.predictedHomeScore,
      'predicted_away_score': instance.predictedAwayScore,
      'home_score': instance.homeScore,
      'away_score': instance.awayScore,
      'first_scorer_id': instance.firstScorerId,
      'first_scorer': instance.firstScorer,
      'points_earned': instance.pointsEarned,
      'is_correct_score': instance.isCorrectScore,
      'is_correct_outcome': instance.isCorrectOutcome,
      'streak_multiplier': instance.streakMultiplier,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'status': instance.status,
    };
