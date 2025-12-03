import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/teams/data/models/team.dart';
import '../../features/teams/data/api/team_api.dart';
import '../network/dio_client.dart';

// Team API Provider
final teamApiProvider = Provider<TeamApi>((ref) {
  return TeamApi(ref.watch(dioProvider));
});

// Teams List Provider
final teamsListProvider =
    FutureProvider.family<List<Team>, Map<String, dynamic>>((
  ref,
  params,
) async {
  return ref.watch(teamApiProvider).getTeams(
        competitionId: params['competition_id'],
        search: params['search'],
        page: params['page'] ?? 1,
      );
});

// Team Detail Provider
final teamDetailProvider = FutureProvider.family<Team, int>((
  ref,
  teamId,
) async {
  return ref.watch(teamApiProvider).getTeamDetail(teamId);
});

// Team Players Provider
final teamPlayersProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  teamId,
) async {
  return ref.watch(teamApiProvider).getTeamPlayers(teamId);
});

// Team Matches Provider
final teamMatchesProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  teamId,
) async {
  return ref.watch(teamApiProvider).getTeamMatches(teamId);
});

// Team News Provider
final teamNewsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  teamId,
) async {
  return ref.watch(teamApiProvider).getTeamNews(teamId);
});

// My Team Provider (Manager)
final myTeamProvider = FutureProvider<Team>((ref) async {
  return ref.watch(teamApiProvider).getMyTeam();
});

// Simple Teams Provider (all teams)
final teamsProvider = FutureProvider<List<Team>>((ref) async {
  return ref.watch(teamApiProvider).getTeams();
});

