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
  int _selectedRound = 0; // 0 = Tất cả
  String _selectedStatus = 'all'; // all, scheduled, finished, live

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
    
    // Check if there's any description or rules to show
    final hasDescription = data['description'] != null || 
        (currentSeason != null && (currentSeason['description'] != null || currentSeason['rules'] != null));

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

          // Description & Rules
          if (hasDescription) ...[
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
            // Round type - Hình thức thi đấu
            if (currentSeason != null && currentSeason['round_type'] != null)
              _buildInfoRow(
                Icons.sports_soccer,
                'Hình thức',
                currentSeason['round_type_label'] ?? _getRoundTypeLabel(currentSeason['round_type']),
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
              // Số đội tham gia
              _buildInfoRow(
                Icons.groups_outlined,
                'Số đội',
                '${currentSeason['min_teams'] ?? 2} - ${currentSeason['max_teams'] ?? 20} đội',
              ),
              // Thời gian đăng ký
              if (currentSeason['registration_start_date'] != null ||
                  currentSeason['registration_end_date'] != null) ...[
                _buildInfoRow(
                  Icons.app_registration,
                  'Đăng ký từ',
                  _formatDate(currentSeason['registration_start_date']),
                ),
                _buildInfoRow(
                  Icons.event_busy,
                  'Đăng ký đến',
                  _formatDate(currentSeason['registration_end_date']),
                ),
              ],
              // Địa điểm
              if (currentSeason['location'] != null &&
                  currentSeason['location'].toString().isNotEmpty)
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Địa điểm',
                  currentSeason['location'],
                ),
              // Giải thưởng
              if (currentSeason['prize'] != null &&
                  currentSeason['prize'].toString().isNotEmpty)
                _buildInfoRow(
                  Icons.card_giftcard_outlined,
                  'Giải thưởng',
                  currentSeason['prize'],
                ),
              // Liên hệ
              if (currentSeason['contact'] != null &&
                  currentSeason['contact'].toString().isNotEmpty)
                _buildInfoRow(
                  Icons.contact_phone_outlined,
                  'Liên hệ',
                  currentSeason['contact'],
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
    final seasons = data['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;
    final description = data['description'] ?? currentSeason?['description'];
    final rules = currentSeason?['rules'];

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
            if (description != null && description.toString().isNotEmpty)
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.darkGrey,
                ),
              ),
            // Luật lệ giải đấu
            if (rules != null && rules.toString().isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.rule,
                        color: AppTheme.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Điều lệ giải đấu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                ),
                child: Text(
                  rules,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ),
            ],
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

    final matchesAsync = ref.watch(simpleCompetitionMatchesProvider(widget.competitionId));

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
              onPressed: () => ref.invalidate(simpleCompetitionMatchesProvider(widget.competitionId)),
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
                Icon(Icons.event_busy_outlined, size: 64, color: AppTheme.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lịch thi đấu',
                  style: TextStyle(fontSize: 16, color: AppTheme.darkGrey),
                ),
              ],
            ),
          );
        }

        // Get all rounds from matches with names
        final roundsMap = <int, String>{};
        for (var match in matches) {
          final roundNum = match['round']?['number'] ?? 0;
          final roundName = match['round']?['name'] ?? 'Vòng $roundNum';
          if (roundNum > 0 && !roundsMap.containsKey(roundNum)) {
            roundsMap[roundNum] = roundName;
          }
        }
        final sortedRounds = roundsMap.keys.toList()..sort();

        // Filter matches
        List<dynamic> filteredMatches = matches;
        
        // Filter by round
        if (_selectedRound > 0) {
          filteredMatches = filteredMatches.where((m) => 
            m['round']?['number'] == _selectedRound
          ).toList();
        }
        
        // Filter by status
        if (_selectedStatus != 'all') {
          filteredMatches = filteredMatches.where((m) {
            final status = m['status'] ?? '';
            if (_selectedStatus == 'live') {
              return status == 'live' || status == '1st_half' || status == '2nd_half';
            } else if (_selectedStatus == 'finished') {
              return status == 'finished';
            } else if (_selectedStatus == 'scheduled') {
              return status == 'scheduled';
            }
            return true;
          }).toList();
        }

        // Group matches by round for display
        final groupedByRound = <int, List<dynamic>>{};
        for (var match in filteredMatches) {
          final roundNum = match['round']?['number'] ?? 0;
          groupedByRound.putIfAbsent(roundNum, () => []).add(match);
        }
        final sortedGroupRounds = groupedByRound.keys.toList()..sort();

        return Column(
          children: [
            // Filters Section
            _buildMatchFilters(sortedRounds, roundsMap),
            
            // Stats Summary
            _buildMatchStats(matches),
            
            // Matches List
            Expanded(
              child: filteredMatches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off, size: 48, color: AppTheme.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'Không có trận đấu phù hợp',
                            style: TextStyle(color: AppTheme.darkGrey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedGroupRounds.length,
                      itemBuilder: (context, index) {
                        final roundNum = sortedGroupRounds[index];
                        final roundMatches = groupedByRound[roundNum]!;
                        
                        return _buildRoundSection(context, roundNum, roundMatches);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchFilters(List<int> rounds, Map<int, String> roundsMap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round Filter
          Row(
            children: [
              Icon(Icons.filter_list, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text('Vòng đấu:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoundChip('Tất cả', 0),
                      ...rounds.map((r) => _buildRoundChip(roundsMap[r] ?? 'Vòng $r', r)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status Filter
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              _buildStatusChip('Tất cả', 'all', Icons.list),
              _buildStatusChip('Sắp diễn ra', 'scheduled', Icons.access_time),
              _buildStatusChip('Đang đấu', 'live', Icons.play_circle),
              _buildStatusChip('Kết thúc', 'finished', Icons.check_circle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundChip(String label, int roundNum) {
    final isSelected = _selectedRound == roundNum;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedRound = roundNum),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, IconData icon) {
    final isSelected = _selectedStatus == status;
    Color chipColor;
    switch (status) {
      case 'live':
        chipColor = AppTheme.live;
        break;
      case 'finished':
        chipColor = AppTheme.finished;
        break;
      case 'scheduled':
        chipColor = AppTheme.scheduled;
        break;
      default:
        chipColor = AppTheme.primary;
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedStatus = status),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? chipColor : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? chipColor : Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? chipColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchStats(List<dynamic> matches) {
    int total = matches.length;
    int scheduled = matches.where((m) => m['status'] == 'scheduled').length;
    int finished = matches.where((m) => m['status'] == 'finished').length;
    int live = matches.where((m) => 
      m['status'] == 'live' || m['status'] == '1st_half' || m['status'] == '2nd_half'
    ).length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.1), AppTheme.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tổng', total, Icons.sports_soccer, AppTheme.primary),
          Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
          _buildStatItem('Sắp đấu', scheduled, Icons.schedule, AppTheme.scheduled),
          Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
          _buildStatItem('Đang đấu', live, Icons.play_circle_fill, AppTheme.live),
          Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
          _buildStatItem('Kết thúc', finished, Icons.check_circle, AppTheme.finished),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRoundSection(BuildContext context, int roundNum, List<dynamic> matches) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get round name from first match
    final roundName = matches.isNotEmpty 
        ? (matches.first['round']?['name'] ?? 'Vòng $roundNum')
        : 'Vòng $roundNum';
    
    // Sort matches by date
    matches.sort((a, b) {
      final dateA = a['match_date'] ?? '';
      final dateB = b['match_date'] ?? '';
      return dateA.compareTo(dateB);
    });
    
    // Group by date within round
    final groupedByDate = <String, List<dynamic>>{};
    for (var match in matches) {
      final date = match['match_date']?.split('T')[0] ?? 'unknown';
      groupedByDate.putIfAbsent(date, () => []).add(match);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round Header
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                roundName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${matches.length} trận',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Matches grouped by date
        ...groupedByDate.entries.map((entry) {
          // Group by group_name within date
          final matchesByGroup = <String, List<dynamic>>{};
          for (var match in entry.value) {
            final groupName = match['group_name'] ?? '';
            matchesByGroup.putIfAbsent(groupName, () => []).add(match);
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date sub-header
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      _formatMatchDate(entry.key),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              // Match cards grouped by group_name
              ...matchesByGroup.entries.map((groupEntry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (groupEntry.key.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: groupEntry.key == 'Bảng A' 
                                ? Colors.blue.withOpacity(0.1) 
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: groupEntry.key == 'Bảng A' 
                                  ? Colors.blue.withOpacity(0.3) 
                                  : Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            groupEntry.key,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: groupEntry.key == 'Bảng A' ? Colors.blue : Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ...groupEntry.value.map((match) => _buildCompactMatchCard(context, match)),
                  ],
                );
              }),
            ],
          );
        }),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCompactMatchCard(BuildContext context, dynamic match) {
    final homeTeam = match['home_team'] ?? {};
    final awayTeam = match['away_team'] ?? {};
    final status = match['status'] ?? 'scheduled';
    final isLive = status == 'live' || status == '1st_half' || status == '2nd_half';
    final isFinished = status == 'finished';
    
    // Kiểm tra xem đội đã được xác định chưa (TBD)
    final homeTeamId = match['home_team_id'];
    final awayTeamId = match['away_team_id'];
    final isTeamTBD = homeTeamId == null || awayTeamId == null;

    Color statusColor = AppTheme.scheduled;
    if (isLive) statusColor = AppTheme.live;
    if (isFinished) statusColor = AppTheme.finished;
    if (isTeamTBD) statusColor = Colors.grey; // Màu xám cho trận chưa xác định đội

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isLive ? 3 : 1,
      shadowColor: isLive ? AppTheme.live.withOpacity(0.5) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLive ? AppTheme.live : (isTeamTBD ? Colors.grey.withOpacity(0.3) : Colors.transparent),
          width: isLive ? 2 : (isTeamTBD ? 1 : 0),
        ),
      ),
      child: InkWell(
        onTap: isTeamTBD 
          ? null // Khóa không cho nhấn nếu đội chưa xác định
          : () {
              if (match['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchDetailScreen(matchId: match['id']),
                  ),
                );
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isTeamTBD ? 0.6 : 1.0, // Làm mờ nếu đội chưa xác định
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Home Team
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          homeTeam['short_name'] ?? homeTeam['name'] ?? 'TBD',
                          style: TextStyle(
                            fontWeight: isFinished && (match['home_score'] ?? 0) > (match['away_score'] ?? 0) 
                              ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                            fontStyle: isTeamTBD ? FontStyle.italic : FontStyle.normal,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSmallTeamLogo(homeTeam['logo'], homeTeam['name'] ?? 'TBD'),
                    ],
                  ),
                ),
                
                // Score / Time
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.live,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              match['minute'] != null ? "${match['minute']}'" : 'LIVE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      isFinished || isLive
                          ? '${match['home_score'] ?? 0} - ${match['away_score'] ?? 0}'
                          : _formatMatchTime(match['match_date']),
                      style: TextStyle(
                        fontSize: isFinished || isLive ? 18 : 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    if (!isLive && !isFinished && !isTeamTBD)
                      Text(
                        'Sắp diễn ra',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                        ),
                      ),
                    if (isTeamTBD)
                      Text(
                        'Chờ xác định',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (isFinished)
                      Text(
                        'Kết thúc',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Away Team
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildSmallTeamLogo(awayTeam['logo'], awayTeam['name'] ?? 'TBD'),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        awayTeam['short_name'] ?? awayTeam['name'] ?? 'TBD',
                        style: TextStyle(
                          fontWeight: isFinished && (match['away_score'] ?? 0) > (match['home_score'] ?? 0) 
                            ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                          fontStyle: isTeamTBD ? FontStyle.italic : FontStyle.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildSmallTeamLogo(String? logoUrl, String? teamName) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: logoUrl != null && logoUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoUrl.startsWith('http') ? logoUrl : 'http://127.0.0.1:8000$logoUrl',
                fit: BoxFit.contain,
                placeholder: (_, __) => _buildTeamInitial(teamName),
                errorWidget: (_, __, ___) => _buildTeamInitial(teamName),
              )
            : _buildTeamInitial(teamName),
      ),
    );
  }

  Widget _buildTeamInitial(String? name) {
    return Center(
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
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

  String _getRoundTypeLabel(String? roundType) {
    switch (roundType) {
      case 'round_robin':
        return 'Vòng tròn';
      case 'group_stage':
        return 'Vòng bảng';
      case 'knockout':
        return 'Loại trực tiếp';
      case 'league':
        return 'Giải vô địch';
      case 'mixed':
        return 'Kết hợp (Bảng + Loại)';
      default:
        return 'Vòng tròn';
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
