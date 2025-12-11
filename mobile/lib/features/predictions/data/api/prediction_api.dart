import 'package:dio/dio.dart';
import '../models/prediction.dart';
import '../models/leaderboard_entry.dart';

class PredictionApi {
  final Dio dio;

  PredictionApi(this.dio);

  Future<List<Prediction>> getMyPredictions({int page = 1}) async {
    final response = await dio.get(
      '/predictions',
      queryParameters: {'page': page},
    );
    final List data = response.data['data'];
    return data.map((e) => Prediction.fromJson(e)).toList();
  }

  Future<Prediction> createPrediction({
    required int matchId,
    required String predictedOutcome, // 'home', 'draw', 'away'
  }) async {
    final response = await dio.post(
      '/predictions',
      data: {
        'match_id': matchId,
        'predicted_outcome': predictedOutcome,
      },
    );
    return Prediction.fromJson(response.data['data']);
  }

  Future<Prediction> updatePrediction({
    required int predictionId,
    required String predictedOutcome, // 'home', 'draw', 'away'
  }) async {
    final response = await dio.put(
      '/predictions/$predictionId',
      data: {
        'predicted_outcome': predictedOutcome,
      },
    );
    return Prediction.fromJson(response.data['data']);
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'all_time',
    int? competitionId,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/leaderboard',
      queryParameters: {
        'period': period,
        if (competitionId != null) 'competition_id': competitionId,
        'page': page,
      },
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final data = response.data['data'];
    if (data is! List) {
      return [];
    }

    return data.map((e) {
      try {
        if (e is Map) {
          return LeaderboardEntry.fromJson(Map<String, dynamic>.from(e));
        }
        return null;
      } catch (e) {
        print('Error parsing leaderboard entry: $e');
        return null;
      }
    }).whereType<LeaderboardEntry>().toList();
  }

  Future<Map<String, dynamic>> getMyStats() async {
    final response = await dio.get('/predictions/stats');
    return response.data['data'];
  }
}

