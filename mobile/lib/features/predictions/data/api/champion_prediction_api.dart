import 'package:dio/dio.dart';
import '../models/champion_prediction.dart';
import '../models/champion_prediction_leaderboard.dart';
import '../models/season_champion.dart';
import '../models/available_season.dart';

class ChampionPredictionApi {
  final Dio dio;

  ChampionPredictionApi(this.dio);

  /// Get available seasons for champion prediction
  Future<List<AvailableSeason>> getAvailableSeasons() async {
    final response = await dio.get('/champion-predictions/seasons');
    final List data = response.data['data'] ?? [];
    return data.map((e) => AvailableSeason.fromJson(e)).toList();
  }

  /// Get teams in a season with standings and prediction stats
  Future<Map<String, dynamic>> getSeasonTeams(int seasonId) async {
    final response = await dio.get('/champion-predictions/seasons/$seasonId/teams');
    final data = response.data['data'];
    return {
      'season': data['season'],
      'teams': (data['teams'] as List)
          .map((e) => SeasonTeamForPrediction.fromJson(e))
          .toList(),
      'total_predictions': data['total_predictions'] ?? 0,
    };
  }

  /// Get user's champion predictions
  Future<List<ChampionPrediction>> getMyPredictions() async {
    final response = await dio.get('/champion-predictions/my-predictions');
    final List data = response.data['data'] ?? [];
    return data.map((e) => ChampionPrediction.fromJson(e)).toList();
  }

  /// Get user's prediction for a specific season
  Future<ChampionPrediction?> getMySeasonPrediction(int seasonId) async {
    final response = await dio.get('/champion-predictions/seasons/$seasonId/my-prediction');
    final data = response.data['data'];
    if (data == null) return null;
    return ChampionPrediction.fromJson(data);
  }

  /// Create a champion prediction
  Future<ChampionPrediction> createPrediction({
    required int seasonId,
    required int predictedTeamId,
    String? reason,
    required int confidenceLevel,
    required int pointsWagered,
  }) async {
    final response = await dio.post('/champion-predictions', data: {
      'season_id': seasonId,
      'predicted_team_id': predictedTeamId,
      'reason': reason,
      'confidence_level': confidenceLevel,
      'points_wagered': pointsWagered,
    });
    return ChampionPrediction.fromJson(response.data['data']);
  }

  /// Update a champion prediction
  Future<ChampionPrediction> updatePrediction({
    required int predictionId,
    required int predictedTeamId,
    String? reason,
    required int confidenceLevel,
  }) async {
    final response = await dio.put('/champion-predictions/$predictionId', data: {
      'predicted_team_id': predictedTeamId,
      'reason': reason,
      'confidence_level': confidenceLevel,
    });
    return ChampionPrediction.fromJson(response.data['data']);
  }

  /// Get prediction details
  Future<ChampionPrediction> getPrediction(int predictionId) async {
    final response = await dio.get('/champion-predictions/$predictionId');
    return ChampionPrediction.fromJson(response.data['data']);
  }

  /// Get season prediction statistics
  Future<Map<String, dynamic>> getSeasonStats(int seasonId) async {
    final response = await dio.get('/champion-predictions/seasons/$seasonId/stats');
    return response.data['data'];
  }

  /// Get champion prediction leaderboard
  Future<List<ChampionPredictionLeaderboardEntry>> getLeaderboard({
    String period = 'all_time',
    int? seasonId,
  }) async {
    final response = await dio.get('/champion-predictions/leaderboard', queryParameters: {
      'period': period,
      if (seasonId != null) 'season_id': seasonId,
    });
    final List data = response.data['data'] ?? [];
    return data.map((e) => ChampionPredictionLeaderboardEntry.fromJson(e)).toList();
  }

  /// Get user's rank in champion prediction
  Future<ChampionPredictionLeaderboardEntry?> getMyRank({int? seasonId}) async {
    final response = await dio.get('/champion-predictions/my-rank', queryParameters: {
      if (seasonId != null) 'season_id': seasonId,
    });
    final data = response.data['data'];
    if (data == null || data['rank'] == null) return null;
    return ChampionPredictionLeaderboardEntry.fromJson(data);
  }

  /// Get season champion
  Future<SeasonChampion?> getSeasonChampion(int seasonId) async {
    final response = await dio.get('/champion-predictions/seasons/$seasonId/champion');
    final data = response.data['data'];
    if (data == null) return null;
    return SeasonChampion.fromJson(data);
  }

  /// Get all season champions
  Future<List<SeasonChampion>> getAllChampions() async {
    final response = await dio.get('/champion-predictions/champions');
    final List data = response.data['data'] ?? [];
    return data.map((e) => SeasonChampion.fromJson(e)).toList();
  }
}
