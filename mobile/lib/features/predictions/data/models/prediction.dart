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
  @JsonKey(name: 'predicted_outcome')
  final String predictedOutcome; // 'home', 'draw', 'away'
  @JsonKey(name: 'predicted_outcome_label')
  final String? predictedOutcomeLabel;
  @JsonKey(name: 'points_earned')
  final int? pointsEarned;
  @JsonKey(name: 'is_correct_outcome')
  final bool? isCorrectOutcome;
  @JsonKey(name: 'is_correct')
  final bool? isCorrect;
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
    required this.predictedOutcome,
    this.predictedOutcomeLabel,
    this.pointsEarned,
    this.isCorrectOutcome,
    this.isCorrect,
    this.streakMultiplier,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionToJson(this);

  String get predictionDisplay => predictedOutcomeLabel ?? _getOutcomeLabel(predictedOutcome);
  bool get isSettled => pointsEarned != null || status == 'completed';
  bool get isPredictionCorrect => isCorrectOutcome == true || isCorrect == true;
  
  String _getOutcomeLabel(String outcome) {
    switch (outcome) {
      case 'home':
        return 'Đội nhà thắng';
      case 'draw':
        return 'Hòa';
      case 'away':
        return 'Đội khách thắng';
      default:
        return outcome;
    }
  }
}

