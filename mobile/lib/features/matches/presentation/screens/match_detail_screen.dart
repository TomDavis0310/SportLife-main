import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/match_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';
import '../widgets/match_header.dart';
import '../widgets/match_events_tab.dart';
import '../widgets/match_lineups_tab.dart';
import '../widgets/match_stats_tab.dart';
import '../widgets/match_highlights_tab.dart';
import '../widgets/prediction_form.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final int matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      body: matchAsync.when(
        data: (match) => _buildContent(match),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(matchDetailProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: matchAsync.whenOrNull(
        data: (match) {
          final user = userAsync.valueOrNull?.user;
          final isSponsor = user?.roles.contains('sponsor') ?? false;

          // Kiểm tra xem nút có nên hiển thị không
          if (!isSponsor || !_canUpdateMatch(match)) {
            return null;
          }

          return FloatingActionButton.extended(
            onPressed: () => context.push('/match/${match.id}/update'),
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.edit_note, color: Colors.white),
            label: const Text(
              'Cập nhật',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  /// Kiểm tra xem có thể cập nhật trận đấu không
  /// Mở khi trận đấu bắt đầu và đóng sau 2h khi trận kết thúc
  bool _canUpdateMatch(Match match) {
    final now = DateTime.now();
    final matchTime = DateTime.tryParse(match.matchTime);

    if (matchTime == null) return false;

    // Nếu trận đang diễn ra -> cho phép
    if (match.isLive) return true;

    // Nếu trận đã kết thúc -> kiểm tra 2h
    if (match.isFinished) {
      // Ước tính thời gian kết thúc = thời gian bắt đầu + 2h (trận đấu ~2h)
      final estimatedEndTime = matchTime.add(const Duration(hours: 2));
      final allowedUntil = estimatedEndTime.add(const Duration(hours: 2));
      return now.isBefore(allowedUntil);
    }

    // Nếu trận chưa bắt đầu nhưng đã đến giờ -> cho phép
    if (match.isScheduled && now.isAfter(matchTime)) {
      return true;
    }

    return false;
  }

  Widget _buildContent(Match match) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: MatchHeader(match: match),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  // Share match
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Set notification
                },
              ),
            ],
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Sự kiện'),
                  Tab(text: 'Đội hình'),
                  Tab(text: 'Thống kê'),
                  Tab(text: 'Highlight'),
                  Tab(text: 'Dự Đoán'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          MatchEventsTab(match: match),
          MatchLineupsTab(match: match),
          MatchStatsTab(match: match),
          MatchHighlightsTab(matchId: match.id),
          PredictionForm(match: match),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
