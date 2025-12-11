import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/api/tournament_api.dart';
import '../../data/models/tournament_models.dart';
import 'tournament_schedule_screen.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int seasonId;
  final String tournamentName;

  const TournamentDetailScreen({
    super.key,
    required this.seasonId,
    required this.tournamentName,
  });

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seasonDetailsAsync = ref.watch(tournamentSeasonDetailsProvider(widget.seasonId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournamentName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tournamentSeasonDetailsProvider(widget.seasonId)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan', icon: Icon(Icons.info_outline)),
            Tab(text: 'Đội tham gia', icon: Icon(Icons.groups)),
            Tab(text: 'Lịch thi đấu', icon: Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: seasonDetailsAsync.when(
        data: (season) => TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(season: season, onLockRegistration: _toggleRegistrationLock),
            _TeamsTab(
              season: season,
              onApprove: _approveTeam,
              onReject: _rejectTeam,
              isProcessing: _isProcessing,
            ),
            _ScheduleTab(season: season),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tournamentSeasonDetailsProvider(widget.seasonId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleRegistrationLock(TournamentSeason season) async {
    final api = TournamentApi(ref.read(dioProvider));
    
    try {
      setState(() => _isProcessing = true);
      
      if (season.registrationLocked) {
        await api.unlockRegistration(widget.seasonId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã mở lại đăng ký'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await api.lockRegistration(widget.seasonId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã khóa đăng ký. Bây giờ bạn có thể tạo lịch thi đấu.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      ref.invalidate(tournamentSeasonDetailsProvider(widget.seasonId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _approveTeam(int teamId) async {
    final api = TournamentApi(ref.read(dioProvider));
    
    try {
      setState(() => _isProcessing = true);
      await api.approveRegistration(widget.seasonId, teamId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã phê duyệt đội'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      ref.invalidate(tournamentSeasonDetailsProvider(widget.seasonId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectTeam(int teamId) async {
    final api = TournamentApi(ref.read(dioProvider));
    
    try {
      setState(() => _isProcessing = true);
      await api.rejectRegistration(widget.seasonId, teamId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối đội'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      ref.invalidate(tournamentSeasonDetailsProvider(widget.seasonId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _OverviewTab extends StatelessWidget {
  final TournamentSeason season;
  final Function(TournamentSeason) onLockRegistration;

  const _OverviewTab({
    required this.season,
    required this.onLockRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registration status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        season.registrationLocked ? Icons.lock : Icons.lock_open,
                        color: season.registrationLocked ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        season.registrationLocked ? 'Đăng ký đã khóa' : 'Đăng ký đang mở',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: season.maxTeams > 0
                        ? season.approvedTeamsCount / season.maxTeams
                        : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      season.isRegistrationFull ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${season.approvedTeamsCount}/${season.maxTeams} đội đã được phê duyệt',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onLockRegistration(season),
                      icon: Icon(
                        season.registrationLocked ? Icons.lock_open : Icons.lock,
                      ),
                      label: Text(
                        season.registrationLocked
                            ? 'Mở lại đăng ký'
                            : 'Khóa đăng ký',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: season.registrationLocked
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Tổng đăng ký',
                  value: '${season.teamsCount}',
                  icon: Icons.groups,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Đã duyệt',
                  value: '${season.approvedTeamsCount}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Chờ duyệt',
                  value: '${season.pendingTeamsCount}',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Số đội tối đa',
                  value: '${season.maxTeams}',
                  icon: Icons.emoji_events,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Season info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin mùa giải',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Ngày bắt đầu',
                    value: season.startDate ?? 'Chưa xác định',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.event_available,
                    label: 'Ngày kết thúc',
                    value: season.endDate ?? 'Chưa xác định',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _TeamsTab extends StatelessWidget {
  final TournamentSeason season;
  final Function(int) onApprove;
  final Function(int) onReject;
  final bool isProcessing;

  const _TeamsTab({
    required this.season,
    required this.onApprove,
    required this.onReject,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTeams = season.teams.where((t) => t.isPending).toList();
    final approvedTeams = season.teams.where((t) => t.isApproved).toList();
    final rejectedTeams = season.teams.where((t) => t.isRejected).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Chờ duyệt (${pendingTeams.length})'),
              Tab(text: 'Đã duyệt (${approvedTeams.length})'),
              Tab(text: 'Từ chối (${rejectedTeams.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TeamsList(
                  teams: pendingTeams,
                  emptyMessage: 'Không có đội nào đang chờ duyệt',
                  showActions: !season.registrationLocked,
                  onApprove: onApprove,
                  onReject: onReject,
                  isProcessing: isProcessing,
                ),
                _TeamsList(
                  teams: approvedTeams,
                  emptyMessage: 'Chưa có đội nào được phê duyệt',
                  showActions: false,
                  onApprove: onApprove,
                  onReject: onReject,
                  isProcessing: isProcessing,
                ),
                _TeamsList(
                  teams: rejectedTeams,
                  emptyMessage: 'Không có đội nào bị từ chối',
                  showActions: false,
                  onApprove: onApprove,
                  onReject: onReject,
                  isProcessing: isProcessing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamsList extends StatelessWidget {
  final List<TournamentTeam> teams;
  final String emptyMessage;
  final bool showActions;
  final Function(int) onApprove;
  final Function(int) onReject;
  final bool isProcessing;

  const _TeamsList({
    required this.teams,
    required this.emptyMessage,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              backgroundImage: team.logo != null ? NetworkImage(team.logo!) : null,
              child: team.logo == null
                  ? Text(
                      team.shortName?.substring(0, 2) ?? team.name.substring(0, 2),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(team.name),
            subtitle: team.registeredAt != null
                ? Text('Đăng ký: ${team.registeredAt}', style: const TextStyle(fontSize: 12))
                : null,
            trailing: showActions
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: isProcessing ? null : () => onApprove(team.id),
                        tooltip: 'Phê duyệt',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: isProcessing ? null : () => onReject(team.id),
                        tooltip: 'Từ chối',
                      ),
                    ],
                  )
                : _buildStatusChip(team.status),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Đã duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.orange;
        text = 'Chờ duyệt';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final TournamentSeason season;

  const _ScheduleTab({required this.season});

  @override
  Widget build(BuildContext context) {
    if (!season.registrationLocked) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng khóa đăng ký trước khi tạo lịch thi đấu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đội đã duyệt: ${season.approvedTeamsCount}/${season.maxTeams}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Quản lý lịch thi đấu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${season.approvedTeamsCount} đội đã sẵn sàng',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TournamentScheduleScreen(
                    seasonId: season.id,
                    seasonName: season.name,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Xếp lịch thi đấu'),
          ),
        ],
      ),
    );
  }
}
