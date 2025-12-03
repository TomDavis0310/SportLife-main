import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/reward_provider.dart';
import '../../data/models/redemption.dart';

class MyRewardsScreen extends ConsumerWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRewardsAsync = ref.watch(userRewardsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phần thưởng của tôi'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Chờ xử lý'),
              Tab(text: 'Đã dùng'),
              Tab(text: 'Hết hạn'),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: userRewardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Không thể tải phần thưởng'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(userRewardsProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (redemptions) {
            final pending =
                redemptions.where((r) => r.status == 'pending').toList();
            final used = redemptions
                .where((r) => r.status == 'used' || r.status == 'approved')
                .toList();
            final expired = redemptions
                .where((r) => r.status == 'expired' || r.status == 'rejected')
                .toList();

            return TabBarView(
              children: [
                _buildRewardList(context, ref, pending, 'pending'),
                _buildRewardList(context, ref, used, 'used'),
                _buildRewardList(context, ref, expired, 'expired'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRewardList(
    BuildContext context,
    WidgetRef ref,
    List<Redemption> redemptions,
    String type,
  ) {
    final theme = Theme.of(context);

    if (redemptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending'
                  ? Icons.hourglass_empty
                  : type == 'used'
                      ? Icons.check_circle_outline
                      : Icons.timer_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'pending'
                  ? 'Chưa có phần thưởng chờ xử lý'
                  : type == 'used'
                      ? 'Chưa có phần thưởng đã sử dụng'
                      : 'Chưa có phần thưởng hết hạn',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userRewardsProvider);
        await ref.read(userRewardsProvider.future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: redemptions.length,
        itemBuilder: (context, index) {
          final redemption = redemptions[index];
          return _MyRewardCard(redemption: redemption);
        },
      ),
    );
  }
}

class _MyRewardCard extends StatelessWidget {
  final Redemption redemption;

  const _MyRewardCard({required this.redemption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reward = redemption.reward;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (redemption.status == 'pending') {
            _showRedemptionCode(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Reward Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: reward?.imageUrl != null
                    ? Image.network(
                        reward!.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward?.name ?? 'Phần thưởng',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đổi ngày: ${_formatDate(redemption.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(context),
                  ],
                ),
              ),

              // Arrow
              if (redemption.status == 'pending')
                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      color: theme.colorScheme.primaryContainer,
      child: Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (redemption.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Chờ xử lý';
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
      case 'used':
        color = Colors.green;
        text = 'Đã sử dụng';
        icon = Icons.check_circle;
        break;
      case 'expired':
        color = Colors.grey;
        text = 'Hết hạn';
        icon = Icons.timer_off;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Bị từ chối';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = redemption.status ?? 'Không rõ';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRedemptionCode(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.qr_code_2, size: 100, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Mã đổi thưởng',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                redemption.voucherCode ?? 'XXXXXX',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Xuất trình mã này tại điểm đổi thưởng',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}/${date.year}';
  }
}
