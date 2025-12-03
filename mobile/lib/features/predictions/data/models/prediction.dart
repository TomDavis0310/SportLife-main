import 'package:json_annotation/json_annotation.dart';

import '../../../matches/data/models/match.dart';

part 'prediction.g.dart';

@JsonSerializable(explicitToJson: true)
class Prediction {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'match_id')
  final int matchId;
  final Match? match;
  @JsonKey(name: 'predicted_home_score')
  final int predictedHomeScore;
  @JsonKey(name: 'predicted_away_score')
  final int predictedAwayScore;
  @JsonKey(name: 'home_score')
  final int? homeScore;
  @JsonKey(name: 'away_score')
  final int? awayScore;
  @JsonKey(name: 'first_scorer_id')
  final int? firstScorerId;
  @JsonKey(name: 'first_scorer')
  final Map<String, dynamic>? firstScorer;
  @JsonKey(name: 'points_earned')
  final int? pointsEarned;
  @JsonKey(name: 'is_correct_score')
  final bool? isCorrectScore;
  @JsonKey(name: 'is_correct_outcome')
  final bool? isCorrectOutcome;
  @JsonKey(name: 'streak_multiplier')
  final double? streakMultiplier;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final String? status;

  Prediction({
    required this.id,
    required this.userId,
    required this.matchId,
    this.match,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    this.homeScore,
    this.awayScore,
    this.firstScorerId,
    this.firstScorer,
    this.pointsEarned,
    this.isCorrectScore,
    this.isCorrectOutcome,
    this.streakMultiplier,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionToJson(this);

  String get predictionDisplay => '$predictedHomeScore - $predictedAwayScore';
  bool get isSettled => pointsEarned != null || status == 'completed';
  bool get isCorrect => isCorrectScore == true || isCorrectOutcome == true;
}

