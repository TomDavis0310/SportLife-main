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
  }) async {
    await dio.post('/tournaments', data: {
      'name': name,
      'type': type,
      'season_name': seasonName,
      'start_date': startDate,
      'end_date': endDate,
    });
  }

  Future<void> registerTeam(int seasonId) async {
    await dio.post('/tournaments/$seasonId/register');
  }

  Future<List<Team>> getRegistrations(int seasonId) async {
    final response = await dio.get('/tournaments/$seasonId/registrations');
    final List data = response.data['data'];
    return data.map((e) => Team.fromJson(e)).toList();
  }

  Future<void> approveRegistration(int seasonId, int teamId) async {
    await dio.post('/tournaments/$seasonId/registrations/$teamId/approve');
  }
}
