import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/matches/data/models/match.dart';
import '../../features/matches/data/models/competition.dart';
import '../../features/matches/data/api/match_api.dart';
import '../network/dio_client.dart';

// Match API Provider
final matchApiProvider = Provider<MatchApi>((ref) {
  return MatchApi(ref.watch(dioProvider));
});

// Competitions Provider
final competitionsProvider = FutureProvider<List<Competition>>((ref) async {
  return ref.watch(matchApiProvider).getCompetitions();
});

// Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected Competition Provider
final selectedCompetitionProvider = StateProvider<int?>((ref) => null);

// Matches Provider
final matchesProvider =
    FutureProvider.family<List<Match>, Map<String, dynamic>>((
  ref,
  params,
) async {
  final api = ref.watch(matchApiProvider);
  return api.getMatches(
    date: params['date'],
    competitionId: params['competition_id'],
    status: params['status'],
    page: params['page'] ?? 1,
  );
});

// Live Matches Provider
final liveMatchesProvider = FutureProvider<List<Match>>((ref) async {
  return ref.watch(matchApiProvider).getLiveMatches();
});

// Upcoming Matches Provider
final upcomingMatchesProvider = FutureProvider<List<Match>>((ref) async {
  return ref.watch(matchApiProvider).getUpcomingMatches(limit: 10);
});

// Match Detail Provider
final matchDetailProvider = FutureProvider.family<Match, int>((
  ref,
  matchId,
) async {
  return ref.watch(matchApiProvider).getMatch(matchId);
});

// Match Events Provider
final matchEventsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  matchId,
) async {
  return ref.watch(matchApiProvider).getMatchEvents(matchId);
});

// Today's Matches Provider
final todayMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return ref.watch(matchApiProvider).getMatches(date: dateStr);
});

// Matches By Date Provider
final matchesByDateProvider = FutureProvider.family<List<Match>, String>((
  ref,
  date,
) async {
  return ref.watch(matchApiProvider).getMatches(date: date);
});

