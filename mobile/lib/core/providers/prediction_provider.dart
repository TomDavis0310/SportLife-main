import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/predictions/data/models/prediction.dart';
import '../../features/predictions/data/models/leaderboard_entry.dart';
import '../../features/predictions/data/api/prediction_api.dart';
import '../network/dio_client.dart';

// Prediction API Provider
final predictionApiProvider = Provider<PredictionApi>((ref) {
  return PredictionApi(ref.watch(dioProvider));
});

// My Predictions Provider
final myPredictionsProvider = FutureProvider<List<Prediction>>((ref) async {
  return ref.watch(predictionApiProvider).getMyPredictions();
});

// Leaderboard Params
class LeaderboardParams {
  final String period;
  final int? competitionId;
  final int page;

  const LeaderboardParams({
    this.period = 'all_time',
    this.competitionId,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardParams &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          competitionId == other.competitionId &&
          page == other.page;

  @override
  int get hashCode => period.hashCode ^ competitionId.hashCode ^ page.hashCode;
}

// Leaderboard Provider
final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, LeaderboardParams>((
      ref,
      params,
    ) async {
      return ref
          .watch(predictionApiProvider)
          .getLeaderboard(
            period: params.period,
            competitionId: params.competitionId,
            page: params.page,
          );
    });

// Prediction Stats Provider
final predictionStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return ref.watch(predictionApiProvider).getMyStats();
});

// Create Prediction State
class CreatePredictionState {
  final int? matchId;
  final String? predictedOutcome; // 'home', 'draw', 'away'
  final bool isLoading;
  final String? error;

  const CreatePredictionState({
    this.matchId,
    this.predictedOutcome,
    this.isLoading = false,
    this.error,
  });

  CreatePredictionState copyWith({
    int? matchId,
    String? predictedOutcome,
    bool? isLoading,
    String? error,
  }) {
    return CreatePredictionState(
      matchId: matchId ?? this.matchId,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Create Prediction Notifier
class CreatePredictionNotifier extends StateNotifier<CreatePredictionState> {
  final PredictionApi api;

  CreatePredictionNotifier(this.api) : super(const CreatePredictionState());

  void setMatch(int matchId) {
    state = state.copyWith(matchId: matchId);
  }

  void setPredictedOutcome(String outcome) {
    state = state.copyWith(predictedOutcome: outcome);
  }

  Future<Prediction?> submit() async {
    if (state.matchId == null || state.predictedOutcome == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await api.createPrediction(
        matchId: state.matchId!,
        predictedOutcome: state.predictedOutcome!,
      );
      state = const CreatePredictionState();
      return prediction;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const CreatePredictionState();
  }
}

// Create Prediction Provider
final createPredictionProvider =
    StateNotifierProvider<CreatePredictionNotifier, CreatePredictionState>((
      ref,
    ) {
      return CreatePredictionNotifier(ref.watch(predictionApiProvider));
    });

