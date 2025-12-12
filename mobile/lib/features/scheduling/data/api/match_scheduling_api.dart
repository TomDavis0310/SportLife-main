import 'package:dio/dio.dart';
import '../models/scheduling_models.dart';

class MatchSchedulingApi {
  final Dio _dio;

  MatchSchedulingApi(this._dio);

  // Get available seasons for scheduling
  Future<List<SchedulingSeason>> getSeasons() async {
    try {
      final response = await _dio.get('/scheduling/seasons');
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((e) => SchedulingSeason.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load seasons');
    } catch (e) {
      throw Exception('Error loading seasons: $e');
    }
  }

  // Get season details with teams
  Future<Map<String, dynamic>> getSeasonDetails(int seasonId) async {
    try {
      final response = await _dio.get('/scheduling/seasons/$seasonId');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to load season details');
    } catch (e) {
      throw Exception('Error loading season details: $e');
    }
  }

  // Get rounds for a season
  Future<List<SchedulingRound>> getRounds(int seasonId) async {
    try {
      final response = await _dio.get('/scheduling/seasons/$seasonId/rounds');
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((e) => SchedulingRound.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load rounds');
    } catch (e) {
      throw Exception('Error loading rounds: $e');
    }
  }

  // Get matches for a round
  Future<List<SchedulingMatch>> getRoundMatches(int roundId) async {
    try {
      final response = await _dio.get('/scheduling/rounds/$roundId/matches');
      if (response.data['success'] == true) {
        final data = response.data['data']['matches'] as List;
        return data.map((e) => SchedulingMatch.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load matches');
    } catch (e) {
      throw Exception('Error loading matches: $e');
    }
  }

  // Preview auto-generated schedule
  Future<SchedulePreview> previewSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
    int? numGroups,
    bool? homeAndAway,
  }) async {
    try {
      final response = await _dio.post(
        '/scheduling/seasons/$seasonId/preview',
        data: {
          'type': type,
          if (startDate != null) 'start_date': startDate,
          if (timeSlots != null) 'time_slots': timeSlots,
          if (matchDays != null) 'match_days': matchDays,
          if (matchesPerDay != null) 'matches_per_day': matchesPerDay,
          if (numGroups != null) 'num_groups': numGroups,
          if (homeAndAway != null) 'home_and_away': homeAndAway,
        },
      );
      if (response.data['success'] == true) {
        return SchedulePreview.fromJson(response.data);
      }
      throw Exception(response.data['message'] ?? 'Failed to preview schedule');
    } catch (e) {
      throw Exception('Error previewing schedule: $e');
    }
  }

  // Generate and save auto schedule
  Future<Map<String, dynamic>> generateSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
    int? numGroups,
    bool? homeAndAway,
    bool clearExisting = false,
  }) async {
    try {
      final response = await _dio.post(
        '/scheduling/seasons/$seasonId/generate',
        data: {
          'type': type,
          if (startDate != null) 'start_date': startDate,
          if (timeSlots != null) 'time_slots': timeSlots,
          if (matchDays != null) 'match_days': matchDays,
          if (matchesPerDay != null) 'matches_per_day': matchesPerDay,
          if (numGroups != null) 'num_groups': numGroups,
          if (homeAndAway != null) 'home_and_away': homeAndAway,
          'clear_existing': clearExisting,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to generate schedule');
    } catch (e) {
      throw Exception('Error generating schedule: $e');
    }
  }

  // Create manual match
  Future<Map<String, dynamic>> createMatch({
    required int roundId,
    required int homeTeamId,
    required int awayTeamId,
    required String matchDate,
    String? venue,
  }) async {
    try {
      final response = await _dio.post(
        '/scheduling/matches',
        data: {
          'round_id': roundId,
          'home_team_id': homeTeamId,
          'away_team_id': awayTeamId,
          'match_date': matchDate,
          if (venue != null) 'venue': venue,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to create match');
    } catch (e) {
      throw Exception('Error creating match: $e');
    }
  }

  // Update match
  Future<Map<String, dynamic>> updateMatch(
    int matchId, {
    int? roundId,
    String? matchDate,
    String? venue,
  }) async {
    try {
      final response = await _dio.put(
        '/scheduling/matches/$matchId',
        data: {
          if (roundId != null) 'round_id': roundId,
          if (matchDate != null) 'match_date': matchDate,
          if (venue != null) 'venue': venue,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to update match');
    } catch (e) {
      throw Exception('Error updating match: $e');
    }
  }

  // Reschedule match
  Future<Map<String, dynamic>> rescheduleMatch(
    int matchId,
    String newDate, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/scheduling/matches/$matchId/reschedule',
        data: {
          'new_date': newDate,
          if (reason != null) 'reason': reason,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to reschedule match');
    } catch (e) {
      throw Exception('Error rescheduling match: $e');
    }
  }

  // Swap home/away teams
  Future<Map<String, dynamic>> swapTeams(int matchId) async {
    try {
      final response = await _dio.post('/scheduling/matches/$matchId/swap');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to swap teams');
    } catch (e) {
      throw Exception('Error swapping teams: $e');
    }
  }

  // Delete match
  Future<void> deleteMatch(int matchId) async {
    try {
      final response = await _dio.delete('/scheduling/matches/$matchId');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete match');
      }
    } catch (e) {
      throw Exception('Error deleting match: $e');
    }
  }

  // Create round
  Future<Map<String, dynamic>> createRound(
    int seasonId, {
    required String name,
    int? roundNumber,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/scheduling/seasons/$seasonId/rounds',
        data: {
          'name': name,
          if (roundNumber != null) 'round_number': roundNumber,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Failed to create round');
    } catch (e) {
      throw Exception('Error creating round: $e');
    }
  }

  // Check scheduling conflicts
  Future<List<SchedulingConflict>> checkConflicts(int seasonId) async {
    try {
      final response = await _dio.get('/scheduling/seasons/$seasonId/conflicts');
      if (response.data['success'] == true) {
        final conflicts = response.data['data']['conflicts'] as List;
        return conflicts.map((e) => SchedulingConflict.fromJson(e)).toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to check conflicts');
    } catch (e) {
      throw Exception('Error checking conflicts: $e');
    }
  }

  // Clear season schedule
  Future<int> clearSchedule(int seasonId) async {
    try {
      final response = await _dio.delete('/scheduling/seasons/$seasonId/clear');
      if (response.data['success'] == true) {
        return response.data['data']['deleted_matches'] ?? 0;
      }
      throw Exception(response.data['message'] ?? 'Failed to clear schedule');
    } catch (e) {
      throw Exception('Error clearing schedule: $e');
    }
  }
}
