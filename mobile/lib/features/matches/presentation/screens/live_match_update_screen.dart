import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/match_provider.dart';
import '../../../../core/providers/live_match_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';

class LiveMatchUpdateScreen extends ConsumerStatefulWidget {
  final int matchId;

  const LiveMatchUpdateScreen({super.key, required this.matchId});

  @override
  ConsumerState<LiveMatchUpdateScreen> createState() =>
      _LiveMatchUpdateScreenState();
}

class _LiveMatchUpdateScreenState extends ConsumerState<LiveMatchUpdateScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật trận đấu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
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
    );
  }

  Widget _buildContent(Match match) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Score Header
          _buildScoreHeader(match),
          const SizedBox(height: 24),

          // Match Status Controls
          _buildStatusSection(match),
          const SizedBox(height: 24),

          // Add Event Section
          _buildEventSection(match),
          const SizedBox(height: 24),

          // Recent Events
          _buildRecentEvents(match),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(Match match) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      if (match.homeTeam?.logo != null)
                        Image.network(
                          match.homeTeam!.logo!,
                          width: 48,
                          height: 48,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.sports_soccer, size: 48),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam?.shortName ?? 'Home',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Score
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (match.minute != null && match.isLive)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${match.minute}'",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Away Team
                Expanded(
                  child: Column(
                    children: [
                      if (match.awayTeam?.logo != null)
                        Image.network(
                          match.awayTeam!.logo!,
                          width: 48,
                          height: 48,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.sports_soccer, size: 48),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam?.shortName ?? 'Away',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(match),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Match match) {
    Color color;
    String text;

    switch (match.status) {
      case MatchStatus.live:
        color = Colors.red;
        text = 'ĐANG DIỄN RA';
        break;
      case MatchStatus.halftime:
        color = Colors.orange;
        text = 'HIỆP 1 KẾT THÚC';
        break;
      case MatchStatus.finished:
        color = Colors.grey;
        text = 'KẾT THÚC';
        break;
      case MatchStatus.scheduled:
        color = Colors.blue;
        text = 'CHƯA BẮT ĐẦU';
        break;
      default:
        color = Colors.grey;
        text = match.status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusSection(Match match) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái trận đấu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (match.isScheduled)
                  _buildStatusButton(
                    'Bắt đầu trận',
                    Icons.play_arrow,
                    Colors.green,
                    () => _startMatch(match),
                  ),
                if (match.isLive && (match.minute ?? 0) < 45)
                  _buildStatusButton(
                    'Giữa hiệp',
                    Icons.pause,
                    Colors.orange,
                    () => _updateStatus(match, 'half_time'),
                  ),
                if (match.status == MatchStatus.halftime)
                  _buildStatusButton(
                    'Hiệp 2',
                    Icons.play_arrow,
                    Colors.green,
                    () => _updateStatus(match, 'second_half'),
                  ),
                if (match.isLive || match.status == MatchStatus.halftime)
                  _buildStatusButton(
                    'Kết thúc',
                    Icons.stop,
                    Colors.red,
                    () => _endMatch(match),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildEventSection(Match match) {
    if (!match.isLive && match.status != MatchStatus.halftime) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm sự kiện',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Goal buttons
            Row(
              children: [
                Expanded(
                  child: _buildEventButton(
                    'Bàn thắng\n${match.homeTeam?.shortName ?? "Home"}',
                    Icons.sports_soccer,
                    AppTheme.primary,
                    () => _showAddEventDialog(match, 'goal', 'home'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEventButton(
                    'Bàn thắng\n${match.awayTeam?.shortName ?? "Away"}',
                    Icons.sports_soccer,
                    AppTheme.secondary,
                    () => _showAddEventDialog(match, 'goal', 'away'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Card buttons
            Row(
              children: [
                Expanded(
                  child: _buildEventButton(
                    'Thẻ vàng',
                    Icons.square,
                    Colors.amber,
                    () => _showAddEventDialog(match, 'yellow_card', null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEventButton(
                    'Thẻ đỏ',
                    Icons.square,
                    Colors.red,
                    () => _showAddEventDialog(match, 'red_card', null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Other events
            Row(
              children: [
                Expanded(
                  child: _buildEventButton(
                    'Thay người',
                    Icons.swap_horiz,
                    Colors.blue,
                    () => _showAddEventDialog(match, 'substitution', null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEventButton(
                    'Phạt đền',
                    Icons.gps_fixed,
                    Colors.purple,
                    () => _showAddEventDialog(match, 'penalty', null),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEvents(Match match) {
    final events = match.events ?? [];

    if (events.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.event_note, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Chưa có sự kiện nào',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sự kiện gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(matchDetailProvider(widget.matchId)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length > 5 ? 5 : events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: _getEventIcon(event.eventType),
                  title: Text(event.playerName ?? event.eventType),
                  subtitle: Text("${event.minute}'"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteEvent(match, event.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEventIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'goal':
      case 'penalty':
        icon = Icons.sports_soccer;
        color = AppTheme.primary;
        break;
      case 'yellow_card':
        icon = Icons.square;
        color = Colors.amber;
        break;
      case 'red_card':
        icon = Icons.square;
        color = Colors.red;
        break;
      case 'substitution':
        icon = Icons.swap_horiz;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Future<void> _showAddEventDialog(
      Match match, String eventType, String? teamSide) async {
    int minute = match.minute ?? 0;
    String? selectedTeamSide = teamSide;
    String description = '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(_getEventTitle(eventType)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minute input
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Phút',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: minute.toString()),
                  onChanged: (value) => minute = int.tryParse(value) ?? minute,
                ),
                const SizedBox(height: 16),

                // Team selection (if not pre-selected)
                if (selectedTeamSide == null) ...[
                  const Text('Chọn đội:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(match.homeTeam?.shortName ?? 'Home'),
                          selected: selectedTeamSide == 'home',
                          onSelected: (selected) {
                            setState(() => selectedTeamSide = 'home');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(match.awayTeam?.shortName ?? 'Away'),
                          selected: selectedTeamSide == 'away',
                          onSelected: (selected) {
                            setState(() => selectedTeamSide = 'away');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedTeamSide != null || teamSide != null
                  ? () {
                      Navigator.pop(context, {
                        'minute': minute,
                        'team_side': selectedTeamSide ?? teamSide,
                        'description': description,
                      });
                    }
                  : null,
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _addEvent(match, eventType, result);
    }
  }

  String _getEventTitle(String type) {
    switch (type) {
      case 'goal':
        return 'Thêm bàn thắng';
      case 'penalty':
        return 'Thêm phạt đền';
      case 'yellow_card':
        return 'Thêm thẻ vàng';
      case 'red_card':
        return 'Thêm thẻ đỏ';
      case 'substitution':
        return 'Thay người';
      default:
        return 'Thêm sự kiện';
    }
  }

  Future<void> _startMatch(Match match) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(liveMatchApiProvider).startMatch(match.id);
      ref.invalidate(matchDetailProvider(widget.matchId));
      _showSuccess('Trận đấu đã bắt đầu!');
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(Match match, String status) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(liveMatchApiProvider).updateStatus(match.id, status);
      ref.invalidate(matchDetailProvider(widget.matchId));
      _showSuccess('Đã cập nhật trạng thái');
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _endMatch(Match match) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc trận đấu?'),
        content: Text(
          'Tỷ số cuối cùng: ${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(liveMatchApiProvider).endMatch(match.id);
      ref.invalidate(matchDetailProvider(widget.matchId));
      _showSuccess('Trận đấu đã kết thúc');
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEvent(
      Match match, String eventType, Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      final teamId =
          data['team_side'] == 'home' ? match.homeTeamId : match.awayTeamId;

      await ref.read(liveMatchApiProvider).addEvent(
            match.id,
            eventType: eventType,
            minute: data['minute'],
            teamId: teamId!,
            description: data['description'],
          );
      ref.invalidate(matchDetailProvider(widget.matchId));
      _showSuccess('Đã thêm sự kiện');
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent(Match match, int eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sự kiện?'),
        content: const Text('Bạn có chắc muốn xóa sự kiện này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(liveMatchApiProvider).deleteEvent(match.id, eventId);
      ref.invalidate(matchDetailProvider(widget.matchId));
      _showSuccess('Đã xóa sự kiện');
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
