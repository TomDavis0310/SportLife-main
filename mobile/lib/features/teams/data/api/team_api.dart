import 'package:dio/dio.dart';
import '../models/team.dart';

class TeamApi {
  final Dio dio;

  TeamApi(this.dio);

  Future<List<Team>> getTeams({
    int? competitionId,
    String? search,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/teams',
      queryParameters: {
        if (competitionId != null) 'competition_id': competitionId,
        if (search != null) 'search': search,
        'page': page,
      },
    );
    final List data = response.data['data'];
    return data.map((e) => Team.fromJson(e)).toList();
  }

  Future<Team> getTeamDetail(int id) async {
    final response = await dio.get('/teams/$id');
    return Team.fromJson(response.data['data']);
  }

  Future<List<dynamic>> getTeamPlayers(int teamId) async {
    final response = await dio.get('/teams/$teamId/players');
    return response.data['data'];
  }

  Future<List<dynamic>> getTeamMatches(int teamId, {int limit = 10}) async {
    final response = await dio.get(
      '/teams/$teamId/matches',
      queryParameters: {'limit': limit},
    );
    return response.data['data'];
  }

  Future<List<dynamic>> getTeamNews(int teamId, {int page = 1}) async {
    final response = await dio.get(
      '/teams/$teamId/news',
      queryParameters: {'page': page},
    );
    return response.data['data'];
  }

  // Manager methods
  Future<Team> getMyTeam() async {
    final response = await dio.get('/my-team');
    return Team.fromJson(response.data['data']);
  }

  Future<void> addPlayer({
    required String name,
    required String position,
    required int jerseyNumber,
  }) async {
    await dio.post('/my-team/players', data: {
      'name': name,
      'position': position,
      'jersey_number': jerseyNumber,
    });
  }

  Future<void> removePlayer(int playerId) async {
    await dio.delete('/my-team/players/$playerId');
  }
}

