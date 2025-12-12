import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../../data/models/tournament_models.dart';

class TournamentScheduleViewScreen extends ConsumerWidget {
  final int seasonId;
  final String seasonName;
  final String? competitionName;

  const TournamentScheduleViewScreen({
    super.key,
    required this.seasonId,
    required this.seasonName,
    this.competitionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(tournamentScheduleProvider(seasonId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              competitionName ?? 'Lịch thi đấu',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              seasonName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tournamentScheduleProvider(seasonId)),
          ),
        ],
      ),
      body: scheduleAsync.when(
        data: (rounds) {
          if (rounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch thi đấu',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lịch thi đấu sẽ được công bố sớm',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tournamentScheduleProvider(seasonId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final round = rounds[index];
                return _RoundCard(round: round);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tournamentScheduleProvider(seasonId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  final TournamentRound round;

  const _RoundCard({required this.round});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  round.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${round.matches.length} trận',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Matches
          ...round.matches.map((match) => _MatchTile(match: match)),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final TournamentMatch match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status == 'finished';
    final isLive = match.status == 'live' || match.status == 'first_half' || match.status == 'second_half';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Teams row
          Row(
            children: [
              // Home team
              Expanded(
                child: Row(
                  children: [
                    _buildTeamLogo(match.homeTeam.logo),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.homeTeam.shortName ?? match.homeTeam.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Score or status
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive 
                      ? Colors.red.shade50 
                      : (isFinished ? Colors.grey.shade100 : Colors.blue.shade50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isFinished || isLive
                    ? Text(
                        '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLive ? Colors.red : Colors.black,
                        ),
                      )
                    : Text(
                        'vs',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
              ),
              
              // Away team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        match.awayTeam.shortName ?? match.awayTeam.name,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTeamLogo(match.awayTeam.logo),
                  ],
                ),
              ),
            ],
          ),
          
          // Match info
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                match.matchDateFormatted ?? 'Chưa xác định',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (match.venue != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    match.venue!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (isLive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String? logo) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: logo != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 20),
              ),
            )
          : const Icon(Icons.sports_soccer, size: 20, color: Colors.grey),
    );
  }
}
