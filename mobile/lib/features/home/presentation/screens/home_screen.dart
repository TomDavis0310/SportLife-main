import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/match_provider.dart';
import '../../../../core/providers/news_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/highlight_provider.dart';
import '../../../../core/widgets/auto_svg_image.dart';
import '../../../auth/data/models/user.dart';
import '../../../highlights/data/models/match_highlight.dart';
import '../widgets/live_match_card.dart';
import '../widgets/upcoming_match_card.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/highlight_video_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Map<String, dynamic>> _quickActions = const [
    {
      'title': 'Dự đoán',
      'subtitle': 'Đặt kèo ngay',
      'icon': 'assets/icons/football.svg',
      'route': '/predictions',
      'color': Color(0xFFFFA726),
    },
    {
      'title': 'Lịch thi đấu',
      'subtitle': 'Theo dõi hôm nay',
      'icon': 'assets/icons/basketball.svg',
      'route': '/matches',
      'color': Color(0xFF29B6F6),
    },
    {
      'title': 'Đổi quà',
      'subtitle': 'Ưu đãi nóng',
      'icon': 'assets/icons/tennis.svg',
      'route': '/rewards',
      'color': Color(0xFF66BB6A),
    },
    {
      'title': 'Bảng xếp hạng',
      'subtitle': 'Thách đấu bạn bè',
      'icon': 'assets/icons/esports.svg',
      'route': '/leaderboard',
      'color': Color(0xFFAB47BC),
    },
  ];

  final List<Map<String, dynamic>> _sports = const [
    {
      'name': 'Bóng đá',
      'icon': 'assets/icons/football.svg',
      'color': Color(0xFFE0F7FA),
      'matches': '158 trận',
    },
    {
      'name': 'Bóng rổ',
      'icon': 'assets/icons/basketball.svg',
      'color': Color(0xFFFFF3E0),
      'matches': '42 trận',
    },
    {
      'name': 'Quần vợt',
      'icon': 'assets/icons/tennis.svg',
      'color': Color(0xFFF1F8E9),
      'matches': '24 trận',
    },
    {
      'name': 'Esports',
      'icon': 'assets/icons/esports.svg',
      'color': Color(0xFFF3E5F5),
      'matches': '18 giải đấu',
    },
  ];

  Future<void> _refreshContent() async {
    ref.invalidate(liveMatchesProvider);
    ref.invalidate(upcomingMatchesProvider);
    ref.invalidate(featuredNewsProvider);
    ref.invalidate(featuredHighlightsProvider);
    await ref.read(authStateProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final liveMatches = ref.watch(liveMatchesProvider);
    final upcomingMatches = ref.watch(upcomingMatchesProvider);
    final featuredNews = ref.watch(featuredNewsProvider);
    final featuredHighlights = ref.watch(featuredHighlightsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        child: CustomScrollView(
          slivers: [
            _buildHeroAppBar(context, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildQuickActionsSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _buildSportsCarousel(),
              ),
            ),
            ..._buildHighlightsSection(context, featuredHighlights),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                'Trận đang diễn ra',
                subtitle: 'Cập nhật live từng phút',
                onSeeAll: () => context.push('/matches?status=live'),
              ),
            ),
            liveMatches.when(
              data: (matches) {
                if (matches.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Không có trận đấu nào đang diễn ra'),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: LiveMatchCard(match: matches[index]),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: Text('Lỗi tải dữ liệu')),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                'Sắp diễn ra',
                subtitle: 'Đặt kèo trước giờ bóng lăn',
                onSeeAll: () => context.push('/matches'),
              ),
            ),
            upcomingMatches.when(
              data: (matches) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= matches.length) return null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: UpcomingMatchCard(match: matches[index]),
                    );
                  }, childCount: matches.length > 5 ? 5 : matches.length),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: Text('Lỗi tải dữ liệu')),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                'Tin nổi bật',
                subtitle: 'Lướt nhanh các bản tin nóng',
                onSeeAll: () => context.go('/news'),
              ),
            ),
            featuredNews.when(
              data: (news) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: news.length > 5 ? 5 : news.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FeaturedNewsCard(news: news[index]),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: Text('Lỗi tải dữ liệu')),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeroAppBar(BuildContext context, User? user) {
    final points = user?.totalPoints ?? 0;
    final streak = user?.currentStreak ?? 0;
    final accuracy = user?.accuracy ?? 0;
    final numberFormat = NumberFormat.compact();

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 240,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryDark],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào,',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Người dùng',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _circleIconButton(
                        icon: Icons.notifications_none,
                        onTap: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage:
                              user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                          child: user?.avatar == null
                              ? Text(
                                  _userInitial(user),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Điểm hiện tại',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                numberFormat.format(points),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Streak $streak ngày',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/rewards'),
                          icon: const Icon(Icons.card_giftcard, color: Colors.white),
                          label: const Text('Đổi quà', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statChip('${user?.predictionsCount ?? 0}', 'Dự đoán'),
                      _statChip('${accuracy.toStringAsFixed(0)}%', 'Độ chính xác'),
                      _statChip('${user?.bestStreak ?? 0}', 'Streak cao nhất'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _quickActions.length,
      itemBuilder: (context, index) {
        final action = _quickActions[index];
        final Color color = action['color'] as Color;
        return GestureDetector(
          onTap: () => _handleQuickAction(context, action),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AutoSvgImage(
                      source: action['icon'] as String?,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSportsCarousel() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final sport = _sports[index];
          final Color color = sport['color'] as Color;
          return Container(
            width: 150,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSvgImage(
                  source: sport['icon'] as String?,
                  width: 32,
                  height: 32,
                ),
                const Spacer(),
                Text(
                  sport['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sport['matches'] as String,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _sports.length,
      ),
    );
  }

  List<Widget> _buildHighlightsSection(
    BuildContext context,
    AsyncValue<List<MatchHighlight>> highlights,
  ) {
    return highlights.when(
      data: (items) {
        if (items.isEmpty) return [];
        final visibleItems = items.length > 6 ? items.sublist(0, 6) : items;
        return [
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Video Highlights',
              subtitle: 'Xem lại khoảnh khắc nổi bật',
              onSeeAll: () => context.push('/matches?status=finished'),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: visibleItems.length,
                itemBuilder: (context, index) {
                  final highlight = visibleItems[index];
                  return HighlightVideoCard(
                    highlight: highlight,
                    onTap: () => _openHighlight(context, highlight.videoUrl),
                  );
                },
              ),
            ),
          ),
        ];
      },
      loading: () => [
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            context,
            'Video Highlights',
            subtitle: 'Đang tải...',
            onSeeAll: () => context.push('/matches?status=finished'),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Không thể tải highlights: $error',
              style: TextStyle(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHighlight(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liên kết video không hợp lệ')),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở video highlight')),
      );
    }
  }

  String _userInitial(User? user) {
    if (user == null || user.name.isEmpty) {
      return 'S';
    }
    return user.name.substring(0, 1).toUpperCase();
  }

  Widget _statChip(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _handleQuickAction(BuildContext context, Map<String, dynamic> action) {
    final route = action['route'] as String?;
    if (route != null) {
      context.push(route);
    }
  }

}

