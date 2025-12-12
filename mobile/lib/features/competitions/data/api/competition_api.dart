import 'package:dio/dio.dart';
import '../../../../features/teams/data/models/team.dart';

class CompetitionApi {
  final Dio dio;

  CompetitionApi(this.dio);

  Future<List<dynamic>> getCompetitions() async {
    final response = await dio.get('/tournaments');
    return response.data['data'];
  }

  Future<void> createCompetition({
    required String name,
    required String type,
    required String seasonName,
    required String startDate,
    required String endDate,
    String? roundType,
    int? maxTeams,
    int? minTeams,
    String? registrationStartDate,
    String? registrationEndDate,
    String? description,
    String? location,
    String? prize,
    String? rules,
    String? contact,
  }) async {
    await dio.post('/tournaments', data: {
      'name': name,
      'type': type,
      'season_name': seasonName,
      'start_date': startDate,
      'end_date': endDate,
      if (roundType != null) 'round_type': roundType,
      if (maxTeams != null) 'max_teams': maxTeams,
      if (minTeams != null) 'min_teams': minTeams,
      if (registrationStartDate != null) 'registration_start_date': registrationStartDate,
      if (registrationEndDate != null) 'registration_end_date': registrationEndDate,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (prize != null) 'prize': prize,
      if (rules != null) 'rules': rules,
      if (contact != null) 'contact': contact,
    });
  }

  Future<void> registerTeam(int seasonId) async {
    await dio.post('/tournaments/$seasonId/register');
  }

  Future<List<Team>> getRegistrations(int seasonId) async {
    final response = await dio.get('/tournaments/$seasonId/registrations');
    final data = response.data['data'];
    // API trả về object có 'teams' là List, không phải List trực tiếp
    final List teams = data['teams'] ?? [];
    return teams.map((e) => Team.fromJson(e)).toList();
  }

  Future<void> approveRegistration(int seasonId, int teamId) async {
    await dio.post('/tournaments/$seasonId/registrations/$teamId/approve');
  }
}
