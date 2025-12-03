import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/prediction_provider.dart';
import '../../data/models/prediction.dart';

class PredictionsScreen extends ConsumerWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dự đoán của tôi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ kết quả'),
              Tab(text: 'Đã có KQ'),
              Tab(text: 'Tất cả'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPredictionList(context, ref, 'pending'),
            _buildPredictionList(context, ref, 'completed'),
            _buildPredictionList(context, ref, 'all'),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionList(BuildContext context, WidgetRef ref, String filter) {
    final predictionsAsync = ref.watch(myPredictionsProvider);

    return predictionsAsync.when(
      data: (predictions) {
        var filtered = predictions;
        if (filter == 'pending') {
          filtered = predictions.where((p) => p.pointsEarned == null).toList();
        } else if (filter == 'completed') {
          filtered = predictions.where((p) => p.pointsEarned != null).toList();
        }

        if (filtered.isEmpty) {
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
                  'Chưa có dự đoán nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/matches'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Dự đoán ngay'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myPredictionsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final prediction = filtered[index];
              return _buildPredictionCard(context, prediction);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
    );
  }

  Widget _buildPredictionCard(BuildContext context, Prediction prediction) {
    final match = prediction.match;
    final isPending = !prediction.isSettled;
    final isCorrect = prediction.isCorrect;
    final hasResult = match?.homeScore != null && match?.awayScore != null;
    final timeLabel = match?.matchTime != null
        ? _formatMatchTime(match!.matchTime)
        : prediction.createdAt ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isPending
            ? null
            : Border.all(
            color: isCorrect
              ? AppTheme.primary.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.5),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Competition & Venue
          if (match?.competitionName != null || match?.venue != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (match?.competitionName != null)
                    Text(
                      match!.competitionName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (match?.competitionName != null && match?.venue != null)
                    Text(
                      ' • ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  if (match?.venue != null)
                    Expanded(
                      child: Text(
                        match!.venue!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          // Match info
          Row(
            children: [
              Expanded(
                child: Text(
                  '${match?.homeTeam?.shortName ?? match?.homeTeam?.name ?? 'Home'} vs ${match?.awayTeam?.shortName ?? match?.awayTeam?.name ?? 'Away'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (isPending && match?.matchTime != null)
                    _PredictionCountdown(
                      matchTime: DateTime.parse(match!.matchTime),
                    ),
                ],
              ),
              if (!isPending)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCorrect
                        ? '+${prediction.pointsEarned ?? 0} điểm'
                        : '0 điểm',
                    style: TextStyle(
                      color: isCorrect ? AppTheme.primary : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Predictions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dự đoán',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${prediction.predictedHomeScore} - ${prediction.predictedAwayScore}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (prediction.streakMultiplier != null)
                      Text(
                        'Hệ số streak x${prediction.streakMultiplier?.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isPending || hasResult)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kết quả',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${match?.homeScore ?? '-'} - ${match?.awayScore ?? '-'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (prediction.firstScorer != null &&
              prediction.firstScorer!['name'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Người ghi bàn đầu: ${prediction.firstScorer!['name']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatMatchTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _PredictionCountdown extends StatefulWidget {
  final DateTime matchTime;

  const _PredictionCountdown({super.key, required this.matchTime});

  @override
  State<_PredictionCountdown> createState() => _PredictionCountdownState();
}

class _PredictionCountdownState extends State<_PredictionCountdown> {
  late Timer _timer;
  late Duration _timeLeft;
  late DateTime _resultTime;

  @override
  void initState() {
    super.initState();
    // Assume result is available 2 hours after match start
    _resultTime = widget.matchTime.add(const Duration(hours: 2));
    _calculateTimeLeft();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _calculateTimeLeft(),
    );
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = _resultTime.difference(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) {
      return const Text(
        'Đang cập nhật KQ...',
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;

    String timeStr = '';
    if (days > 0) {
      timeStr = '${days}d ${hours}h';
    } else if (hours > 0) {
      timeStr = '${hours}h ${minutes}p';
    } else {
      timeStr = '${minutes}p';
    }

    return Text(
      'KQ sau: $timeStr',
      style: const TextStyle(
        fontSize: 11,
        color: Colors.green,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}



