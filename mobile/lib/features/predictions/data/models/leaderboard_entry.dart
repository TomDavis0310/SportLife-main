import '../../../../core/config/app_config.dart';

class LeaderboardEntry {
  final int userId;
  final int totalPoints;
  final int totalPredictions;
  final int correctScores;
  final int correctDifferences;
  final int correctWinners;
  final int rank;
  final Map<String, dynamic>? user;

  LeaderboardEntry({
    required this.userId,
    required this.totalPoints,
    required this.totalPredictions,
    required this.correctScores,
    required this.correctDifferences,
    required this.correctWinners,
    required this.rank,
    this.user,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: _parseInt(json['user_id']),
      totalPoints: _parseInt(json['total_points']),
      totalPredictions: _parseInt(json['total_predictions']),
      correctScores: _parseInt(json['correct_scores']),
      correctDifferences: _parseInt(json['correct_differences']),
      correctWinners: _parseInt(json['correct_winners']),
      rank: _parseInt(json['rank']),
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  String get userName => user?['name'] ?? 'User';
  
  String get userAvatar {
    final avatar = user?['avatar'] ?? '';
    if (avatar.isEmpty) return '';
    if (avatar.startsWith('http')) return avatar;
    return '${AppConfig.imageUrl}$avatar';
  }
}
