import '../../../../core/config/app_config.dart';

class ChampionPrediction {
  final int id;
  final int userId;
  final int seasonId;
  final int predictedTeamId;
  final String? reason;
  final int confidenceLevel;
  final int pointsWagered;
  final int? pointsEarned;
  final int potentialWinnings;
  final double multiplier;
  final String status;
  final String statusLabel;
  final bool isPending;
  final bool isWon;
  final bool isLost;
  final String? calculatedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? season;
  final Map<String, dynamic>? predictedTeam;

  ChampionPrediction({
    required this.id,
    required this.userId,
    required this.seasonId,
    required this.predictedTeamId,
    this.reason,
    required this.confidenceLevel,
    required this.pointsWagered,
    this.pointsEarned,
    required this.potentialWinnings,
    required this.multiplier,
    required this.status,
    required this.statusLabel,
    required this.isPending,
    required this.isWon,
    required this.isLost,
    this.calculatedAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.season,
    this.predictedTeam,
  });

  factory ChampionPrediction.fromJson(Map<String, dynamic> json) {
    return ChampionPrediction(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      predictedTeamId: json['predicted_team_id'] ?? 0,
      reason: json['reason'],
      confidenceLevel: json['confidence_level'] ?? 50,
      pointsWagered: json['points_wagered'] ?? 0,
      pointsEarned: json['points_earned'],
      potentialWinnings: json['potential_winnings'] ?? 0,
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'Đang chờ',
      isPending: json['is_pending'] ?? true,
      isWon: json['is_won'] ?? false,
      isLost: json['is_lost'] ?? false,
      calculatedAt: json['calculated_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      season: json['season'] is Map ? Map<String, dynamic>.from(json['season']) : null,
      predictedTeam: json['predicted_team'] is Map ? Map<String, dynamic>.from(json['predicted_team']) : null,
    );
  }

  // Getters for nested data
  String get teamName => predictedTeam?['name'] ?? predictedTeam?['short_name'] ?? 'Unknown';
  String get teamShortName => predictedTeam?['short_name'] ?? teamName;
  
  String get teamLogoUrl {
    final logo = predictedTeam?['logo_url'] ?? '';
    if (logo.isEmpty) return '';
    if (logo.startsWith('http')) return logo;
    return '${AppConfig.imageUrl}$logo';
  }

  String get seasonName => season?['name'] ?? 'Unknown Season';
  String get competitionName => season?['competition']?['name'] ?? 'Unknown Competition';
  
  String get userName => user?['name'] ?? 'User';
  
  String get userAvatar {
    final avatar = user?['avatar'] ?? '';
    if (avatar.isEmpty) return '';
    if (avatar.startsWith('http')) return avatar;
    return '${AppConfig.imageUrl}$avatar';
  }

  DateTime? get createdAtDate => createdAt != null ? DateTime.tryParse(createdAt!) : null;
}
