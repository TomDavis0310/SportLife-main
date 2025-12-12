import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colors = AppTheme.getColors(context);

    if (user == null) {
      return Scaffold(
        body: _buildNotLoggedInView(context),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authStateProvider.notifier).refreshProfile();
        },
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            // Profile Header
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(
                user: user,
                onEditTap: () => context.push('/profile/edit'),
                onAvatarTap: () => _showAvatarPreview(context, user.avatar),
              ),
            ),
            // Stats Card
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: ProfileStatsCard(
                  user: user,
                  onTap: () => context.push('/profile/statistics'),
                ),
              ),
            ),
            // Menu Sections
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Activity Section
                  ProfileMenuSection(
                    title: 'HOẠT ĐỘNG',
                    items: [
                      ProfileMenuItem(
                        icon: Icons.history,
                        title: 'Lịch sử dự đoán',
                        subtitle: 'Xem các dự đoán đã thực hiện',
                        onTap: () => context.push('/predictions'),
                      ),
                      ProfileMenuItem(
                        icon: Icons.emoji_events,
                        title: 'Bảng xếp hạng',
                        subtitle: 'Vị trí của bạn trong cộng đồng',
                        onTap: () => context.push('/leaderboard'),
                        iconColor: AppTheme.warning,
                      ),
                      ProfileMenuItem(
                        icon: Icons.card_giftcard,
                        title: 'Phần thưởng',
                        subtitle: 'Đổi điểm lấy quà',
                        onTap: () => context.push('/rewards'),
                        iconColor: AppTheme.accent,
                      ),
                    ],
                  ),
                  // Achievement Section
                  ProfileMenuSection(
                    title: 'THÀNH TÍCH',
                    items: [
                      ProfileMenuItem(
                        icon: Icons.military_tech,
                        title: 'Huy hiệu',
                        subtitle: 'Các huy hiệu bạn đã đạt được',
                        onTap: () => context.push('/badges'),
                        iconColor: AppTheme.secondary,
                      ),
                      ProfileMenuItem(
                        icon: Icons.timeline,
                        title: 'Tiến trình',
                        subtitle: 'Theo dõi sự tiến bộ của bạn',
                        onTap: () => context.push('/profile/progress'),
                        iconColor: AppTheme.info,
                      ),
                    ],
                  ),
                  // Social Section
                  ProfileMenuSection(
                    title: 'XÃ HỘI',
                    items: [
                      ProfileMenuItem(
                        icon: Icons.people,
                        title: 'Bạn bè',
                        subtitle: 'Quản lý danh sách bạn bè',
                        showBadge: true,
                        badgeCount: 3,
                        onTap: () => context.push('/friends'),
                      ),
                      ProfileMenuItem(
                        icon: Icons.share,
                        title: 'Chia sẻ hồ sơ',
                        subtitle: 'Mời bạn bè tham gia',
                        onTap: () => _shareProfile(context),
                        iconColor: AppTheme.secondary,
                      ),
                    ],
                  ),
                  // Support Section
                  ProfileMenuSection(
                    title: 'HỖ TRỢ',
                    items: [
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Trợ giúp',
                        subtitle: 'Câu hỏi thường gặp',
                        onTap: () => context.push('/help'),
                      ),
                      ProfileMenuItem(
                        icon: Icons.feedback_outlined,
                        title: 'Phản hồi',
                        subtitle: 'Gửi ý kiến đóng góp',
                        onTap: () => _showFeedbackDialog(context),
                      ),
                      ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'Về ứng dụng',
                        subtitle: 'Phiên bản 1.0.0',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withOpacity(0.8),
            AppTheme.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Chào mừng đến với SportLife',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đăng nhập để xem hồ sơ và theo dõi thành tích của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push('/register'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPreview(BuildContext context, String? avatar) {
    if (avatar == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                avatar,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chuẩn bị chia sẻ...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phản hồi'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ý kiến của bạn giúp chúng tôi cải thiện ứng dụng',
              style: TextStyle(color: AppTheme.darkGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập phản hồi của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn phản hồi của bạn!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'SportLife',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sports_soccer, color: Colors.white, size: 32),
        ),
        applicationLegalese: '© 2024 SportLife. All rights reserved.',
        children: const [
          SizedBox(height: 16),
          Text('Ứng dụng dự đoán bóng đá với nhiều tính năng thú vị như dự đoán trận đấu, theo dõi bảng xếp hạng, nhận thưởng và hơn thế nữa.'),
        ],
      ),
    );
  }
}
