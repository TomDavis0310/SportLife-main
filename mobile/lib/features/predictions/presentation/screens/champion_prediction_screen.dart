import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/champion_prediction_provider.dart';
import '../../data/models/available_season.dart';

class ChampionPredictionScreen extends ConsumerWidget {
  const ChampionPredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Du doan Vo dich'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Du doan'),
              Tab(text: 'BXH'),
              Tab(text: 'Nha vo dich'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PredictionTab(),
            _LeaderboardTab(),
            _ChampionsTab(),
          ],
        ),
      ),
    );
  }
}

class _PredictionTab extends ConsumerWidget {
  const _PredictionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(availableSeasonsProvider);

    return seasonsAsync.when(
      data: (seasons) {
        if (seasons.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chua co mua giai de du doan'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return _SeasonCard(season: season);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Loi: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(availableSeasonsProvider),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonCard extends ConsumerWidget {
  final AvailableSeason season;

  const _SeasonCard({required this.season});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPredictionAsync = ref.watch(mySeasonPredictionProvider(season.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/champion-prediction/${season.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (season.competitionLogoUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        season.competitionLogoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.sports_soccer),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sports_soccer),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season.competitionName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          season.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (season.isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Dang dien ra',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.groups,
                    label: '${season.teamsCount} doi',
                  ),
                  const SizedBox(width: 12),
                  if (season.canPredict)
                    _InfoChip(
                      icon: Icons.check_circle,
                      label: 'Co the du doan',
                      color: Colors.green,
                    )
                  else
                    _InfoChip(
                      icon: Icons.block,
                      label: 'Da dong',
                      color: Colors.red,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              myPredictionAsync.when(
                data: (prediction) {
                  if (prediction != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Du doan cua ban:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  prediction.teamName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(prediction.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prediction.statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(prediction.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ElevatedButton.icon(
                    onPressed: season.canPredict
                        ? () => context.push('/champion-prediction/${season.id}')
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Du doan ngay'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'won':
        return Colors.green;
      case 'lost':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      championLeaderboardProvider(const ChampionLeaderboardParams()),
    );

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chua co du lieu BXH'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(entry.rank ?? index + 1),
                  child: Text(
                    '${entry.rank ?? index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  entry.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Thang: ${entry.correctPredictions}/${entry.totalPredictions} - Ti le: ${entry.winRate}%',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.totalPointsEarned}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Loi nhuan: ${entry.profit >= 0 ? '+' : ''}${entry.profit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: entry.profit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Loi: $error')),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return AppTheme.primary;
    }
  }
}

class _ChampionsTab extends ConsumerWidget {
  const _ChampionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final championsAsync = ref.watch(allChampionsProvider);

    return championsAsync.when(
      data: (champions) {
        if (champions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chua co doi vo dich nao'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: champions.length,
          itemBuilder: (context, index) {
            final champion = champions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: champion.teamLogoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          champion.teamLogoUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.emoji_events, color: Colors.amber),
                          ),
                        ),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.amber),
                      ),
                title: Text(
                  champion.teamName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(champion.seasonName),
                    Text(
                      champion.competitionName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Loi: $error')),
    );
  }
}
