import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/tournaments/data/api/tournament_api.dart';
import '../../features/tournaments/data/models/tournament_models.dart';
import '../network/dio_client.dart';

// Tournament API provider
final tournamentApiProvider = Provider<TournamentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return TournamentApi(dio);
});

// Tournaments list provider
final tournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  final api = ref.watch(tournamentApiProvider);
  final data = await api.getTournaments();
  return data.map((e) => Tournament.fromJson(e)).toList();
});

// Selected season ID provider
final selectedTournamentSeasonProvider = StateProvider<int?>((ref) => null);

// Season details provider
final tournamentSeasonDetailsProvider = FutureProvider.family<TournamentSeason, int>((ref, seasonId) async {
  final api = ref.watch(tournamentApiProvider);
  final data = await api.getSeasonDetails(seasonId);
  return TournamentSeason.fromJson(data);
});

// Season registrations provider (for sponsors)
final tournamentRegistrationsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, seasonId) async {
  final api = ref.watch(tournamentApiProvider);
  return await api.getRegistrations(seasonId);
});

// Tournament schedule provider
final tournamentScheduleProvider = FutureProvider.family<List<TournamentRound>, int>((ref, seasonId) async {
  final api = ref.watch(tournamentApiProvider);
  final data = await api.getSchedule(seasonId);
  final rounds = data['rounds'] as List<dynamic>? ?? [];
  return rounds.map((e) => TournamentRound.fromJson(e)).toList();
});

// Schedule preview state
class SchedulePreviewState {
  final bool isLoading;
  final SchedulePreviewData? data;
  final String? error;

  SchedulePreviewState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  SchedulePreviewState copyWith({
    bool? isLoading,
    SchedulePreviewData? data,
    String? error,
  }) {
    return SchedulePreviewState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

// Schedule preview notifier
class SchedulePreviewNotifier extends StateNotifier<SchedulePreviewState> {
  final TournamentApi _api;
  
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
      final data = await _api.previewSchedule(
        seasonId: seasonId,
        type: type,
        startDate: startDate,
        timeSlots: timeSlots,
        matchDays: matchDays,
        matchesPerDay: matchesPerDay,
      );
      state = state.copyWith(
        isLoading: false,
        data: SchedulePreviewData.fromJson(data),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = SchedulePreviewState();
  }
}

final schedulePreviewNotifierProvider = StateNotifierProvider<SchedulePreviewNotifier, SchedulePreviewState>((ref) {
  final api = ref.watch(tournamentApiProvider);
  return SchedulePreviewNotifier(api);
});

// Schedule generation state
class ScheduleGenerationState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Map<String, dynamic>? summary;

  ScheduleGenerationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.summary,
  });
}

// Schedule generation notifier
class ScheduleGenerationNotifier extends StateNotifier<ScheduleGenerationState> {
  final TournamentApi _api;
  
  ScheduleGenerationNotifier(this._api) : super(ScheduleGenerationState());

  Future<bool> generateSchedule({
    required int seasonId,
    required String type,
    String? startDate,
    List<String>? timeSlots,
    List<int>? matchDays,
    int? matchesPerDay,
    bool clearExisting = false,
  }) async {
    state = ScheduleGenerationState(isLoading: true);
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
      state = ScheduleGenerationState(
        isSuccess: true,
        summary: result['summary'],
      );
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

final scheduleGenerationNotifierProvider = StateNotifierProvider<ScheduleGenerationNotifier, ScheduleGenerationState>((ref) {
  final api = ref.watch(tournamentApiProvider);
  return ScheduleGenerationNotifier(api);
});
