import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/reward_provider.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/reward.dart';
import '../widgets/reward_visuals.dart';

class RewardDetailScreen extends ConsumerStatefulWidget {
  final int rewardId;

  const RewardDetailScreen({super.key, required this.rewardId});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _isRedeeming = false;

  Future<void> _redeemReward() async {
    final user = ref.read(authStateProvider).valueOrNull?.user;
    if (user == null) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }

    setState(() => _isRedeeming = true);

    try {
      await ref.read(rewardApiProvider).redeemReward(rewardId: widget.rewardId);
      await ref.read(authStateProvider.notifier).refreshProfile();
      ref.invalidate(rewardsProvider);
      ref.invalidate(userRewardsProvider);
      ref.invalidate(redemptionHistoryProvider);
      ref.invalidate(rewardDetailProvider(widget.rewardId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi thưởng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đổi thưởng thất bại: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRedeeming = false);
      }
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(rewardDetailProvider(widget.rewardId));
    await ref.read(rewardDetailProvider(widget.rewardId).future);
  }

  @override
  Widget build(BuildContext context) {
    final rewardAsync = ref.watch(rewardDetailProvider(widget.rewardId));
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;
    final userPoints = user?.totalPoints ?? 0;
    final isLoggedIn = user != null;

    return Scaffold(
      body: rewardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải thông tin phần thưởng',
          onRetry: () => ref.invalidate(rewardDetailProvider(widget.rewardId)),
        ),
        data: (reward) {
          final theme = Theme.of(context);
          final heroTag = 'reward-image-${reward.id}';
          final coverImage = RewardVisuals.imageFor(reward);
          final gradient = RewardVisuals.gradientForType(reward.type);
          final friendlyType = RewardVisuals.labelForType(reward.type);
          final typeIcon = RewardVisuals.iconForType(reward.type);
          final canRedeem = isLoggedIn &&
              userPoints >= reward.pointsCost &&
              reward.isAvailable;

          return LoadingOverlay(
            isLoading: _isRedeeming,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    stretch: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        reward.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: CachedNetworkImage(
                              imageUrl: coverImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.card_giftcard,
                                  size: 100,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 24,
                            child: _buildHeroInfoChip(
                              icon: typeIcon,
                              label: friendlyType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              _buildPointsBadge(theme, reward.pointsCost),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (reward.quantity != null)
                                _buildChipTag(
                                  context,
                                  reward.quantity! > 0
                                      ? 'Còn ${reward.quantity} phần'
                                      : 'Đã hết quà',
                                  reward.quantity! > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              if (reward.expiresAt != null)
                                _buildChipTag(
                                  context,
                                  'HSD: ${_formatDate(reward.expiresAt!)}',
                                  Colors.orange,
                                ),
                              if (reward.isPhysical)
                                _buildChipTag(
                                  context,
                                  'Quà vật lý',
                                  theme.colorScheme.primary,
                                ),
                              if (!reward.isActive)
                                _buildChipTag(
                                  context,
                                  'Không khả dụng',
                                  Colors.grey,
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Thông tin nổi bật',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildInfoHighlight(
                                icon: Icons.stars_rounded,
                                label: 'Điểm quy đổi',
                                value: '${reward.pointsCost}',
                                color: theme.colorScheme.primary,
                              ),
                              if (reward.quantity != null)
                                _buildInfoHighlight(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Số lượng còn',
                                  value: reward.quantity! > 0
                                      ? '${reward.quantity}'
                                      : 'Đã hết',
                                  color: reward.quantity! > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              _buildInfoHighlight(
                                icon: Icons.verified_user,
                                label: 'Trạng thái',
                                value: reward.isActive ? 'Có sẵn' : 'Tạm khóa',
                                color: reward.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              if (reward.expiresAt != null)
                                _buildInfoHighlight(
                                  icon: Icons.event_available,
                                  label: 'Hạn sử dụng',
                                  value: _formatDate(reward.expiresAt!),
                                  color: Colors.orange,
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            title: 'Mô tả chi tiết',
                            content: reward.description ??
                                'Không có mô tả cho quà tặng này.',
                          ),
                          if (reward.terms != null) ...[
                            const SizedBox(height: 16),
                            _buildDetailSection(
                              title: 'Điều kiện & Điều khoản',
                              content: reward.terms!,
                            ),
                          ],
                          if (reward.sponsor != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Nhà tài trợ',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSponsorCard(theme, reward),
                          ],
                          if (isLoggedIn) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Điểm của bạn',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildUserPointsCard(
                              theme,
                              userPoints,
                              reward.pointsCost,
                            ),
                            if (!canRedeem)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  userPoints >= reward.pointsCost
                                      ? 'Quà chưa thể đổi ở thời điểm này.'
                                      : 'Bạn còn thiếu ${reward.pointsCost - userPoints} điểm.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                          ] else ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: theme.colorScheme.surfaceVariant,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đăng nhập để đổi quà',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tạo tài khoản hoặc đăng nhập để tích điểm và đổi quà hấp dẫn.',
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: () => context.push('/login'),
                                    child: const Text('Đăng nhập ngay'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: rewardAsync.whenOrNull(
        data: (reward) {
          final canRedeem = isLoggedIn &&
              userPoints >= reward.pointsCost &&
              reward.isAvailable;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: !isLoggedIn
                    ? () => context.push('/login')
                    : (canRedeem ? _redeemReward : null),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  !isLoggedIn
                      ? 'Đăng nhập để đổi quà'
                      : canRedeem
                          ? 'Đổi ${reward.pointsCost} điểm'
                          : reward.isAvailable
                              ? 'Không đủ điểm'
                              : 'Đã hết quà',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(ThemeData theme, int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            '$points',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
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

  Widget _buildInfoHighlight({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSponsorCard(ThemeData theme, Reward reward) {
    final sponsor = reward.sponsor;
    if (sponsor == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: sponsor.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: sponsor.logoUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.business,
                          color: theme.colorScheme.primary),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: theme.colorScheme.primaryContainer,
                    child:
                        Icon(Icons.business, color: theme.colorScheme.primary),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sponsor.name,
                  style: theme.textTheme.titleMedium,
                ),
                if (sponsor.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    sponsor.description!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPointsCard(
    ThemeData theme,
    int userPoints,
    int pointsCost,
  ) {
    final hasEnough = userPoints >= pointsCost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceVariant,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm của bạn',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '$userPoints điểm',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasEnough ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          if (!hasEnough)
            Text(
              'Thiếu ${pointsCost - userPoints} điểm',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
