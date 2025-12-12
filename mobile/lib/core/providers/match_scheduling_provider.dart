import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../../features/scheduling/data/api/match_scheduling_api.dart';
import '../../features/scheduling/data/models/scheduling_models.dart';

// API Provider
final matchSchedulingApiProvider = Provider<MatchSchedulingApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MatchSchedulingApi(dio);
});

// Seasons Provider
final schedulingSeasonsProvider = FutureProvider<List<SchedulingSeason>>((ref) async {
  final api = ref.watch(matchSchedulingApiProvider);
  return api.getSeasons();
});

// Selected Season Provider
final selectedSchedulingSeasonProvider = StateProvider<int?>((ref) => null);

// Season Details Provider
final seasonDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, seasonId) async {
  final api = ref.watch(matchSchedulingApiProvider);
  return api.getSeasonDetails(seasonId);
});

// Rounds Provider
final schedulingRoundsProvider = FutureProvider.family<List<SchedulingRound>, int>((ref, seasonId) async {
  final api = ref.watch(matchSchedulingApiProvider);
  return api.getRounds(seasonId);
});

// Selected Round Provider
final selectedSchedulingRoundProvider = StateProvider<int?>((ref) => null);

// Round Matches Provider
final roundMatchesProvider = FutureProvider.family<List<SchedulingMatch>, int>((ref, roundId) async {
  final api = ref.watch(matchSchedulingApiProvider);
  return api.getRoundMatches(roundId);
});

// Conflicts Provider
final schedulingConflictsProvider = FutureProvider.family<List<SchedulingConflict>, int>((ref, seasonId) async {
  final api = ref.watch(matchSchedulingApiProvider);
  return api.checkConflicts(seasonId);
});

// Schedule Preview State
class SchedulePreviewState {
  final bool isLoading;
  final SchedulePreview? preview;
  final String? error;

  SchedulePreviewState({
    this.isLoading = false,
    this.preview,
    this.error,
  });

  SchedulePreviewState copyWith({
    bool? isLoading,
    SchedulePreview? preview,
    String? error,
  }) {
    return SchedulePreviewState(
      isLoading: isLoading ?? this.isLoading,
      preview: preview ?? this.preview,
      error: error,
    );
  }
}

class SchedulePreviewNotifier extends StateNotifier<SchedulePreviewState> {
  final MatchSchedulingApi _api;

  SchedulePreviewNotifier(this._api) : super(SchedulePreviewState());

  Future<void> previewSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final preview = await _api.previewSchedule(
        seasonId: seasonId,
        type: type,
        startDate: startDate,
        timeSlots: timeSlots,
        matchDays: matchDays,
        matchesPerDay: matchesPerDay,
      );
      state = state.copyWith(isLoading: false, preview: preview);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearPreview() {
    state = SchedulePreviewState();
  }
}

final schedulePreviewProvider = StateNotifierProvider<SchedulePreviewNotifier, SchedulePreviewState>((ref) {
  final api = ref.watch(matchSchedulingApiProvider);
  return SchedulePreviewNotifier(api);
});

// Schedule Generation State
class ScheduleGenerationState {
  final bool isGenerating;
  final bool success;
  final String? message;
  final String? error;

  ScheduleGenerationState({
    this.isGenerating = false,
    this.success = false,
    this.message,
    this.error,
  });
}

class ScheduleGenerationNotifier extends StateNotifier<ScheduleGenerationState> {
  final MatchSchedulingApi _api;
  final Ref _ref;

  ScheduleGenerationNotifier(this._api, this._ref) : super(ScheduleGenerationState());

  Future<bool> generateSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
    bool clearExisting = false,
  }) async {
    state = ScheduleGenerationState(isGenerating: true);
    try {
      final result = await _api.generateSchedule(
        seasonId: seasonId,
        type: type,
        startDate: startDate,
        timeSlots: timeSlots,
        matchDays: matchDays,
        matchesPerDay: matchesPerDay,
        clearExisting: clearExisting,
      );
      
      final summary = result['summary'] as Map<String, dynamic>?;
      final message = 'Đã tạo ${summary?['total_rounds'] ?? 0} vòng đấu với ${summary?['total_matches'] ?? 0} trận';
      
      state = ScheduleGenerationState(success: true, message: message);
      
      // Refresh rounds
      _ref.invalidate(schedulingRoundsProvider(seasonId));
      
      return true;
    } catch (e) {
      state = ScheduleGenerationState(error: e.toString());
      return false;
    }
  }

  void reset() {
    state = ScheduleGenerationState();
  }
}

final scheduleGenerationProvider = StateNotifierProvider<ScheduleGenerationNotifier, ScheduleGenerationState>((ref) {
  final api = ref.watch(matchSchedulingApiProvider);
  return ScheduleGenerationNotifier(api, ref);
});
