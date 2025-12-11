import 'package:dio/dio.dart';

class TournamentApi {
  final Dio _dio;

  TournamentApi(this._dio);

  // Get list of tournaments (competitions with seasons)
  Future<List<dynamic>> getTournaments() async {
    try {
      final response = await _dio.get('/tournaments');
      if (response.data['success'] == true) {
        return response.data['data'] as List;
      }
      throw Exception(response.data['message'] ?? 'Không thể tải danh sách giải đấu');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách giải đấu: $e');
    }
  }

  // Create new tournament (Sponsor only)
  Future<Map<String, dynamic>> createTournament({
    required String name,
    required String type,
    required String seasonName,
    required String startDate,
    required String endDate,
    required int maxTeams,
    String? roundType,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/tournaments', data: {
        'name': name,
        'type': type,
        'season_name': seasonName,
        'start_date': startDate,
        'end_date': endDate,
        'max_teams': maxTeams,
        if (roundType != null) 'round_type': roundType,
        if (description != null) 'description': description,
      });
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể tạo giải đấu');
    } catch (e) {
      throw Exception('Lỗi khi tạo giải đấu: $e');
    }
  }

  // Get season details
  Future<Map<String, dynamic>> getSeasonDetails(int seasonId) async {
    try {
      final response = await _dio.get('/tournaments/$seasonId');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể tải thông tin giải đấu');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin giải đấu: $e');
    }
  }

  // Register team for tournament (Manager only)
  Future<void> registerTeam(int seasonId) async {
    try {
      final response = await _dio.post('/tournaments/$seasonId/register');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Không thể đăng ký tham gia');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi đăng ký');
      }
      throw Exception('Lỗi khi đăng ký: $e');
    }
  }

  // Get registrations for a season (Sponsor only)
  Future<Map<String, dynamic>> getRegistrations(int seasonId) async {
    try {
      final response = await _dio.get('/tournaments/$seasonId/registrations');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể tải danh sách đăng ký');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách đăng ký: $e');
    }
  }

  // Approve team registration (Sponsor only)
  Future<void> approveRegistration(int seasonId, int teamId) async {
    try {
      final response = await _dio.post('/tournaments/$seasonId/registrations/$teamId/approve');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Không thể phê duyệt');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi phê duyệt');
      }
      throw Exception('Lỗi khi phê duyệt: $e');
    }
  }

  // Reject team registration (Sponsor only)
  Future<void> rejectRegistration(int seasonId, int teamId) async {
    try {
      final response = await _dio.post('/tournaments/$seasonId/registrations/$teamId/reject');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Không thể từ chối');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi từ chối');
      }
      throw Exception('Lỗi khi từ chối: $e');
    }
  }

  // Lock registration (Sponsor only)
  Future<Map<String, dynamic>> lockRegistration(int seasonId) async {
    try {
      final response = await _dio.post('/tournaments/$seasonId/lock-registration');
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      throw Exception(response.data['message'] ?? 'Không thể khóa đăng ký');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi khóa đăng ký');
      }
      throw Exception('Lỗi khi khóa đăng ký: $e');
    }
  }

  // Unlock registration (Sponsor only)
  Future<void> unlockRegistration(int seasonId) async {
    try {
      final response = await _dio.post('/tournaments/$seasonId/unlock-registration');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Không thể mở lại đăng ký');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi mở lại đăng ký');
      }
      throw Exception('Lỗi khi mở lại đăng ký: $e');
    }
  }

  // Get tournament schedule
  Future<Map<String, dynamic>> getSchedule(int seasonId) async {
    try {
      final response = await _dio.get('/tournaments/$seasonId/schedule');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể tải lịch thi đấu');
    } catch (e) {
      throw Exception('Lỗi khi tải lịch thi đấu: $e');
    }
  }

  // Preview schedule before generating (Sponsor only)
  Future<Map<String, dynamic>> previewSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
  }) async {
    try {
      final response = await _dio.post(
        '/tournaments/$seasonId/schedule/preview',
        data: {
          'type': type,
          if (startDate != null) 'start_date': startDate,
          if (timeSlots != null) 'time_slots': timeSlots,
          if (matchDays != null) 'match_days': matchDays,
          if (matchesPerDay != null) 'matches_per_day': matchesPerDay,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể xem trước lịch thi đấu');
    } catch (e) {
      throw Exception('Lỗi khi xem trước lịch thi đấu: $e');
    }
  }

  // Generate schedule (Sponsor only)
  Future<Map<String, dynamic>> generateSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
    bool clearExisting = false,
  }) async {
    try {
      final response = await _dio.post(
        '/tournaments/$seasonId/schedule/generate',
        data: {
          'type': type,
          if (startDate != null) 'start_date': startDate,
          if (timeSlots != null) 'time_slots': timeSlots,
          if (matchDays != null) 'match_days': matchDays,
          if (matchesPerDay != null) 'matches_per_day': matchesPerDay,
          'clear_existing': clearExisting,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      throw Exception(response.data['message'] ?? 'Không thể tạo lịch thi đấu');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi tạo lịch thi đấu');
      }
      throw Exception('Lỗi khi tạo lịch thi đấu: $e');
    }
  }

  // Clear schedule (Sponsor only)
  Future<void> clearSchedule(int seasonId) async {
    try {
      final response = await _dio.delete('/tournaments/$seasonId/schedule');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Không thể xóa lịch thi đấu');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi xóa lịch thi đấu');
      }
      throw Exception('Lỗi khi xóa lịch thi đấu: $e');
    }
  }

  // Update match (Sponsor only)
  Future<Map<String, dynamic>> updateMatch({
    required int seasonId,
    required int matchId,
    String? matchDate,
    String? venue,
    int? homeTeamId,
    int? awayTeamId,
  }) async {
    try {
      final response = await _dio.put(
        '/tournaments/$seasonId/matches/$matchId',
        data: {
          if (matchDate != null) 'match_date': matchDate,
          if (venue != null) 'venue': venue,
          if (homeTeamId != null) 'home_team_id': homeTeamId,
          if (awayTeamId != null) 'away_team_id': awayTeamId,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Không thể cập nhật trận đấu');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trận đấu: $e');
    }
  }
}
