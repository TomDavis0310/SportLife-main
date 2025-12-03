import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';

class MatchStatsTab extends StatelessWidget {
  final Match match;

  const MatchStatsTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final stats = match.statistics;

    if (stats == null || stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có thống kê',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatRow(
          'Kiểm soát bóng',
          stats['possession_home'] ?? 50,
          stats['possession_away'] ?? 50,
          isPercentage: true,
        ),
        _buildStatRow(
          'Tổng số cú sút',
          stats['shots_home'] ?? 0,
          stats['shots_away'] ?? 0,
        ),
        _buildStatRow(
          'Sút trúng đích',
          stats['shots_on_target_home'] ?? 0,
          stats['shots_on_target_away'] ?? 0,
        ),
        _buildStatRow(
          'Số đường chuyền',
          stats['passes_home'] ?? 0,
          stats['passes_away'] ?? 0,
        ),
        _buildStatRow(
          'Chuyền chính xác %',
          stats['pass_accuracy_home'] ?? 0,
          stats['pass_accuracy_away'] ?? 0,
          isPercentage: true,
        ),
        _buildStatRow(
          'Phạm lỗi',
          stats['fouls_home'] ?? 0,
          stats['fouls_away'] ?? 0,
        ),
        _buildStatRow(
          'Thẻ vàng',
          stats['yellow_cards_home'] ?? 0,
          stats['yellow_cards_away'] ?? 0,
        ),
        _buildStatRow(
          'Thẻ đỏ',
          stats['red_cards_home'] ?? 0,
          stats['red_cards_away'] ?? 0,
        ),
        _buildStatRow(
          'Phạt góc',
          stats['corners_home'] ?? 0,
          stats['corners_away'] ?? 0,
        ),
        _buildStatRow(
          'Việt vị',
          stats['offsides_home'] ?? 0,
          stats['offsides_away'] ?? 0,
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    dynamic homeValue,
    dynamic awayValue, {
    bool isPercentage = false,
  }) {
    final homeNum = (homeValue is int)
        ? homeValue.toDouble()
        : (homeValue as num).toDouble();
    final awayNum = (awayValue is int)
        ? awayValue.toDouble()
        : (awayValue as num).toDouble();
    final total = homeNum + awayNum;
    final homePercent = total > 0 ? homeNum / total : 0.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPercentage ? '$homeValue%' : '$homeValue',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(label, style: TextStyle(color: Colors.grey[600])),
              Text(
                isPercentage ? '$awayValue%' : '$awayValue',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: (homePercent * 100).round(),
                  child: Container(height: 6, color: AppTheme.primary),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: ((1 - homePercent) * 100).round(),
                  child: Container(height: 6, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



