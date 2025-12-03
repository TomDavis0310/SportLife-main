import 'package:dio/dio.dart';
import '../models/match.dart';
import '../models/competition.dart';

class MatchApi {
  final Dio dio;

  MatchApi(this.dio);

  Future<List<Competition>> getCompetitions() async {
    final response = await dio.get('/competitions');
    final List data = response.data['data'];
    return data.map((e) => Competition.fromJson(e)).toList();
  }

  Future<List<Match>> getMatches({
    String? date,
    int? competitionId,
    String? status,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/matches',
      queryParameters: {
        if (date != null) 'date': date,
        if (competitionId != null) 'competition_id': competitionId,
        if (status != null) 'status': status,
        'page': page,
      },
    );
    final List data = response.data['data'];
    return data.map((e) => Match.fromJson(e)).toList();
  }

  Future<List<Match>> getLiveMatches() async {
    final response = await dio.get('/matches/live');
    final List data = response.data['data'];
    return data.map((e) => Match.fromJson(e)).toList();
  }

  Future<List<Match>> getUpcomingMatches({int limit = 10}) async {
    final response = await dio.get(
      '/matches/upcoming',
      queryParameters: {'limit': limit},
    );
    final List data = response.data['data'];
    return data.map((e) => Match.fromJson(e)).toList();
  }

  Future<Match> getMatch(int id) async {
    final response = await dio.get('/matches/$id');
    return Match.fromJson(response.data['data']);
  }

  Future<List<dynamic>> getMatchEvents(int matchId) async {
    final response = await dio.get('/matches/$matchId/events');
    return response.data['data'];
  }

  Future<List<dynamic>> getMatchPredictions(int matchId) async {
    final response = await dio.get('/matches/$matchId/predictions');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getHeadToHead(int matchId) async {
    final response = await dio.get('/matches/$matchId/h2h');
    return response.data['data'];
  }
}

