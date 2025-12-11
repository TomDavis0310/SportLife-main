import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/match_scheduling_provider.dart';
import '../../data/models/scheduling_models.dart';

class MatchSchedulingScreen extends ConsumerStatefulWidget {
  const MatchSchedulingScreen({super.key});

  @override
  ConsumerState<MatchSchedulingScreen> createState() => _MatchSchedulingScreenState();
}

class _MatchSchedulingScreenState extends ConsumerState<MatchSchedulingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final seasonsAsync = ref.watch(schedulingSeasonsProvider);
    final selectedSeasonId = ref.watch(selectedSchedulingSeasonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xep lich thi dau'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tu dong', icon: Icon(Icons.auto_fix_high)),
            Tab(text: 'Thu cong', icon: Icon(Icons.edit_calendar)),
          ],
        ),
        actions: [
          if (selectedSeasonId != null)
            IconButton(
              icon: const Icon(Icons.warning_amber_outlined),
              tooltip: 'Kiem tra xung dot',
              onPressed: () => _checkConflicts(selectedSeasonId),
            ),
        ],
      ),
      body: Column(
        children: [
          // Season selector
          seasonsAsync.when(
            data: (seasons) => _buildSeasonSelector(seasons),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Loi: $e', style: const TextStyle(color: Colors.red)),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AutoScheduleTab(seasonId: selectedSeasonId),
                _ManualScheduleTab(seasonId: selectedSeasonId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector(List<SchedulingSeason> seasons) {
    final selectedId = ref.watch(selectedSchedulingSeasonProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final season = seasons[index];
          final isSelected = selectedId == season.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: ChoiceChip(
              label: Text(season.name),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedSchedulingSeasonProvider.notifier).state = season.id;
                ref.read(selectedSchedulingRoundProvider.notifier).state = null;
              },
              avatar: season.isCurrent
                  ? const Icon(Icons.star, size: 16, color: Colors.amber)
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _checkConflicts(int seasonId) async {
    final conflicts = await ref.read(schedulingConflictsProvider(seasonId).future);
    
    if (!mounted) return;
    
    if (conflicts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khong co xung dot lich'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xung dot lich'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: conflicts.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(conflicts[i].description),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dong'),
            ),
          ],
        ),
      );
    }
  }
}

class _AutoScheduleTab extends ConsumerStatefulWidget {
  final int? seasonId;

  const _AutoScheduleTab({this.seasonId});

  @override
  ConsumerState<_AutoScheduleTab> createState() => _AutoScheduleTabState();
}

