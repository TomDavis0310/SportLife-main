import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/predictions/data/models/champion_prediction.dart';
import '../../features/predictions/data/models/champion_prediction_leaderboard.dart';
import '../../features/predictions/data/models/season_champion.dart';
import '../../features/predictions/data/models/available_season.dart';
import '../../features/predictions/data/api/champion_prediction_api.dart';
import '../network/dio_client.dart';

// Champion Prediction API Provider
final championPredictionApiProvider = Provider<ChampionPredictionApi>((ref) {
  return ChampionPredictionApi(ref.watch(dioProvider));
});

// Available Seasons Provider
final availableSeasonsProvider = FutureProvider<List<AvailableSeason>>((ref) async {
  return ref.watch(championPredictionApiProvider).getAvailableSeasons();
});

// Season Teams Provider (with season ID parameter)
final seasonTeamsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, seasonId) async {
  return ref.watch(championPredictionApiProvider).getSeasonTeams(seasonId);
});

// My Champion Predictions Provider
final myChampionPredictionsProvider = FutureProvider<List<ChampionPrediction>>((ref) async {
  return ref.watch(championPredictionApiProvider).getMyPredictions();
});

// My Season Prediction Provider
final mySeasonPredictionProvider = FutureProvider.family<ChampionPrediction?, int>((ref, seasonId) async {
  return ref.watch(championPredictionApiProvider).getMySeasonPrediction(seasonId);
});

// Season Stats Provider
final seasonStatsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, seasonId) async {
  return ref.watch(championPredictionApiProvider).getSeasonStats(seasonId);
});

// Champion Prediction Leaderboard Params
class ChampionLeaderboardParams {
  final String period;
  final int? seasonId;

  const ChampionLeaderboardParams({
    this.period = 'all_time',
    this.seasonId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChampionLeaderboardParams &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          seasonId == other.seasonId;

  @override
  int get hashCode => period.hashCode ^ seasonId.hashCode;
}

// Champion Leaderboard Provider
final championLeaderboardProvider = FutureProvider.family<List<ChampionPredictionLeaderboardEntry>, ChampionLeaderboardParams>((ref, params) async {
  return ref.watch(championPredictionApiProvider).getLeaderboard(
    period: params.period,
    seasonId: params.seasonId,
  );
});

// My Champion Rank Provider
final myChampionRankProvider = FutureProvider.family<ChampionPredictionLeaderboardEntry?, int?>((ref, seasonId) async {
  return ref.watch(championPredictionApiProvider).getMyRank(seasonId: seasonId);
});

// Season Champion Provider
final seasonChampionProvider = FutureProvider.family<SeasonChampion?, int>((ref, seasonId) async {
  return ref.watch(championPredictionApiProvider).getSeasonChampion(seasonId);
});

// All Champions Provider
final allChampionsProvider = FutureProvider<List<SeasonChampion>>((ref) async {
  return ref.watch(championPredictionApiProvider).getAllChampions();
});

// Create Champion Prediction State
class CreateChampionPredictionState {
  final int? seasonId;
  final int? predictedTeamId;
  final String? reason;
  final int confidenceLevel;
  final int pointsWagered;
  final bool isLoading;
  final String? error;

  const CreateChampionPredictionState({
    this.seasonId,
    this.predictedTeamId,
    this.reason,
    this.confidenceLevel = 50,
    this.pointsWagered = 100,
    this.isLoading = false,
    this.error,
  });

  CreateChampionPredictionState copyWith({
    int? seasonId,
    int? predictedTeamId,
    String? reason,
    int? confidenceLevel,
    int? pointsWagered,
    bool? isLoading,
    String? error,
  }) {
    return CreateChampionPredictionState(
      seasonId: seasonId ?? this.seasonId,
      predictedTeamId: predictedTeamId ?? this.predictedTeamId,
      reason: reason ?? this.reason,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      pointsWagered: pointsWagered ?? this.pointsWagered,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Create Champion Prediction Notifier
class CreateChampionPredictionNotifier extends StateNotifier<CreateChampionPredictionState> {
  final ChampionPredictionApi api;

  CreateChampionPredictionNotifier(this.api) : super(const CreateChampionPredictionState());

  void setSeason(int seasonId) {
    state = state.copyWith(seasonId: seasonId, predictedTeamId: null);
  }

  void setTeam(int teamId) {
    state = state.copyWith(predictedTeamId: teamId);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void setConfidenceLevel(int level) {
    state = state.copyWith(confidenceLevel: level);
  }

  void setPointsWagered(int points) {
    state = state.copyWith(pointsWagered: points);
  }

  Future<ChampionPrediction?> submit() async {
    if (state.seasonId == null || state.predictedTeamId == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await api.createPrediction(
        seasonId: state.seasonId!,
        predictedTeamId: state.predictedTeamId!,
        reason: state.reason,
        confidenceLevel: state.confidenceLevel,
        pointsWagered: state.pointsWagered,
      );
      state = const CreateChampionPredictionState();
      return prediction;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<ChampionPrediction?> update(int predictionId) async {
    if (state.predictedTeamId == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await api.updatePrediction(
        predictionId: predictionId,
        predictedTeamId: state.predictedTeamId!,
        reason: state.reason,
        confidenceLevel: state.confidenceLevel,
      );
      state = const CreateChampionPredictionState();
      return prediction;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const CreateChampionPredictionState();
  }
}

// Create Champion Prediction Provider
final createChampionPredictionProvider = StateNotifierProvider<CreateChampionPredictionNotifier, CreateChampionPredictionState>((ref) {
  return CreateChampionPredictionNotifier(ref.watch(championPredictionApiProvider));
});
