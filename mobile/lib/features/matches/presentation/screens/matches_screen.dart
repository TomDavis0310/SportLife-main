import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/match_provider.dart';
import '../../data/models/match.dart';
import '../widgets/match_list_item.dart';
import '../../../../core/widgets/auto_svg_image.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  late DateTime _startDate;
  late final ScrollController _dateScrollController;
  static const int _dateWindowDays = 30;
  static const double _dateItemExtent = 60;
  int? _selectedCompetitionId;

  final List<String> _tabs = [
    'Tất cả',
    'Đang diễn ra',
    'Sắp tới',
    'Đã kết thúc',
  ];

  final List<Map<String, dynamic>> _otherSportsMatches = const [
    {
      'sport': 'Bóng rổ',
      'league': 'NBA Regular Season',
      'home': 'Los Angeles Lakers',
      'away': 'Golden State Warriors',
      'score': '112 - 108',
      'status': 'live',
      'time': 'Q4 02:15',
      'stats': ['Rebound 42-38', '3PT 12-9', 'LeBron 28 điểm'],
      'icon': 'assets/icons/basketball.svg',
    },
    {
      'sport': 'Quần vợt',
      'league': 'ATP Finals',
      'home': 'N. Djokovic',
      'away': 'C. Alcaraz',
      'score': '7-6 3-6 6-4',
      'status': 'finished',
      'time': 'Kết thúc',
      'stats': ['Ace 14-11', 'Winner 32-28', 'Thời gian 2h18'],
      'icon': 'assets/icons/tennis.svg',
    },
    {
      'sport': 'Esports',
      'league': 'VCS Winter',
      'home': 'GAM Esports',
      'away': 'Team Flash',
      'score': '2 - 1',
      'status': 'upcoming',
      'time': '20:00 hôm nay',
      'stats': ['Bo3', 'Livestream: VETV7', 'MVP kỳ vọng: Levi'],
      'icon': 'assets/icons/esports.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _startDate = DateTime.now().subtract(
      const Duration(days: _dateWindowDays ~/ 2),
    );
    _dateScrollController = ScrollController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToDate(_selectedDate));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trận Đấu'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Date Selector
              _buildDateSelector(),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(null),
          _buildMatchList('live'),
          _buildMatchList('upcoming'),
          _buildMatchList('finished'),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _handleDateSelection(
              _selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _dateScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _dateWindowDays,
              itemBuilder: (context, index) {
                final date = _startDate.add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _handleDateSelection(date),
                    child: Container(
                      width: _dateItemExtent,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(color: AppTheme.primary)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E', 'vi').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                _handleDateSelection(_selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(String? status) {
    final matchesAsync = ref.watch(
      matchesByDateProvider(DateFormat('yyyy-MM-dd').format(_selectedDate)),
    );

    return matchesAsync.when(
      data: (matches) {
        // Filter by status
        List<Match> filteredMatches = matches;
        if (status != null) {
          filteredMatches = matches
              .where((match) => _matchStatusMatches(match, status))
              .toList();
        }

        // Filter by competition
        if (_selectedCompetitionId != null) {
          filteredMatches = filteredMatches
              .where((m) => m.competitionId == _selectedCompetitionId)
              .toList();
        }

        if (filteredMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có trận đấu nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Group by competition
        final groupedMatches = _groupMatchesByCompetition(filteredMatches);

        final includeOtherSports = status == null;
        final entries = groupedMatches.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length + (includeOtherSports ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < entries.length) {
              final entry = entries[index];
              return _buildCompetitionSection(entry.key, entry.value);
            }
            return _buildOtherSportsSection();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(matchesByDateProvider(
                  DateFormat('yyyy-MM-dd').format(_selectedDate))),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDateSelection(DateTime date) {
    setState(() {
      if (date.isBefore(_startDate.add(const Duration(days: 3)))) {
        _startDate = _startDate.subtract(const Duration(days: 7));
      } else if (date.isAfter(
          _startDate.add(const Duration(days: _dateWindowDays - 4)))) {
        _startDate = _startDate.add(const Duration(days: 7));
      }
      _selectedDate = date;
    });

    _refreshMatchesFor(date);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToDate(date));
  }

  void _refreshMatchesFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    ref.invalidate(matchesByDateProvider(key));
  }

  void _scrollToDate(DateTime date) {
    if (!_dateScrollController.hasClients) return;

    final index = date.difference(_startDate).inDays;
    if (index < 0 || index >= _dateWindowDays) return;

    const extentWithSpacing = _dateItemExtent + 8;
    final targetOffset = (index * extentWithSpacing) - (_dateItemExtent * 2);
    final maxScroll = _dateScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll).toDouble();

    _dateScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Map<String, List<Match>> _groupMatchesByCompetition(List<Match> matches) {
    final Map<String, List<Match>> grouped = {};
    for (final match in matches) {
      final competitionName =
          match.competitionName ?? match.competition?.name ?? 'Khác';
      grouped.putIfAbsent(competitionName, () => []).add(match);
    }
    return grouped;
  }

  Widget _buildCompetitionSection(String competitionName, List<Match> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  competitionName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...matches.map((match) => MatchListItem(match: match)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOtherSportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.sports, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Môn thể thao khác',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _otherSportsMatches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _OtherSportCard(data: _otherSportsMatches[index]);
            },
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    final competitions = ref.read(competitionsProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc theo giải đấu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tất cả giải đấu'),
                leading: Radio<int?>(
                  value: null,
                  groupValue: _selectedCompetitionId,
                  onChanged: (value) {
                    setState(() => _selectedCompetitionId = value);
                    Navigator.pop(context);
                  },
                ),
              ),
              competitions.when(
                data: (comps) => Column(
                  children: comps.map((comp) {
                    return ListTile(
                      title: Text(comp.name),
                      leading: Radio<int?>(
                        value: comp.id,
                        groupValue: _selectedCompetitionId,
                        onChanged: (value) {
                          setState(() => _selectedCompetitionId = value);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Lỗi tải giải đấu'),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _matchStatusMatches(Match match, String status) {
    switch (status) {
      case 'live':
        return match.isLive;
      case 'upcoming':
        return match.isScheduled || match.status == MatchStatus.postponed;
      case 'finished':
        return match.isFinished;
      default:
        return true;
    }
  }
}

class _OtherSportCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _OtherSportCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] as String).toLowerCase();
    final statusColor = status == 'live'
        ? AppTheme.live
        : status == 'upcoming'
            ? AppTheme.primary
            : Colors.grey;
    final stats = List<String>.from(data['stats'] as List);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoSvgImage(
                source: data['icon'] as String,
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['sport'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['league'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  data['time'] as String,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['score'] as String,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data['home']} vs ${data['away']}',
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ...stats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record,
                      size: 6, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      stat,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
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



