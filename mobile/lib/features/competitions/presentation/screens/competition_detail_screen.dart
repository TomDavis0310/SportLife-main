import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../matches/presentation/screens/match_detail_screen.dart';
import '../../../teams/presentation/screens/team_detail_screen.dart';
import 'tournament_registration_screen.dart';

class CompetitionDetailScreen extends ConsumerStatefulWidget {
  final int competitionId;
  final dynamic initialData;

  const CompetitionDetailScreen({
    super.key,
    required this.competitionId,
    this.initialData,
  });

  @override
  ConsumerState<CompetitionDetailScreen> createState() =>
      _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState
    extends ConsumerState<CompetitionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competitionAsync =
        ref.watch(competitionDetailProvider(widget.competitionId));
    final standingsAsync =
        ref.watch(competitionStandingsProvider(widget.competitionId));

    return Scaffold(
      body: competitionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải thông tin giải đấu',
          onRetry: () =>
              ref.invalidate(competitionDetailProvider(widget.competitionId)),
        ),
        data: (competition) {
          final data = competition ?? widget.initialData;
          if (data == null) {
            return const ErrorState(message: 'Không tìm thấy giải đấu');
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context, data),
                SliverToBoxAdapter(
                  child: _buildCompetitionHeader(context, data),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: AppTheme.darkGrey,
                      indicatorColor: AppTheme.primary,
                      tabs: const [
                        Tab(text: 'Tổng quan'),
                        Tab(text: 'Đội bóng'),
                        Tab(text: 'Lịch đấu'),
                        Tab(text: 'BXH'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, data),
                _buildTeamsTab(context, data),
                _buildMatchesTab(context, data),
                _buildStandingsTab(context, standingsAsync),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic data) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          data['name'] ?? 'Chi tiết giải đấu',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (data['banner'] != null)
              CachedNetworkImage(
                imageUrl: data['banner'],
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: AppTheme.primaryDark),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () {
            // Share functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Notification settings
          },
        ),
      ],
    );
  }

  Widget _buildCompetitionHeader(BuildContext context, dynamic data) {
    final seasons = data['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;
    final user = ref.watch(currentUserProvider);
    final isManager = user?.roles.contains('club_manager') ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Competition Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: data['logo'] != null
                      ? CachedNetworkImage(
                          imageUrl: data['logo'],
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.emoji_events,
                              size: 40,
                              color: AppTheme.primary),
                        )
                      : const Icon(Icons.emoji_events,
                          size: 40, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              // Competition Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildCompetitionType(data['type']),
                    if (currentSeason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Mùa giải: ${currentSeason['name'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Season dates
          if (currentSeason != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    icon: Icons.play_circle_outlined,
                    label: 'Bắt đầu',
                    date: _formatDate(currentSeason['start_date']),
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateCard(
                    icon: Icons.flag_outlined,
                    label: 'Kết thúc',
                    date: _formatDate(currentSeason['end_date']),
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
          // Register Button for Club Managers
          if (isManager && currentSeason != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentRegistrationScreen(
                        season: currentSeason,
                        competitionName: data['name'] ?? 'Giải đấu',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Đăng ký tham gia giải đấu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompetitionType(String? type) {
    String label;
    IconData icon;
    Color color;

    switch (type) {
      case 'league':
        label = 'Giải Vô Địch Quốc Gia';
        icon = Icons.emoji_events;
        color = AppTheme.warning;
        break;
      case 'cup':
        label = 'Cúp Quốc Gia';
        icon = Icons.military_tech;
        color = AppTheme.secondary;
        break;
      default:
        label = 'Giải đấu';
        icon = Icons.sports_soccer;
        color = AppTheme.primary;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required IconData icon,
    required String label,
    required String date,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== OVERVIEW TAB ====================
  Widget _buildOverviewTab(BuildContext context, dynamic data) {
    final teams = data['teams'] as List? ?? [];
    final seasons = data['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sponsor Section
          _buildSponsorSection(context, data),
          const SizedBox(height: 20),

          // Competition Info
          _buildInfoCard(context, data, currentSeason),
          const SizedBox(height: 20),

          // Quick Stats
          _buildQuickStats(context, data, teams.length),
          const SizedBox(height: 20),

          // Description
          if (data['description'] != null) ...[
            _buildDescriptionSection(context, data),
            const SizedBox(height: 20),
          ],

          // Location/Venue Info
          _buildVenueSection(context, data),
        ],
      ),
    );
  }

  Widget _buildSponsorSection(BuildContext context, dynamic data) {
    final sponsor = data['sponsor'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified,
                      color: AppTheme.info, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nhà tài trợ chính',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sponsor != null) ...[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: sponsor['logo'] != null
                        ? CachedNetworkImage(
                            imageUrl: sponsor['logo'],
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.business, color: AppTheme.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sponsor['name'] ?? 'Nhà tài trợ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (sponsor['website'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            sponsor['website'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.info,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake_outlined,
                        color: AppTheme.grey.withOpacity(0.7), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Liên hệ để trở thành nhà tài trợ',
                      style: TextStyle(
                        color: AppTheme.darkGrey.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, dynamic data, dynamic currentSeason) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Thông tin giải đấu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.category_outlined,
              'Loại giải',
              data['type'] == 'league' ? 'Giải Vô Địch Quốc Gia' : 'Cúp',
            ),
            _buildInfoRow(
              Icons.public,
              'Quốc gia',
              data['country'] ?? 'Việt Nam',
            ),
            if (currentSeason != null) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Mùa giải hiện tại',
                currentSeason['name'] ?? '',
              ),
              _buildInfoRow(
                Icons.schedule,
                'Trạng thái',
                _getSeasonStatus(currentSeason),
              ),
            ],
            if (data['short_name'] != null)
              _buildInfoRow(
                Icons.tag,
                'Tên viết tắt',
                data['short_name'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic data, int teamsCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.groups,
            value: teamsCount.toString(),
            label: 'Đội bóng',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.sports_soccer,
            value: data['matches_count']?.toString() ?? '0',
            label: 'Trận đấu',
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.sports,
            value: data['goals_count']?.toString() ?? '0',
            label: 'Bàn thắng',
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, dynamic data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: AppTheme.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Giới thiệu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['description'],
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueSection(BuildContext context, dynamic data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined,
                      color: AppTheme.accent, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Địa điểm thi đấu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 18, color: AppTheme.darkGrey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data['country'] ?? 'Việt Nam',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.stadium_outlined,
                          size: 18, color: AppTheme.darkGrey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Các sân vận động trên toàn quốc',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TEAMS TAB ====================
  Widget _buildTeamsTab(BuildContext context, dynamic data) {
    final teams = data['teams'] as List? ?? [];

    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: AppTheme.grey),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đội bóng tham gia',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamCard(context, team, index + 1);
      },
    );
  }

  Widget _buildTeamCard(BuildContext context, dynamic team, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          if (team['id'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailScreen(teamId: team['id']),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Team Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: team['logo'] != null
                      ? CachedNetworkImage(
                          imageUrl: team['logo'],
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              const Icon(Icons.sports_soccer),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.sports_soccer),
                        )
                      : Center(
                          child: Text(
                            team['name']?[0] ?? '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Team Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team['name'] ?? 'Unknown Team',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.stadium_outlined,
                            size: 14, color: AppTheme.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            team['stadium'] ?? 'Chưa cập nhật',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (team['city'] != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_city,
                              size: 14, color: AppTheme.grey),
                          const SizedBox(width: 4),
                          Text(
                            team['city'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MATCHES TAB ====================
  Widget _buildMatchesTab(BuildContext context, dynamic data) {
    final seasons = data['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;

    if (currentSeason == null) {
      return const Center(
        child: Text('Không có thông tin mùa giải'),
      );
    }

    final matchesParams = {
      'competition_id': widget.competitionId,
    };

    final matchesAsync = ref.watch(competitionMatchesProvider(matchesParams));

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('Không thể tải lịch đấu: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(competitionMatchesProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy_outlined,
                    size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lịch thi đấu',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          );
        }

        // Group matches by date
        final groupedMatches = <String, List<dynamic>>{};
        for (var match in matches) {
          final date = match['match_date']?.split('T')[0] ?? 'unknown';
          groupedMatches.putIfAbsent(date, () => []).add(match);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedMatches.length,
          itemBuilder: (context, index) {
            final date = groupedMatches.keys.elementAt(index);
            final dayMatches = groupedMatches[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatMatchDate(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Matches for this date
                ...dayMatches.map((match) => _buildMatchCard(context, match)),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, dynamic match) {
    final homeTeam = match['home_team'] ?? {};
    final awayTeam = match['away_team'] ?? {};
    final status = match['status'] ?? 'scheduled';
    final isLive = status == 'live' || status == '1st_half' || status == '2nd_half';
    final isFinished = status == 'finished';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLive
              ? AppTheme.live.withOpacity(0.5)
              : AppTheme.lightGrey.withOpacity(0.5),
          width: isLive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (match['id'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(matchId: match['id']),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Match Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMatchStatus(status, match['minute']),
                  if (match['venue'] != null)
                    Row(
                      children: [
                        const Icon(Icons.stadium_outlined,
                            size: 12, color: AppTheme.grey),
                        const SizedBox(width: 4),
                        Text(
                          match['venue'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Teams and Score
              Row(
                children: [
                  // Home Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(homeTeam['logo'], homeTeam['name']),
                        const SizedBox(height: 8),
                        Text(
                          homeTeam['name'] ?? 'Home',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Score
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isLive
                          ? AppTheme.live.withOpacity(0.1)
                          : (isFinished
                              ? AppTheme.finished.withOpacity(0.1)
                              : AppTheme.scheduled.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isFinished || isLive
                        ? Text(
                            '${match['home_score'] ?? 0} - ${match['away_score'] ?? 0}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isLive ? AppTheme.live : AppTheme.black,
                            ),
                          )
                        : Text(
                            _formatMatchTime(match['match_date']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.scheduled,
                            ),
                          ),
                  ),
                  // Away Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(awayTeam['logo'], awayTeam['name']),
                        const SizedBox(height: 8),
                        Text(
                          awayTeam['name'] ?? 'Away',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String? teamName) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: logoUrl != null
            ? CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Icon(Icons.sports_soccer),
                errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer),
              )
            : Center(
                child: Text(
                  teamName?[0] ?? '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMatchStatus(String status, dynamic minute) {
    Color color;
    String label;
    bool showPulse = false;

    switch (status) {
      case 'live':
      case '1st_half':
      case '2nd_half':
        color = AppTheme.live;
        label = minute != null ? '$minute\'' : 'LIVE';
        showPulse = true;
        break;
      case 'halftime':
        color = AppTheme.warning;
        label = 'HT';
        break;
      case 'finished':
        color = AppTheme.finished;
        label = 'KT';
        break;
      case 'postponed':
        color = AppTheme.error;
        label = 'Hoãn';
        break;
      default:
        color = AppTheme.scheduled;
        label = 'Sắp diễn ra';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STANDINGS TAB ====================
  Widget _buildStandingsTab(
      BuildContext context, AsyncValue<List<dynamic>> standingsAsync) {
    return standingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text('Không thể tải bảng xếp hạng'),
            ElevatedButton(
              onPressed: () => ref.invalidate(
                  competitionStandingsProvider(widget.competitionId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (standings) {
        if (standings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_outlined,
                    size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có bảng xếp hạng',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                          width: 30,
                          child: Text('#',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      const Expanded(
                          flex: 3,
                          child: Text('Đội',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      _buildStandingHeader('Tr'),
                      _buildStandingHeader('T'),
                      _buildStandingHeader('H'),
                      _buildStandingHeader('B'),
                      _buildStandingHeader('Đ', isLast: true),
                    ],
                  ),
                ),
                // Standings List
                ...standings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final standing = entry.value;
                  return _buildStandingRow(standing, index);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStandingHeader(String text, {bool isLast = false}) {
    return SizedBox(
      width: isLast ? 35 : 28,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isLast ? AppTheme.primary : AppTheme.darkGrey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStandingRow(dynamic standing, int index) {
    final team = standing['team'] ?? {};
    final position = standing['position'] ?? (index + 1);

    Color positionColor;
    if (position <= 3) {
      positionColor = AppTheme.success;
    } else if (position <= 6) {
      positionColor = AppTheme.info;
    } else {
      positionColor = AppTheme.darkGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.lightGrey.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 30,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: positionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: positionColor,
                  ),
                ),
              ),
            ),
          ),
          // Team
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: team['logo'] != null
                      ? CachedNetworkImage(
                          imageUrl: team['logo'],
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Text(
                            team['name']?[0] ?? '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team['short_name'] ?? team['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Stats
          _buildStandingStat(standing['played']?.toString() ?? '0'),
          _buildStandingStat(standing['won']?.toString() ?? '0'),
          _buildStandingStat(standing['drawn']?.toString() ?? '0'),
          _buildStandingStat(standing['lost']?.toString() ?? '0'),
          SizedBox(
            width: 35,
            child: Text(
              standing['points']?.toString() ?? '0',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingStat(String value) {
    return SizedBox(
      width: 28,
      child: Text(
        value,
        style: const TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatMatchDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final matchDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (matchDay == today) {
        return 'Hôm nay';
      } else if (matchDay == today.add(const Duration(days: 1))) {
        return 'Ngày mai';
      } else if (matchDay == today.subtract(const Duration(days: 1))) {
        return 'Hôm qua';
      } else {
        return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(dateTime);
      }
    } catch (e) {
      return date;
    }
  }

  String _formatMatchTime(dynamic matchDate) {
    if (matchDate == null) return 'TBD';
    try {
      final dateTime = DateTime.parse(matchDate.toString());
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'TBD';
    }
  }

  String _getSeasonStatus(dynamic season) {
    if (season == null) return 'N/A';

    try {
      final startDate = DateTime.parse(season['start_date'].toString());
      final endDate = DateTime.parse(season['end_date'].toString());
      final now = DateTime.now();

      if (now.isBefore(startDate)) {
        return 'Sắp bắt đầu';
      } else if (now.isAfter(endDate)) {
        return 'Đã kết thúc';
      } else {
        return 'Đang diễn ra';
      }
    } catch (e) {
      return 'N/A';
    }
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
