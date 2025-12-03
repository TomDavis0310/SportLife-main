import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String? email; // Made optional for cases where email is not returned
  final String? avatar;
  final String? phone;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'favorite_team_id')
  final int? favoriteTeamId;
  @JsonKey(name: 'sport_points', defaultValue: 0)
  final int sportPoints;
  @JsonKey(name: 'total_points', defaultValue: 0)
  final int totalPoints;
  @JsonKey(name: 'predictions_count', defaultValue: 0)
  final int predictionsCount;
  @JsonKey(name: 'correct_predictions', defaultValue: 0)
  final int correctPredictions;
  @JsonKey(name: 'exact_predictions', defaultValue: 0)
  final int exactPredictions;
  @JsonKey(name: 'prediction_streak', defaultValue: 0)
  final int currentStreak;
  @JsonKey(name: 'max_prediction_streak', defaultValue: 0)
  final int bestStreak;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'roles', defaultValue: [])
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
    this.phone,
    this.dateOfBirth,
    this.favoriteTeamId,
    this.sportPoints = 0,
    this.totalPoints = 0,
    this.predictionsCount = 0,
    this.correctPredictions = 0,
    this.exactPredictions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.createdAt,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  double get accuracy {
    if (predictionsCount == 0) return 0;
    return (correctPredictions / predictionsCount) * 100;
  }
}

