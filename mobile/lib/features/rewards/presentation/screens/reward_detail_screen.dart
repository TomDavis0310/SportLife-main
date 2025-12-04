import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/reward_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/error_state.dart';

class RewardDetailScreen extends ConsumerStatefulWidget {
  final int rewardId;

  const RewardDetailScreen({super.key, required this.rewardId});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _isRedeeming = false;

  Future<void> _redeemReward() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isRedeeming = true);

    try {
      await ref.read(rewardApiProvider).redeemReward(rewardId: widget.rewardId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi thưởng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(userRewardsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đổi thưởng thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRedeeming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardAsync = ref.watch(rewardDetailProvider(widget.rewardId));
    final userState = ref.watch(authStateProvider).valueOrNull;
    final userPoints = userState?.user?.totalPoints ?? 0;

    return Scaffold(
      body: rewardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải thông tin phần thưởng',
          onRetry: () => ref.invalidate(rewardDetailProvider(widget.rewardId)),
        ),
        data: (reward) {
          final theme = Theme.of(context);
          // ignore: unused_local_variable
          final canRedeem = userState != null &&
              userPoints >= reward.pointsCost &&
              (reward.quantity == null || reward.quantity! > 0) &&
              reward.isActive;

          return LoadingOverlay(
            isLoading: _isRedeeming,
            child: CustomScrollView(
              slivers: [
                // Hero Image
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: reward.imageUrl != null
                        ? Image.network(
                            reward.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.card_giftcard,
                                size: 100,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.card_giftcard,
                              size: 100,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Points
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reward.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reward.pointsCost}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Status Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (reward.quantity != null)
                              _buildTag(
                                context,
                                'Còn ${reward.quantity} phần',
                                reward.quantity! > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            if (reward.expiresAt != null)
                              _buildTag(
                                context,
                                'HSD: ${_formatDate(reward.expiresAt!)}',
                                Colors.orange,
                              ),
                            if (!reward.isActive)
                              _buildTag(context, 'Không khả dụng', Colors.grey),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Mô tả',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reward.description ?? 'Không có mô tả',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Your Points
                        if (userState?.user != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Điểm của bạn',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '$userPoints điểm',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: userPoints >= reward.pointsCost
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (userPoints < reward.pointsCost)
                                  Text(
                                    'Thiếu ${reward.pointsCost - userPoints} điểm',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Terms
                        if (reward.terms != null) ...[
                          Text(
                            'Điều kiện & Điều khoản',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            reward.terms!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Sponsor Info
                        if (reward.sponsor != null) ...[
                          Text(
                            'Nhà tài trợ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withAlpha(77),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: reward.sponsor!.logoUrl != null
                                      ? Image.network(
                                          reward.sponsor!.logoUrl!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 48,
                                          height: 48,
                                          color: theme
                                              .colorScheme.primaryContainer,
                                          child: Icon(
                                            Icons.business,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reward.sponsor!.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: rewardAsync.whenOrNull(
        data: (reward) {
          final canRedeem = userState?.user != null &&
              userPoints >= reward.pointsCost &&
              (reward.quantity == null || reward.quantity! > 0) &&
              reward.isActive;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: canRedeem ? _redeemReward : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  canRedeem
                      ? 'Đổi ${reward.pointsCost} điểm'
                      : userState?.user == null
                          ? 'Đăng nhập để đổi thưởng'
                          : !reward.isActive
                              ? 'Phần thưởng không khả dụng'
                              : (reward.quantity ?? 1) <= 0
                                  ? 'Đã hết'
                                  : 'Không đủ điểm',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
