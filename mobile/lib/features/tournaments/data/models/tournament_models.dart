class Tournament {
  final int id;
  final String name;
  final String? nameEn;
  final String? shortName;
  final String? logo;
  final String? country;
  final String type;
  final String? description;
  final bool isActive;
  final List<TournamentSeason> seasons;

  Tournament({
    required this.id,
    required this.name,
    this.nameEn,
    this.shortName,
    this.logo,
    this.country,
    required this.type,
    this.description,
    required this.isActive,
    required this.seasons,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      shortName: json['short_name'],
      logo: json['logo'],
      country: json['country'],
      type: json['type'] ?? 'league',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => TournamentSeason.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TournamentSeason {
  final int id;
  final int competitionId;
  final String name;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int maxTeams;
  final bool registrationLocked;
  final int teamsCount;
  final int approvedTeamsCount;
  final int pendingTeamsCount;
  final bool canRegister;
  final bool isRegistrationFull;
  final List<TournamentTeam> teams;

  TournamentSeason({
    required this.id,
    required this.competitionId,
    required this.name,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.maxTeams,
    required this.registrationLocked,
    required this.teamsCount,
    required this.approvedTeamsCount,
    required this.pendingTeamsCount,
    required this.canRegister,
    required this.isRegistrationFull,
    required this.teams,
  });

  factory TournamentSeason.fromJson(Map<String, dynamic> json) {
    return TournamentSeason(
      id: json['id'],
      competitionId: json['competition_id'] ?? 0,
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      maxTeams: json['max_teams'] ?? 20,
      registrationLocked: json['registration_locked'] ?? false,
      teamsCount: json['teams_count'] ?? 0,
      approvedTeamsCount: json['approved_teams_count'] ?? 0,
      pendingTeamsCount: json['pending_teams_count'] ?? 0,
      canRegister: json['can_register'] ?? true,
      isRegistrationFull: json['is_registration_full'] ?? false,
      teams: (json['teams'] as List<dynamic>?)
              ?.map((e) => TournamentTeam.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TournamentTeam {
  final int id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? stadium;
  final String status; // pending, approved, rejected
  final String? registeredAt;

  TournamentTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.stadium,
    required this.status,
    this.registeredAt,
  });

  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      logo: json['logo'],
      stadium: json['stadium'],
      status: json['status'] ?? 'pending',
      registeredAt: json['registered_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class TournamentRound {
  final int id;
  final String name;
  final int roundNumber;
  final String? startDate;
  final String? endDate;
  final List<TournamentMatch> matches;

  TournamentRound({
    required this.id,
    required this.name,
    required this.roundNumber,
    this.startDate,
    this.endDate,
    required this.matches,
  });

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      id: json['id'],
      name: json['name'],
      roundNumber: json['round_number'] ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => TournamentMatch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TournamentMatch {
  final int id;
  final TournamentMatchTeam homeTeam;
  final TournamentMatchTeam awayTeam;
  final String? matchDate;
  final String? matchDateFormatted;
  final String? venue;
  final String status;
  final int? homeScore;
  final int? awayScore;

  TournamentMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.matchDate,
    this.matchDateFormatted,
    this.venue,
    required this.status,
    this.homeScore,
    this.awayScore,
  });

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'],
      homeTeam: TournamentMatchTeam.fromJson(json['home_team']),
      awayTeam: TournamentMatchTeam.fromJson(json['away_team']),
      matchDate: json['match_date'],
      matchDateFormatted: json['match_date_formatted'],
      venue: json['venue'],
      status: json['status']?.toString() ?? 'scheduled',
      homeScore: json['home_score'],
      awayScore: json['away_score'],
    );
  }
}

class TournamentMatchTeam {
  final int id;
  final String name;
  final String? shortName;
  final String? logo;

  TournamentMatchTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
  });

  factory TournamentMatchTeam.fromJson(Map<String, dynamic> json) {
    return TournamentMatchTeam(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      logo: json['logo'],
    );
  }
}

class SchedulePreviewData {
  final List<PreviewRound> schedule;
  final int totalRounds;
  final int totalMatches;
  final String type;

  SchedulePreviewData({
    required this.schedule,
    required this.totalRounds,
    required this.totalMatches,
    required this.type,
  });

  factory SchedulePreviewData.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return SchedulePreviewData(
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => PreviewRound.fromJson(e))
              .toList() ??
          [],
      totalRounds: summary['total_rounds'] ?? 0,
      totalMatches: summary['total_matches'] ?? 0,
      type: summary['type'] ?? 'home_away',
    );
  }
}

class PreviewRound {
  final int roundNumber;
  final String name;
  final String? startDate;
  final String? endDate;
  final List<PreviewMatch> matches;

  PreviewRound({
    required this.roundNumber,
    required this.name,
    this.startDate,
    this.endDate,
    required this.matches,
  });

  factory PreviewRound.fromJson(Map<String, dynamic> json) {
    return PreviewRound(
      roundNumber: json['round_number'] ?? 0,
      name: json['name'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => PreviewMatch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PreviewMatch {
  final int homeTeamId;
  final int awayTeamId;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? matchDate;
  final String? venue;

  PreviewMatch({
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeTeamName,
    this.awayTeamName,
    this.matchDate,
    this.venue,
  });

  factory PreviewMatch.fromJson(Map<String, dynamic> json) {
    return PreviewMatch(
      homeTeamId: json['home_team_id'] ?? 0,
      awayTeamId: json['away_team_id'] ?? 0,
      homeTeamName: json['home_team_name'],
      awayTeamName: json['away_team_name'],
      matchDate: json['match_date']?.toString(),
      venue: json['venue'],
    );
  }
}
