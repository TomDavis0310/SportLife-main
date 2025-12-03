import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';
import '../../data/models/match_event.dart';

class MatchEventsTab extends StatelessWidget {
  final Match match;

  const MatchEventsTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final events = match.events ?? [];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có sự kiện nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventTimelineItem(match: match, event: event);
      },
    );
  }
}

class _EventTimelineItem extends StatelessWidget {
  final Match match;
  final MatchEvent event;

  const _EventTimelineItem({required this.match, required this.event});

  @override
  Widget build(BuildContext context) {
    final isHomeEvent =
        event.isHomeSide || (event.teamId != null && event.teamId == match.homeTeamId);
    final icon = _eventIcon(event.eventType);
    final color = _eventColor(event.eventType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            event.displayTime,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: isHomeEvent
                ? _EventBubble(
                    alignRight: true,
                    icon: icon,
                    color: color,
                    event: event,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Container(
          width: 2,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: !isHomeEvent
                ? _EventBubble(
                    alignRight: false,
                    icon: icon,
                    color: color,
                    event: event,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _EventBubble extends StatelessWidget {
  final bool alignRight;
  final IconData icon;
  final Color color;
  final MatchEvent event;

  const _EventBubble({
    required this.alignRight,
    required this.icon,
    required this.color,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final title = _titleText;
    final subtitle = event.typeLabel ?? _defaultTypeLabel;
    final details = _detailLines;

    final content = Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: alignRight
              ? [
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, color: color, size: 18),
                ]
              : [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
          ),
        ],
        for (final line in details) ...[
          const SizedBox(height: 4),
          Text(
            line,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
          ),
        ],
      ],
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: content,
    );
  }

  String get _defaultTypeLabel {
    switch (event.eventType) {
      case 'goal':
        return 'Bàn thắng';
      case 'penalty':
        return 'Phạt đền';
      case 'own_goal':
        return 'Phản lưới';
      case 'yellow_card':
        return 'Thẻ vàng';
      case 'red_card':
        return 'Thẻ đỏ';
      case 'substitution':
        return 'Thay người';
      default:
        return 'Sự kiện';
    }
  }

  String get _titleText {
    if (event.isSubstitution) {
      return event.substitutePlayerName ?? event.playerName ?? 'Thay người';
    }
    return event.playerName ?? event.typeLabel ?? 'Sự kiện';
  }

  List<String> get _detailLines {
    final lines = <String>[];

    if (event.isSubstitution) {
      final label = event.substitutionLabel;
      if (label != null) {
        lines.add(label);
      }
    } else {
      if (event.assistPlayerName != null && event.isGoal) {
        lines.add('Kiến tạo: ${event.assistPlayerName}');
      }
    }

    if (event.description != null && event.description!.isNotEmpty) {
      lines.add(event.description!);
    }

    return lines;
  }
}

IconData _eventIcon(String type) {
  switch (type) {
    case 'goal':
    case 'penalty':
    case 'own_goal':
      return Icons.sports_soccer;
    case 'yellow_card':
      return Icons.square;
    case 'red_card':
      return Icons.square;
    case 'substitution':
      return Icons.swap_horiz;
    case 'penalty_miss':
      return Icons.close;
    case 'var':
      return Icons.tv;
    default:
      return Icons.info_outline;
  }
}

Color _eventColor(String type) {
  switch (type) {
    case 'goal':
    case 'penalty':
      return AppTheme.primary;
    case 'own_goal':
      return Colors.redAccent;
    case 'yellow_card':
      return Colors.amber;
    case 'red_card':
      return Colors.red;
    case 'substitution':
      return Colors.blue;
    case 'penalty_miss':
      return Colors.deepOrange;
    case 'var':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}



