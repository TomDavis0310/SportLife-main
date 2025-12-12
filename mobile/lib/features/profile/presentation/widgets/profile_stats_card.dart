import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user.dart';

class ProfileStatsCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const ProfileStatsCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getColors(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMainStat(
                  icon: Icons.stars,
                  value: '${user.totalPoints}',
                  label: 'Tổng điểm',
                  color: AppTheme.primary,
                ),
                _buildVerticalDivider(),
                _buildMainStat(
                  icon: Icons.sports_soccer,
                  value: '${user.predictionsCount}',
                  label: 'Dự đoán',
                  color: AppTheme.secondary,
                ),
                _buildVerticalDivider(),
                _buildMainStat(
                  icon: Icons.local_fire_department,
                  value: '${user.currentStreak}',
                  label: 'Streak',
                  color: AppTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Accuracy bar
            _buildAccuracyBar(user.accuracy),
            const SizedBox(height: 16),
            // Additional stats
            Row(
              children: [
                Expanded(
                  child: _buildSmallStat(
                    icon: Icons.check_circle,
                    value: '${user.correctPredictions}',
                    label: 'Dự đoán đúng',
                    color: AppTheme.success,
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    icon: Icons.check_circle,
                    value: '${user.exactPredictions}',
                    label: 'Chính xác',
                    color: AppTheme.info,
                  ),
                ),
                Expanded(
                  child: _buildSmallStat(
                    icon: Icons.trending_up,
                    value: '${user.bestStreak}',
                    label: 'Streak cao nhất',
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // View details button
            if (onTap != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem chi tiết thống kê',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Builder(
          builder: (context) {
            final colors = AppTheme.getColors(context);
            return Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Builder(
      builder: (context) {
        final colors = AppTheme.getColors(context);
        return Container(
          height: 60,
          width: 1,
          color: colors.divider,
        );
      },
    );
  }

  Widget _buildAccuracyBar(double accuracy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tỉ lệ chính xác',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getAccuracyColor(accuracy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final colors = AppTheme.getColors(context);
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                minHeight: 10,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getAccuracyColor(accuracy),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 70) return AppTheme.success;
    if (accuracy >= 50) return AppTheme.warning;
    return AppTheme.accent;
  }

  Widget _buildSmallStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final colors = AppTheme.getColors(context);
            return Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }
}
