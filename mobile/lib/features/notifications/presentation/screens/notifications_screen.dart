import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/providers/notification_provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ref.read(notificationApiProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
            },
            tooltip: 'Đánh dấu tất cả đã đọc',
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải thông báo',
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Chưa có thông báo nào',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final dynamic notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isRead = notification.readAt != null;

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationApiProvider).deleteNotification(notification.id);
        ref.invalidate(notificationsProvider);
      },
      child: InkWell(
        onTap: () {
          if (!isRead) {
            ref.read(notificationApiProvider).markAsRead(notification.id);
            ref.invalidate(notificationsProvider);
          }
          _handleNotificationTap(context, notification);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead
                ? null
                : theme.colorScheme.primaryContainer.withAlpha(77),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withAlpha(51),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? 'Thông báo',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'match_start':
        return Icons.sports_soccer;
      case 'match_end':
        return Icons.emoji_events;
      case 'goal':
        return Icons.sports_score;
      case 'prediction_result':
        return Icons.analytics;
      case 'badge_earned':
        return Icons.military_tech;
      case 'reward':
        return Icons.card_giftcard;
      case 'news':
        return Icons.article;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'match_start':
        return Colors.green;
      case 'match_end':
        return Colors.blue;
      case 'goal':
        return Colors.orange;
      case 'prediction_result':
        return Colors.purple;
      case 'badge_earned':
        return Colors.amber;
      case 'reward':
        return Colors.pink;
      case 'news':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return timeago.format(dateTime, locale: 'vi');
  }

  void _handleNotificationTap(BuildContext context, dynamic notification) {
    // Navigate based on notification type and data
    final data = notification.data;
    if (data == null) return;

    switch (notification.type) {
      case 'match_start':
      case 'match_end':
      case 'goal':
        if (data['match_id'] != null) {
          // context.push('/match/${data['match_id']}');
        }
        break;
      case 'prediction_result':
        // context.push('/predictions');
        break;
      case 'badge_earned':
        // context.push('/profile');
        break;
      case 'reward':
        if (data['reward_id'] != null) {
          // context.push('/reward/${data['reward_id']}');
        }
        break;
      case 'news':
        if (data['news_id'] != null) {
          // context.push('/news/${data['news_id']}');
        }
        break;
    }
  }
}


