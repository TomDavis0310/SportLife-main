import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

final liveMatchApiProvider = Provider<LiveMatchApi>((ref) {
  return LiveMatchApi(ref.watch(dioProvider));
});

class LiveMatchApi {
  final Dio _dio;

  LiveMatchApi(this._dio);

  /// Bắt đầu trận đấu
  Future<void> startMatch(int matchId) async {
    await _dio.post('/live-matches/$matchId/start');
  }

  /// Cập nhật trạng thái trận đấu
  Future<void> updateStatus(int matchId, String status, {int? minute}) async {
    await _dio.put(
      '/live-matches/$matchId/status',
      data: {
        'status': status,
        if (minute != null) 'minute': minute,
      },
    );
  }

  /// Cập nhật tỷ số
  Future<void> updateScore(int matchId, int homeScore, int awayScore) async {
    await _dio.put(
      '/live-matches/$matchId/score',
      data: {
        'home_score': homeScore,
        'away_score': awayScore,
      },
    );
  }

  /// Thêm sự kiện
  Future<void> addEvent(
    int matchId, {
    required String eventType,
    required int minute,
    required int teamId,
    int? playerId,
    int? assistPlayerId,
    int? playerOutId,
    String? description,
  }) async {
    await _dio.post(
      '/live-matches/$matchId/events',
      data: {
        'event_type': eventType,
        'minute': minute,
        'team_id': teamId,
        if (playerId != null) 'player_id': playerId,
        if (assistPlayerId != null) 'assist_player_id': assistPlayerId,
        if (playerOutId != null) 'player_out_id': playerOutId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }

  /// Xóa sự kiện
  Future<void> deleteEvent(int matchId, int eventId) async {
    await _dio.delete('/live-matches/$matchId/events/$eventId');
  }

  /// Kết thúc trận đấu
  Future<void> endMatch(int matchId) async {
    await _dio.post('/live-matches/$matchId/end');
  }

  /// Lấy danh sách trận đấu có thể cập nhật (cho sponsor)
  Future<List<dynamic>> getMatches() async {
    final response = await _dio.get('/live-matches');
    return response.data['data'] as List;
  }

  /// Lấy chi tiết trận đấu để cập nhật
  Future<Map<String, dynamic>> getMatchDetail(int matchId) async {
    final response = await _dio.get('/live-matches/$matchId');
    return response.data['data'] as Map<String, dynamic>;
  }
}
