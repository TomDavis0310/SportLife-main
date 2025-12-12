import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/api/tournament_api.dart';
import '../../data/models/tournament_models.dart';

class TournamentScheduleScreen extends ConsumerStatefulWidget {
  final int seasonId;
  final String seasonName;

  const TournamentScheduleScreen({
    super.key,
    required this.seasonId,
    required this.seasonName,
  });

  @override
  ConsumerState<TournamentScheduleScreen> createState() => _TournamentScheduleScreenState();
}

class _TournamentScheduleScreenState extends ConsumerState<TournamentScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String _scheduleType = 'home_away';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _timeSlots = ['15:00', '17:30', '19:00', '21:00'];
  final List<int> _matchDays = [0, 6]; // Sunday, Saturday
  int _matchesPerDay = 4;
  bool _isGenerating = false;
  bool _clearExisting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch thi đấu - ${widget.seasonName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tạo tự động', icon: Icon(Icons.auto_fix_high)),
            Tab(text: 'Xem lịch', icon: Icon(Icons.calendar_view_day)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAutoScheduleTab(),
          _buildViewScheduleTab(),
        ],
      ),
    );
  }

  Widget _buildAutoScheduleTab() {
    final previewState = ref.watch(schedulePreviewNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule type
          const Text(
            'Loại lịch thi đấu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Vòng tròn 2 lượt'),
                selected: _scheduleType == 'home_away',
                onSelected: (selected) {
                  if (selected) setState(() => _scheduleType = 'home_away');
                },
              ),
              ChoiceChip(
                label: const Text('Vòng tròn 1 lượt'),
                selected: _scheduleType == 'round_robin',
                onSelected: (selected) {
                  if (selected) setState(() => _scheduleType = 'round_robin');
                },
              ),
              ChoiceChip(
                label: const Text('Loại trực tiếp'),
                selected: _scheduleType == 'single_elimination',
                onSelected: (selected) {
                  if (selected) setState(() => _scheduleType = 'single_elimination');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start date
          const Text(
            'Ngày bắt đầu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
            trailing: const Icon(Icons.edit),
            onTap: _selectStartDate,
          ),
          const SizedBox(height: 16),

          // Matches per day
          const Text(
            'Số trận mỗi ngày',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _matchesPerDay.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_matchesPerDay trận',
            onChanged: (value) {
              setState(() => _matchesPerDay = value.toInt());
            },
          ),
          const SizedBox(height: 16),

          // Match days
          const Text(
            'Ngày thi đấu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDayChip(0, 'CN'),
              _buildDayChip(1, 'T2'),
              _buildDayChip(2, 'T3'),
              _buildDayChip(3, 'T4'),
              _buildDayChip(4, 'T5'),
              _buildDayChip(5, 'T6'),
              _buildDayChip(6, 'T7'),
            ],
          ),
          const SizedBox(height: 16),

          // Clear existing
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Xóa lịch cũ (nếu có)'),
            value: _clearExisting,
            onChanged: (value) {
              setState(() => _clearExisting = value ?? false);
            },
          ),
          const SizedBox(height: 24),

          // Preview button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: previewState.isLoading ? null : _previewSchedule,
              icon: previewState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.preview),
              label: const Text('Xem trước lịch'),
            ),
          ),
          const SizedBox(height: 12),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateSchedule,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_fix_high),
              label: const Text('Tạo lịch thi đấu'),
            ),
          ),
          const SizedBox(height: 24),

          // Preview result
          if (previewState.data != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xem trước',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Tổng số vòng: ${previewState.data!.totalRounds}'),
                    Text('Tổng số trận: ${previewState.data!.totalMatches}'),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...previewState.data!.schedule.take(3).map((round) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            round.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${round.matches.length} trận',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                    if (previewState.data!.schedule.length > 3)
                      Text(
                        '... và ${previewState.data!.schedule.length - 3} vòng khác',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
            ),
          ],

          if (previewState.error != null) ...[
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        previewState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _matchDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _matchDays.add(day);
          } else {
            _matchDays.remove(day);
          }
        });
      },
    );
  }

  Widget _buildViewScheduleTab() {
    final scheduleAsync = ref.watch(tournamentScheduleProvider(widget.seasonId));

    return scheduleAsync.when(
      data: (rounds) {
        if (rounds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có lịch thi đấu',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sử dụng tab "Tạo tự động" để tạo lịch',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tournamentScheduleProvider(widget.seasonId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rounds.length,
            itemBuilder: (context, index) {
              final round = rounds[index];
              return _RoundCard(
                round: round,
                seasonId: widget.seasonId,
                onMatchUpdated: () {
                  ref.invalidate(tournamentScheduleProvider(widget.seasonId));
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(tournamentScheduleProvider(widget.seasonId)),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _previewSchedule() async {
    await ref.read(schedulePreviewNotifierProvider.notifier).previewSchedule(
      seasonId: widget.seasonId,
      type: _scheduleType,
      startDate: _startDate.toIso8601String().split('T')[0],
      timeSlots: _timeSlots,
      matchDays: _matchDays,
      matchesPerDay: _matchesPerDay,
    );
  }

  Future<void> _generateSchedule() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn tạo lịch thi đấu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isGenerating = true);

    try {
      final api = TournamentApi(ref.read(dioProvider));
      await api.generateSchedule(
        seasonId: widget.seasonId,
        type: _scheduleType,
        startDate: _startDate.toIso8601String().split('T')[0],
        timeSlots: _timeSlots,
        matchDays: _matchDays,
        matchesPerDay: _matchesPerDay,
        clearExisting: _clearExisting,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo lịch thi đấu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(tournamentScheduleProvider(widget.seasonId));
        _tabController.animateTo(1); // Switch to view tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _RoundCard extends StatelessWidget {
  final TournamentRound round;
  final int seasonId;
  final VoidCallback onMatchUpdated;

  const _RoundCard({
    required this.round,
    required this.seasonId,
    required this.onMatchUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          round.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${round.matches.length} trận • ${round.startDate ?? 'Chưa xác định'}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        children: round.matches.map((match) => _MatchTile(
          match: match,
          seasonId: seasonId,
          onUpdated: onMatchUpdated,
        )).toList(),
      ),
    );
  }
}

class _MatchTile extends ConsumerWidget {
  final TournamentMatch match;
  final int seasonId;
  final VoidCallback onUpdated;

  const _MatchTile({
    required this.match,
    required this.seasonId,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Expanded(
            child: Text(
              match.homeTeam.shortName ?? match.homeTeam.name,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('vs', style: TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              match.awayTeam.shortName ?? match.awayTeam.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          match.matchDateFormatted ?? 'Chưa xác định',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: () => _editMatch(context, ref),
      ),
    );
  }

  Future<void> _editMatch(BuildContext context, WidgetRef ref) async {
    final dateController = TextEditingController(
      text: match.matchDate?.split(' ')[0] ?? '',
    );
    final venueController = TextEditingController(text: match.venue ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa trận đấu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${match.homeTeam.name} vs ${match.awayTeam.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Ngày giờ (YYYY-MM-DD HH:mm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(
                labelText: 'Địa điểm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        final api = TournamentApi(ref.read(dioProvider));
        await api.updateMatch(
          seasonId: seasonId,
          matchId: match.id,
          matchDate: dateController.text.isNotEmpty ? dateController.text : null,
          venue: venueController.text.isNotEmpty ? venueController.text : null,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật trận đấu'),
              backgroundColor: Colors.green,
            ),
          );
          onUpdated();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
