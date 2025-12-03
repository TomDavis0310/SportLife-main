import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';

class MatchListItem extends StatelessWidget {
  final Match match;

  const MatchListItem({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.isLive;
    final isFinished = match.isFinished;
    final stats = match.statistics;
    final hasStats = stats != null && stats.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push('/match/${match.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isLive
              ? Border.all(color: AppTheme.live.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          children: [
            if (match.competitionName != null || match.venue != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (match.competitionName != null)
                      Text(
                        match.competitionName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (match.competitionName != null && match.venue != null)
                      Text(
                        ' • ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    if (match.venue != null)
                      Expanded(
                        child: Text(
                          match.venue!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      if (isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.live,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${match.minute}'",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (isFinished) ...[
                        const Text(
                          'FT',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ] else ...[
                        Text(
                          DateFormat('HH:mm')
                              .format(DateTime.parse(match.matchTime)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamRow(
                        match.homeTeam?.name ?? 'Home',
                        match.homeTeam?.logo,
                        match.homeScore,
                        isHome: true,
                        form: match.homeForm,
                      ),
                      const SizedBox(height: 4),
                      _buildTeamRow(
                        match.awayTeam?.name ?? 'Away',
                        match.awayTeam?.logo,
                        match.awayScore,
                        isHome: false,
                        form: match.awayForm,
                      ),
                    ],
                  ),
                ),
                if (!isFinished && match.canPredict)
                  IconButton(
                    onPressed: () => context.push('/match/${match.id}'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            if (hasStats || match.predictionsCount != null) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasStats)
                    _StatChip(
                      label: 'Sút',
                      value:
                          '${stats['shots_home'] ?? 0}-${stats['shots_away'] ?? 0}',
                    ),
                  if (hasStats)
                    _StatChip(
                      label: 'Sút trúng',
                      value:
                          '${stats['shots_on_target_home'] ?? 0}-${stats['shots_on_target_away'] ?? 0}',
                    ),
                  if (hasStats)
                    _StatChip(
                      label: 'Kiểm soát',
                      value:
                          '${stats['possession_home'] ?? 0}% vs ${stats['possession_away'] ?? 0}%',
                    ),
                  if (match.predictionsCount != null)
                    _StatChip(
                      label: 'Dự đoán',
                      value: '${match.predictionsCount}',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow(
    String name,
    String? logoUrl,
    int? score, {
    required bool isHome,
    List<String>? form,
  }) {
    return Row(
      children: [
        // Team logo
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: logoUrl != null
              ? ClipOval(
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        // Team name
        Expanded(
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        // Form
        if (form != null && form.isNotEmpty) ...[
          const SizedBox(width: 8),
          Row(
            children: form
                .take(5)
                .map((result) => _buildFormIndicator(result))
                .toList(),
          ),
          const SizedBox(width: 8),
        ],
        // Score
        if (score != null)
          Text(
            '$score',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildFormIndicator(String result) {
    Color color;
    switch (result) {
      case 'W':
        color = Colors.green;
        break;
      case 'D':
        color = Colors.grey;
        break;
      case 'L':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      margin: const EdgeInsets.only(right: 2),
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          result,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


