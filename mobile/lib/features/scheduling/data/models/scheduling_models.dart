// Match Scheduling Models

class SchedulingSeason {
  final int id;
  final String name;
  final int? competitionId;
  final String? competitionName;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int teamsCount;
  final int roundsCount;
  final bool hasSchedule;

  SchedulingSeason({
    required this.id,
    required this.name,
    this.competitionId,
    this.competitionName,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.teamsCount = 0,
    this.roundsCount = 0,
    this.hasSchedule = false,
  });

  factory SchedulingSeason.fromJson(Map<String, dynamic> json) {
    return SchedulingSeason(
      id: json['id'],
      name: json['name'] ?? '',
      competitionId: json['competition_id'],
      competitionName: json['competition_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      teamsCount: json['teams_count'] ?? 0,
      roundsCount: json['rounds_count'] ?? 0,
      hasSchedule: json['has_schedule'] ?? false,
    );
  }
}

class SchedulingRound {
  final int id;
  final String name;
  final int roundNumber;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final int matchesCount;

  SchedulingRound({
    required this.id,
    required this.name,
    required this.roundNumber,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.matchesCount = 0,
  });

  factory SchedulingRound.fromJson(Map<String, dynamic> json) {
    return SchedulingRound(
      id: json['id'],
      name: json['name'] ?? '',
      roundNumber: json['round_number'] ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      isCurrent: json['is_current'] ?? false,
      matchesCount: json['matches_count'] ?? 0,
    );
  }
}

class SchedulingTeam {
  final int id;
  final String name;
  final String? shortName;
  final String? logo;
  final String? stadium;

  SchedulingTeam({
    required this.id,
    required this.name,
    this.shortName,
    this.logo,
    this.stadium,
  });

  factory SchedulingTeam.fromJson(Map<String, dynamic> json) {
    return SchedulingTeam(
      id: json['id'],
      name: json['name'] ?? '',
      shortName: json['short_name'],
      logo: json['logo'],
      stadium: json['stadium'],
    );
  }
}

class SchedulingMatch {
  final int id;
  final SchedulingTeam homeTeam;
  final SchedulingTeam awayTeam;
  final String? matchDate;
  final String? matchDateFormatted;
  final String? venue;
  final String status;
  final int? homeScore;
  final int? awayScore;

  SchedulingMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.matchDate,
    this.matchDateFormatted,
    this.venue,
    this.status = 'scheduled',
    this.homeScore,
    this.awayScore,
  });

  factory SchedulingMatch.fromJson(Map<String, dynamic> json) {
    return SchedulingMatch(
      id: json['id'],
      homeTeam: SchedulingTeam.fromJson(json['home_team']),
      awayTeam: SchedulingTeam.fromJson(json['away_team']),
      matchDate: json['match_date'],
      matchDateFormatted: json['match_date_formatted'],
      venue: json['venue'],
      status: json['status']?.toString() ?? 'scheduled',
      homeScore: json['home_score'],
      awayScore: json['away_score'],
    );
  }

  bool get isScheduled => status == 'scheduled';
  bool get isFinished => status == 'finished';
  bool get isLive => ['live', '1H', '2H', 'HT'].contains(status);
}

class SchedulePreview {
  final List<PreviewRound> schedule;
  final int totalRounds;
  final int totalMatches;
  final String type;

  SchedulePreview({
    required this.schedule,
    required this.totalRounds,
    required this.totalMatches,
    required this.type,
  });

  factory SchedulePreview.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final scheduleList = data['schedule'] as List? ?? [];
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    
    return SchedulePreview(
      schedule: scheduleList.map((r) => PreviewRound.fromJson(r)).toList(),
      totalRounds: summary['total_rounds'] ?? 0,
      totalMatches: summary['total_matches'] ?? 0,
      type: summary['type'] ?? '',
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
    final matchesList = json['matches'] as List? ?? [];
    return PreviewRound(
      roundNumber: json['round_number'] ?? 0,
      name: json['name'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      matches: matchesList.map((m) => PreviewMatch.fromJson(m)).toList(),
    );
  }
}

class PreviewMatch {
  final int homeTeamId;
  final int awayTeamId;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? matchDate;
  final String? matchDateFormatted;
  final String? venue;

  PreviewMatch({
    required this.homeTeamId,
    required this.awayTeamId,
    this.homeTeamName,
    this.awayTeamName,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.matchDate,
    this.matchDateFormatted,
    this.venue,
  });

  factory PreviewMatch.fromJson(Map<String, dynamic> json) {
    return PreviewMatch(
      homeTeamId: json['home_team_id'],
      awayTeamId: json['away_team_id'],
      homeTeamName: json['home_team_name'],
      awayTeamName: json['away_team_name'],
      homeTeamLogo: json['home_team_logo'],
      awayTeamLogo: json['away_team_logo'],
      matchDate: json['match_date']?.toString(),
      matchDateFormatted: json['match_date_formatted'],
      venue: json['venue'],
    );
  }
}

class SchedulingConflict {
  final String type;
  final String? date;
  final int? teamId;
  final String? teamName;
  final int? count;
  final List<int>? matches;

  SchedulingConflict({
    required this.type,
    this.date,
    this.teamId,
    this.teamName,
    this.count,
    this.matches,
  });

  factory SchedulingConflict.fromJson(Map<String, dynamic> json) {
    return SchedulingConflict(
      type: json['type'] ?? '',
      date: json['date'],
      teamId: json['team_id'],
      teamName: json['team_name'],
      count: json['count'],
      matches: (json['matches'] as List?)?.map((e) => e as int).toList(),
    );
  }

  String get description {
    switch (type) {
      case 'double_booking':
        return '$teamName đá 2 trận trong ngày $date';
      case 'consecutive_home':
        return '$teamName đá $count trận liên tiếp sân nhà';
      case 'consecutive_away':
        return '$teamName đá $count trận liên tiếp sân khách';
      default:
        return 'Xung đột: $type';
    }
  }
}
