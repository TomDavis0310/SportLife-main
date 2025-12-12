import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/competitions/data/api/competition_api.dart' as new_api;
import '../../features/matches/data/api/competition_api.dart';
import '../network/dio_client.dart';

// Competition API Provider (Old - for public matches)
final competitionApiProvider = Provider<CompetitionApi>((ref) {
  return CompetitionApi(ref.watch(dioProvider));
});

// New Competition API Provider (For management)
final managementCompetitionApiProvider = Provider<new_api.CompetitionApi>((ref) {
  return new_api.CompetitionApi(ref.watch(dioProvider));
});

// Competitions List Provider (Public)
final competitionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(competitionApiProvider).getCompetitions();
});

// Managed Competitions Provider (Sponsor/Manager)
final managedCompetitionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(managementCompetitionApiProvider).getCompetitions();
});

// Competition Detail Provider
final competitionDetailProvider = FutureProvider.family<dynamic, int>((
  ref,
  competitionId,
) async {
  return ref.watch(competitionApiProvider).getCompetitionDetail(competitionId);
});

// Competition Standings Provider
final competitionStandingsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  competitionId,
) async {
  return ref.watch(competitionApiProvider).getStandings(competitionId);
});

// Competition Matches Provider
final competitionMatchesProvider =
    FutureProvider.family<List<dynamic>, Map<String, dynamic>>((
  ref,
  params,
) async {
  return ref.watch(competitionApiProvider).getMatches(
        params['competition_id'],
        round: params['round'],
        status: params['status'],
      );
});

// Simple Competition Matches Provider (just by ID)
final simpleCompetitionMatchesProvider =
    FutureProvider.family<List<dynamic>, int>((
  ref,
  competitionId,
) async {
  return ref.watch(competitionApiProvider).getMatches(competitionId);
});

// Selected Competition Provider
final selectedCompetitionProvider = StateProvider<int?>((ref) => null);

