import '../../../../core/config/app_config.dart';

class SeasonChampion {
  final int id;
  final int seasonId;
  final int championTeamId;
  final String? confirmedAt;
  final String? createdAt;
  final Map<String, dynamic>? season;
  final Map<String, dynamic>? championTeam;

  SeasonChampion({
    required this.id,
    required this.seasonId,
    required this.championTeamId,
    this.confirmedAt,
    this.createdAt,
    this.season,
    this.championTeam,
  });

  factory SeasonChampion.fromJson(Map<String, dynamic> json) {
    return SeasonChampion(
      id: json['id'] ?? 0,
      seasonId: json['season_id'] ?? 0,
      championTeamId: json['champion_team_id'] ?? 0,
      confirmedAt: json['confirmed_at'],
      createdAt: json['created_at'],
      season: json['season'] is Map ? Map<String, dynamic>.from(json['season']) : null,
      championTeam: json['champion_team'] is Map ? Map<String, dynamic>.from(json['champion_team']) : null,
    );
  }

  String get teamName => championTeam?['name'] ?? championTeam?['short_name'] ?? 'Unknown';
  String get teamShortName => championTeam?['short_name'] ?? teamName;
  
  String get teamLogoUrl {
    final logo = championTeam?['logo_url'] ?? '';
    if (logo.isEmpty) return '';
    if (logo.startsWith('http')) return logo;
    return '${AppConfig.imageUrl}$logo';
  }

  String get seasonName => season?['name'] ?? 'Unknown Season';
  String get competitionName => season?['competition']?['name'] ?? 'Unknown Competition';

  DateTime? get confirmedAtDate => confirmedAt != null ? DateTime.tryParse(confirmedAt!) : null;
}
