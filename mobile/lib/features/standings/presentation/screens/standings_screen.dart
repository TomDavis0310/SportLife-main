import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/competition_provider.dart';
import '../../../../core/widgets/error_state.dart';

class StandingsScreen extends ConsumerWidget {
  final int competitionId;

  const StandingsScreen({super.key, required this.competitionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(
      competitionStandingsProvider(competitionId),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bảng xếp hạng')),
      body: standingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải bảng xếp hạng',
          onRetry: () =>
              ref.invalidate(competitionStandingsProvider(competitionId)),
        ),
        data: (standings) {
          if (standings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có dữ liệu bảng xếp hạng',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Đội')),
                  DataColumn(label: Text('Đ'), numeric: true),
                  DataColumn(label: Text('T'), numeric: true),
                  DataColumn(label: Text('H'), numeric: true),
                  DataColumn(label: Text('B'), numeric: true),
                  DataColumn(label: Text('BT'), numeric: true),
                  DataColumn(label: Text('BB'), numeric: true),
                  DataColumn(label: Text('HS'), numeric: true),
                  DataColumn(label: Text('Điểm'), numeric: true),
                ],
                rows: List<DataRow>.generate(standings.length, (index) {
                  final standing = standings[index];
                  final team = standing['team'];
                  return DataRow(
                    color: _getRowColor(context, standing['position']),
                    cells: [
                      DataCell(
                        _buildPositionCell(context, standing['position']),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (team != null && team['logo_url'] != null)
                              CachedNetworkImage(
                                imageUrl: team['logo_url'],
                                width: 24,
                                height: 24,
                                placeholder: (_, __) =>
                                    const SizedBox(width: 24, height: 24),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.shield, size: 24),
                              )
                            else
                              const Icon(Icons.shield, size: 24),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.push('/team/${team?['id']}'),
                              child: Text(
                                team?['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text('${standing['played'] ?? 0}')),
                      DataCell(Text('${standing['won'] ?? 0}')),
                      DataCell(Text('${standing['drawn'] ?? 0}')),
                      DataCell(Text('${standing['lost'] ?? 0}')),
                      DataCell(Text('${standing['goals_for'] ?? 0}')),
                      DataCell(Text('${standing['goals_against'] ?? 0}')),
                      DataCell(
                        Text(
                          '${standing['goal_difference'] ?? 0}',
                          style: TextStyle(
                            color: (standing['goal_difference'] ?? 0) > 0
                                ? Colors.green
                                : (standing['goal_difference'] ?? 0) < 0
                                    ? Colors.red
                                    : null,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${standing['points'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPositionCell(BuildContext context, int? position) {
    final theme = Theme.of(context);

    Color? bgColor;
    Color textColor = theme.colorScheme.onSurface;

    if (position != null) {
      if (position <= 4) {
        bgColor = Colors.green.withOpacity(0.8);
        textColor = Colors.white;
      } else if (position >= 18) {
        bgColor = Colors.red.withOpacity(0.8);
        textColor = Colors.white;
      }
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        '${position ?? '-'}',
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  WidgetStateProperty<Color?>? _getRowColor(
    BuildContext context,
    int? position,
  ) {
    return null; // Can customize row colors based on position
  }
}
