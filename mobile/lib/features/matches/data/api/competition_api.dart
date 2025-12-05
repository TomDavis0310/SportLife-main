import 'package:dio/dio.dart';

class CompetitionApi {
  final Dio _dio;

  CompetitionApi(this._dio);

  Future<List<dynamic>> getCompetitions() async {
    final response = await _dio.get('/competitions');
    return response.data['data'] ?? [];
  }

  Future<dynamic> getCompetitionDetail(int id) async {
    final response = await _dio.get('/competitions/$id');
    return response.data['data'];
  }

  Future<List<dynamic>> getStandings(int competitionId) async {
    final response = await _dio.get('/competitions/$competitionId/standings');
    final data = response.data['data'];
    
    // Backend returns { season: {...}, standings: [...] }
    if (data is Map && data.containsKey('standings')) {
      return data['standings'] ?? [];
    }
    
    return data is List ? data : [];
  }

  Future<List<dynamic>> getMatches(
    int competitionId, {
    int? round,
    String? status,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/competitions/$competitionId/matches',
      queryParameters: {
        if (round != null) 'round': round,
        if (status != null) 'status': status,
        'page': page,
      },
    );
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getTopScorers(int competitionId) async {
    final response = await _dio.get('/competitions/$competitionId/top-scorers');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getTeams(int competitionId) async {
    final response = await _dio.get('/competitions/$competitionId/teams');
    return response.data['data'] ?? [];
  }
}

