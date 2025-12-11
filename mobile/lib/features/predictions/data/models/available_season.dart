import '../../../../core/config/app_config.dart';

class AvailableSeason {
  final int id;
  final String name;
  final Map<String, dynamic>? competition;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int teamsCount;
  final bool canPredict;

  AvailableSeason({
    required this.id,
    required this.name,
    this.competition,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.teamsCount,
    required this.canPredict,
  });

  factory AvailableSeason.fromJson(Map<String, dynamic> json) {
    return AvailableSeason(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      competition: json['competition'] is Map ? Map<String, dynamic>.from(json['competition']) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      teamsCount: json['teams_count'] ?? 0,
      canPredict: json['can_predict'] ?? true,
    );
  }

  String get competitionName => competition?['name'] ?? 'Unknown';
  String get competitionShortName => competition?['short_name'] ?? competitionName;
  
  String get competitionLogoUrl {
    final logo = competition?['logo_url'] ?? '';
    if (logo.isEmpty) return '';
    if (logo.startsWith('http')) return logo;
    return '${AppConfig.imageUrl}$logo';
  }

  DateTime? get startDateTime => startDate != null ? DateTime.tryParse(startDate!) : null;
  DateTime? get endDateTime => endDate != null ? DateTime.tryParse(endDate!) : null;
}

class SeasonTeamForPrediction {
  final int id;
  final String name;
  final String shortName;
  final String? logoUrl;
  final Map<String, dynamic>? standing;
  final Map<String, dynamic>? predictionStats;

  SeasonTeamForPrediction({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
    this.standing,
    this.predictionStats,
  });

  factory SeasonTeamForPrediction.fromJson(Map<String, dynamic> json) {
    return SeasonTeamForPrediction(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? json['name'] ?? '',
      logoUrl: json['logo_url'],
      standing: json['standing'] is Map ? Map<String, dynamic>.from(json['standing']) : null,
      predictionStats: json['prediction_stats'] is Map ? Map<String, dynamic>.from(json['prediction_stats']) : null,
    );
  }

  String get logo {
    if (logoUrl == null || logoUrl!.isEmpty) return '';
    if (logoUrl!.startsWith('http')) return logoUrl!;
    return '${AppConfig.imageUrl}$logoUrl';
  }

  // Standing getters
  int get position => standing?['position'] ?? 0;
  int get points => standing?['points'] ?? 0;
  int get played => standing?['played'] ?? 0;
  int get won => standing?['won'] ?? 0;
  int get drawn => standing?['drawn'] ?? 0;
  int get lost => standing?['lost'] ?? 0;
  int get goalsFor => standing?['goals_for'] ?? 0;
  int get goalsAgainst => standing?['goals_against'] ?? 0;
  int get goalDifference => standing?['goal_difference'] ?? 0;

  // Prediction stats getters
  int get predictionCount => predictionStats?['count'] ?? 0;
  double get predictionPercentage => (predictionStats?['percentage'] ?? 0).toDouble();
}