class _AutoScheduleTabState extends ConsumerState<_AutoScheduleTab> {
  String _scheduleType = 'home_away';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _timeSlots = ['15:00', '17:30', '19:00', '21:00'];
  final List<int> _matchDays = [0, 6]; // Sunday, Saturday
  int _matchesPerDay = 4;
  bool _clearExisting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.seasonId == null) {
      return const Center(
        child: Text('Vui long chon mua giai'),
      );
    }

    final previewState = ref.watch(schedulePreviewProvider);
    final generationState = ref.watch(scheduleGenerationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule type selection
          _buildSectionTitle('Loai lich thi dau'),
          _buildScheduleTypeSelector(),
          const SizedBox(height: 16),

          // Start date
          _buildSectionTitle('Ngay bat dau'),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectStartDate,
          ),
          const SizedBox(height: 16),

          // Match days
          _buildSectionTitle('Ngay thi dau trong tuan'),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < 7; i++)
                FilterChip(
                  label: Text(_getDayName(i)),
                  selected: _matchDays.contains(i),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _matchDays.add(i);
                      } else {
                        _matchDays.remove(i);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Matches per day
          _buildSectionTitle('So tran moi ngay: $_matchesPerDay'),
          Slider(
            value: _matchesPerDay.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_matchesPerDay',
            onChanged: (value) => setState(() => _matchesPerDay = value.toInt()),
          ),
          const SizedBox(height: 16),

          // Clear existing
          SwitchListTile(
            title: const Text('Xoa lich hien tai truoc khi tao'),
            value: _clearExisting,
            onChanged: (value) => setState(() => _clearExisting = value),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: previewState.isLoading ? null : _previewSchedule,
                  icon: previewState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.preview),
                  label: const Text('Xem truoc'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: generationState.isGenerating ? null : _generateSchedule,
                  icon: generationState.isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_fix_high),
                  label: const Text('Tao lich'),
                ),
              ),
            ],
          ),

          // Preview result
          if (previewState.preview != null) ...[
            const SizedBox(height: 24),
            _buildPreviewResult(previewState.preview!),
          ],

          // Generation result
          if (generationState.success) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(generationState.message ?? 'Thanh cong')),
                  ],
                ),
              ),
            ),
          ],

          if (previewState.error != null || generationState.error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(previewState.error ?? generationState.error ?? '')),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildScheduleTypeSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Vong tron 2 luot (san nha - san khach)'),
          subtitle: const Text('Moi doi dau voi doi khac 2 tran'),
          value: 'home_away',
          groupValue: _scheduleType,
          onChanged: (value) => setState(() => _scheduleType = value!),
        ),
        RadioListTile<String>(
          title: const Text('Vong tron 1 luot'),
          subtitle: const Text('Moi doi dau voi doi khac 1 tran'),
          value: 'round_robin',
          groupValue: _scheduleType,
          onChanged: (value) => setState(() => _scheduleType = value!),
        ),
        RadioListTile<String>(
          title: const Text('Loai truc tiep (Knockout)'),
          subtitle: const Text('Doi thua bi loai'),
          value: 'single_elimination',
          groupValue: _scheduleType,
          onChanged: (value) => setState(() => _scheduleType = value!),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[day];
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

  void _previewSchedule() {
    if (widget.seasonId == null) return;
    
    ref.read(schedulePreviewProvider.notifier).previewSchedule(
      seasonId: widget.seasonId!,
      type: _scheduleType,
      startDate: '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
      timeSlots: _timeSlots,
      matchDays: _matchDays,
      matchesPerDay: _matchesPerDay,
    );
  }

  void _generateSchedule() async {
    if (widget.seasonId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan'),
        content: Text(_clearExisting
            ? 'Ban co chac muon xoa lich cu va tao lich moi?'
            : 'Ban co chac muon tao lich thi dau?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dong y'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref.read(scheduleGenerationProvider.notifier).generateSchedule(
      seasonId: widget.seasonId!,
      type: _scheduleType,
      startDate: '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
      timeSlots: _timeSlots,
      matchDays: _matchDays,
      matchesPerDay: _matchesPerDay,
      clearExisting: _clearExisting,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Da tao lich thi dau thanh cong'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPreviewResult(SchedulePreview preview) {
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
                  'Xem truoc lich',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('${preview.totalRounds} vong - ${preview.totalMatches} tran'),
              ],
            ),
            const Divider(),
            ...preview.schedule.take(3).map((round) => ExpansionTile(
              title: Text(round.name),
              subtitle: Text('${round.matches.length} tran'),
              children: round.matches.map((match) => ListTile(
                dense: true,
                title: Text('${match.homeTeamName} vs ${match.awayTeamName}'),
                subtitle: Text(match.matchDateFormatted ?? ''),
                trailing: Text(match.venue ?? ''),
              )).toList(),
            )),
            if (preview.schedule.length > 3)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '... va ${preview.schedule.length - 3} vong khac',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ManualScheduleTab extends ConsumerStatefulWidget {
  final int? seasonId;

  const _ManualScheduleTab({this.seasonId});

  @override
  ConsumerState<_ManualScheduleTab> createState() => _ManualScheduleTabState();
}

class _ManualScheduleTabState extends ConsumerState<_ManualScheduleTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.seasonId == null) {
      return const Center(
        child: Text('Vui long chon mua giai'),
      );
    }

    final roundsAsync = ref.watch(schedulingRoundsProvider(widget.seasonId!));
    final selectedRoundId = ref.watch(selectedSchedulingRoundProvider);

    return Column(
      children: [
        // Round selector
        roundsAsync.when(
          data: (rounds) => _buildRoundSelector(rounds),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Loi: $e'),
          ),
        ),

        // Matches list
        if (selectedRoundId != null)
          Expanded(
            child: _buildMatchesList(selectedRoundId),
          )
        else
          const Expanded(
            child: Center(child: Text('Chon vong dau de xem tran')),
          ),
      ],
    );
  }

  Widget _buildRoundSelector(List<SchedulingRound> rounds) {
    final selectedId = ref.watch(selectedSchedulingRoundProvider);

    if (rounds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Chua co vong dau. Su dung tab "Tu dong" de tao.'),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rounds.length,
        itemBuilder: (context, index) {
          final round = rounds[index];
          final isSelected = selectedId == round.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: ChoiceChip(
              label: Text('${round.name} (${round.matchesCount})'),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedSchedulingRoundProvider.notifier).state = round.id;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchesList(int roundId) {
    final matchesAsync = ref.watch(roundMatchesProvider(roundId));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('Chua co tran dau'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(match);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Loi: $e')),
    );
  }

  Widget _buildMatchCard(SchedulingMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: match.homeTeam.logo != null
                            ? NetworkImage(match.homeTeam.logo!)
                            : null,
                        child: match.homeTeam.logo == null
                            ? const Icon(Icons.sports_soccer)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.homeTeam.shortName ?? match.homeTeam.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (match.isFinished)
                        Text(
                          '${match.homeScore} - ${match.awayScore}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'vs',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        match.matchDateFormatted ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: match.awayTeam.logo != null
                            ? NetworkImage(match.awayTeam.logo!)
                            : null,
                        child: match.awayTeam.logo == null
                            ? const Icon(Icons.sports_soccer)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.awayTeam.shortName ?? match.awayTeam.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (match.venue != null) ...[
              const SizedBox(height: 8),
              Text(
                match.venue!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: match.isScheduled ? () => _rescheduleMatch(match) : null,
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Doi lich'),
                ),
                TextButton.icon(
                  onPressed: match.isScheduled ? () => _swapTeams(match) : null,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Doi san'),
                ),
                TextButton.icon(
                  onPressed: match.isScheduled ? () => _deleteMatch(match) : null,
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text('Xoa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _rescheduleMatch(SchedulingMatch match) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (time == null || !mounted) return;

    final newDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final dateStr = newDate.toIso8601String();

    try {
      final api = ref.read(matchSchedulingApiProvider);
      await api.rescheduleMatch(match.id, dateStr);
      
      // Refresh
      final roundId = ref.read(selectedSchedulingRoundProvider);
      if (roundId != null) {
        ref.invalidate(roundMatchesProvider(roundId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da doi lich thanh cong')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _swapTeams(SchedulingMatch match) async {
    try {
      final api = ref.read(matchSchedulingApiProvider);
      await api.swapTeams(match.id);
      
      // Refresh
      final roundId = ref.read(selectedSchedulingRoundProvider);
      if (roundId != null) {
        ref.invalidate(roundMatchesProvider(roundId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da doi san thanh cong')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteMatch(SchedulingMatch match) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan'),
        content: Text('Xoa tran ${match.homeTeam.name} vs ${match.awayTeam.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final api = ref.read(matchSchedulingApiProvider);
      await api.deleteMatch(match.id);
      
      // Refresh
      final roundId = ref.read(selectedSchedulingRoundProvider);
      if (roundId != null) {
        ref.invalidate(roundMatchesProvider(roundId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da xoa tran dau')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
