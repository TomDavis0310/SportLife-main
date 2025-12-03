import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/reward_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/models/reward.dart';
import '../../data/models/redemption.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshUserPoints());
  }

  Future<void> _refreshUserPoints() async {
    if (!mounted) return;
    final isLoggedIn = ref.read(isLoggedInProvider);
    if (!isLoggedIn) return;
    await ref.read(authStateProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authStateProvider);
    final userPoints = userState.valueOrNull?.user?.totalPoints ?? 0;
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phần thưởng'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Có thể đổi'),
              Tab(
                child: Text(
                  isLoggedIn ? 'Đã đổi' : 'Đăng nhập để xem',
                  style: TextStyle(
                    color: isLoggedIn
                        ? null
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.secondary, AppTheme.secondaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Điểm hiện tại',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userPoints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        isLoggedIn ? context.push('/my-rewards') : _promptLogin(context),
                    icon: const Icon(Icons.history),
                    label: const Text('Lịch sử'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRewardsList(),
                  isLoggedIn
                      ? _buildRedemptionHistory()
                      : _buildLoginRequired(
                          message: 'Đăng nhập để xem lịch sử đổi quà của bạn.',
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList() {
    final rewardsAsync = ref.watch(rewardsProvider);

    return rewardsAsync.when(
      data: (rewards) {
        final available = rewards.where((r) => (r.quantity ?? 0) > 0).toList();

        if (available.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Không có phần thưởng nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: available.length,
          itemBuilder: (context, index) {
            final reward = available[index];
            return _buildRewardCard(context, reward);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
    );
  }

  Widget _buildRewardCard(BuildContext context, Reward reward) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: reward.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: reward.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.card_giftcard, size: 48),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.card_giftcard, size: 48),
                      ),
                    ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.pointsCost} điểm',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (reward.quantity ?? 0) > 0
                        ? () {
                            if (!isLoggedIn) {
                              _promptLogin(context);
                              return;
                            }
                            _showRedeemDialog(context, reward);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isLoggedIn ? 'Đổi ngay' : 'Đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionHistory() {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return _buildLoginRequired(
        message: 'Đăng nhập để xem lịch sử đổi quà của bạn.',
      );
    }

    final historyAsync = ref.watch(redemptionHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(redemptionHistoryProvider);
        await ref.read(redemptionHistoryProvider.future);
      },
      child: historyAsync.when(
        data: (redemptions) {
          if (redemptions.isEmpty) {
            return Stack(
              children: [
                ListView(), // Ensure RefreshIndicator works even when empty
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có lịch sử đổi thưởng',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: redemptions.length,
            itemBuilder: (context, index) {
              final redemption = redemptions[index];
              return _buildRedemptionItem(context, redemption);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  Widget _buildRedemptionItem(BuildContext context, Redemption redemption) {
    Color statusColor;
    String statusText;

    switch (redemption.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Đang xử lý';
        break;
      case 'approved':
        statusColor = AppTheme.primary;
        statusText = 'Đã duyệt';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Từ chối';
        break;
      case 'delivered':
        statusColor = Colors.blue;
        statusText = 'Đã giao';
        break;
      default:
        statusColor = Colors.grey;
        statusText = redemption.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.card_giftcard),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.reward?.name ?? 'Phần thưởng',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '-${redemption.pointsSpent ?? 0} điểm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context, Reward reward) {
    if (!ref.read(isLoggedInProvider)) {
      _promptLogin(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đổi thưởng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có muốn đổi ${reward.name}?'),
            const SizedBox(height: 8),
            Text(
              'Điểm cần: ${reward.pointsCost}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(rewardApiProvider)
                    .redeemReward(rewardId: reward.id);
                ref.invalidate(rewardsProvider);
                ref.invalidate(redemptionHistoryProvider);
                await _refreshUserPoints();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đổi thưởng thành công!'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Đổi'),
          ),
        ],
      ),
    );
  }

  void _promptLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vui lòng đăng nhập để sử dụng tính năng này.'),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () => context.push('/login'),
        ),
      ),
    );
  }

  Widget _buildLoginRequired({required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Đăng nhập ngay'),
          ),
        ],
      ),
    );
  }
}
