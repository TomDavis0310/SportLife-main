import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/data/models/user.dart';

class ProfileStatisticsScreen extends ConsumerWidget {
  const ProfileStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thống kê')),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem thống kê'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thống kê chi tiết'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            _buildOverviewCard(user),
            const SizedBox(height: 20),

            // Accuracy Chart
            _buildSectionTitle('Biểu đồ độ chính xác'),
            const SizedBox(height: 12),
            _buildAccuracyChart(user),
            const SizedBox(height: 24),

            // Predictions Breakdown
            _buildSectionTitle('Phân tích dự đoán'),
            const SizedBox(height: 12),
            _buildPredictionsBreakdown(user),
            const SizedBox(height: 24),

            // Streak History
            _buildSectionTitle('Lịch sử Streak'),
            const SizedBox(height: 12),
            _buildStreakHistory(user),
            const SizedBox(height: 24),

            // Points History
            _buildSectionTitle('Biểu đồ điểm số'),
            const SizedBox(height: 12),
            _buildPointsChart(),
            const SizedBox(height: 24),

            // Achievements Progress
            _buildSectionTitle('Tiến trình thành tích'),
            const SizedBox(height: 12),
            _buildAchievementsProgress(user),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildOverviewCard(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat(
                value: '${user.totalPoints}',
                label: 'Tổng điểm',
                icon: Icons.stars,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white30,
              ),
              _buildOverviewStat(
                value: '${user.predictionsCount}',
                label: 'Dự đoán',
                icon: Icons.sports_soccer,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white30,
              ),
              _buildOverviewStat(
                value: '${user.accuracy.toStringAsFixed(1)}%',
                label: 'Chính xác',
                icon: Icons.analytics,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orangeAccent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Streak hiện tại: ${user.currentStreak} ngày',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  Widget _buildOverviewStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyChart(User user) {
    final correct = user.correctPredictions.toDouble();
    final exact = user.exactPredictions.toDouble();
    final total = user.predictionsCount.toDouble();
    final incorrect = total - correct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: exact,
                          title: '${((exact / total) * 100).toStringAsFixed(0)}%',
                          color: AppTheme.success,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        PieChartSectionData(
                          value: correct - exact,
                          title: '${(((correct - exact) / total) * 100).toStringAsFixed(0)}%',
                          color: AppTheme.info,
                          radius: 55,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        PieChartSectionData(
                          value: incorrect,
                          title: '${((incorrect / total) * 100).toStringAsFixed(0)}%',
                          color: AppTheme.grey,
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text('Chưa có dữ liệu dự đoán'),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Chính xác tuyệt đối', AppTheme.success),
              _buildLegendItem('Đúng kết quả', AppTheme.info),
              _buildLegendItem('Sai', AppTheme.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsBreakdown(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBreakdownRow(
            icon: Icons.sports_soccer,
            label: 'Tổng dự đoán',
            value: '${user.predictionsCount}',
            color: AppTheme.primary,
          ),
          const Divider(height: 24),
          _buildBreakdownRow(
            icon: Icons.check_circle,
            label: 'Dự đoán đúng',
            value: '${user.correctPredictions}',
            color: AppTheme.success,
          ),
          const Divider(height: 24),
          _buildBreakdownRow(
            icon: Icons.star,
            label: 'Chính xác tuyệt đối',
            value: '${user.exactPredictions}',
            color: AppTheme.warning,
          ),
          const Divider(height: 24),
          _buildBreakdownRow(
            icon: Icons.cancel,
            label: 'Dự đoán sai',
            value: '${user.predictionsCount - user.correctPredictions}',
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakHistory(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakStat(
                label: 'Streak hiện tại',
                value: user.currentStreak,
                icon: Icons.local_fire_department,
                color: AppTheme.accent,
              ),
              Container(
                width: 1,
                height: 60,
                color: AppTheme.lightGrey,
              ),
              _buildStreakStat(
                label: 'Streak cao nhất',
                value: user.bestStreak,
                icon: Icons.emoji_events,
                color: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weekly streak visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isActive = index < user.currentStreak % 7;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive 
                          ? AppTheme.accent 
                          : AppTheme.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive 
                          ? Icons.local_fire_department 
                          : Icons.circle_outlined,
                      color: isActive ? Colors.white : AppTheme.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? AppTheme.accent : AppTheme.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value ngày',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsChart() {
    // Sample data for points over time
    final spots = [
      const FlSpot(0, 100),
      const FlSpot(1, 250),
      const FlSpot(2, 180),
      const FlSpot(3, 420),
      const FlSpot(4, 350),
      const FlSpot(5, 520),
      const FlSpot(6, 650),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7 ngày gần nhất',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightGrey,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                        if (value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.darkGrey,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.darkGrey,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.1),
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

  Widget _buildAchievementsProgress(User user) {
    final achievements = [
      {
        'title': 'Người mới bắt đầu',
        'description': 'Hoàn thành 10 dự đoán',
        'current': user.predictionsCount,
        'total': 10,
        'icon': Icons.star_border,
        'color': AppTheme.info,
      },
      {
        'title': 'Dự đoán viên',
        'description': 'Hoàn thành 50 dự đoán',
        'current': user.predictionsCount,
        'total': 50,
        'icon': Icons.star_half,
        'color': AppTheme.warning,
      },
      {
        'title': 'Chuyên gia',
        'description': 'Hoàn thành 100 dự đoán',
        'current': user.predictionsCount,
        'total': 100,
        'icon': Icons.star,
        'color': AppTheme.accent,
      },
      {
        'title': 'Streak Master',
        'description': 'Đạt streak 7 ngày',
        'current': user.bestStreak,
        'total': 7,
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'Nhà tiên tri',
        'description': '50 dự đoán chính xác',
        'current': user.exactPredictions,
        'total': 50,
        'icon': Icons.visibility,
        'color': AppTheme.secondary,
      },
    ];

    return Column(
      children: achievements.map((achievement) {
        final current = (achievement['current'] as int).clamp(0, achievement['total'] as int);
        final total = achievement['total'] as int;
        final progress = current / total;
        final isCompleted = current >= total;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted 
                  ? (achievement['color'] as Color).withOpacity(0.3) 
                  : AppTheme.lightGrey,
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withOpacity(
                    isCompleted ? 1 : 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: isCompleted 
                      ? Colors.white 
                      : achievement['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          achievement['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCompleted 
                                ? achievement['color'] as Color 
                                : AppTheme.black,
                          ),
                        ),
                        Text(
                          '$current / $total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isCompleted 
                                ? achievement['color'] as Color 
                                : AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppTheme.lightGrey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          achievement['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 28,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
