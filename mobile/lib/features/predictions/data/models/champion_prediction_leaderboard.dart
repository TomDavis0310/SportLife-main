import '../../../../core/config/app_config.dart';

class ChampionPredictionLeaderboardEntry {
  final int userId;
  final int? seasonId;
  final int totalPredictions;
  final int correctPredictions;
  final int totalPointsWagered;
  final int totalPointsEarned;
  final int profit;
  final double winRate;
  final int? rank;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? season;

  ChampionPredictionLeaderboardEntry({
    required this.userId,
    this.seasonId,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.totalPointsWagered,
    required this.totalPointsEarned,
    required this.profit,
    required this.winRate,
    this.rank,
    this.user,
    this.season,
  });

  factory ChampionPredictionLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return ChampionPredictionLeaderboardEntry(
      userId: json['user_id'] ?? 0,
      seasonId: json['season_id'],
      totalPredictions: json['total_predictions'] ?? 0,
      correctPredictions: json['correct_predictions'] ?? 0,
      totalPointsWagered: json['total_points_wagered'] ?? 0,
      totalPointsEarned: json['total_points_earned'] ?? 0,
      profit: json['profit'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      rank: json['rank'],
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      season: json['season'] is Map ? Map<String, dynamic>.from(json['season']) : null,
    );
  }

  String get userName => user?['name'] ?? 'User';
  
  String get userAvatar {
    final avatar = user?['avatar'] ?? '';
    if (avatar.isEmpty) return '';
    if (avatar.startsWith('http')) return avatar;
    return '${AppConfig.imageUrl}$avatar';
  }

  String get seasonName => season?['name'] ?? 'All Time';
}
