import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/achievement_badge.dart';

class ProfileProgressScreen extends ConsumerWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tiến trình')),
        body: const Center(
          child: Text('Vui lòng đăng nhập'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tiến trình của bạn'),
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
            // Level Progress
            _buildLevelCard(user.totalPoints),
            const SizedBox(height: 24),

            // Milestones
            _buildSectionTitle('Cột mốc'),
            const SizedBox(height: 12),
            _buildMilestones(user.totalPoints),
            const SizedBox(height: 24),

            // Achievements Progress
            _buildSectionTitle('Thành tích đang tiến hành'),
            const SizedBox(height: 12),
            _buildAchievementsInProgress(user.predictionsCount, user.currentStreak, user.exactPredictions),
            const SizedBox(height: 24),

            // Weekly Goals
            _buildSectionTitle('Mục tiêu tuần này'),
            const SizedBox(height: 12),
            _buildWeeklyGoals(),
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

  Widget _buildLevelCard(int totalPoints) {
    // Calculate level based on points
    int level = 1;
    int pointsForCurrentLevel = 0;
    int pointsForNextLevel = 100;

    final levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500];
    for (int i = 0; i < levelThresholds.length - 1; i++) {
      if (totalPoints >= levelThresholds[i]) {
        level = i + 1;
        pointsForCurrentLevel = levelThresholds[i];
        pointsForNextLevel = levelThresholds[i + 1];
      }
    }

    final pointsInLevel = totalPoints - pointsForCurrentLevel;
    final pointsNeeded = pointsForNextLevel - pointsForCurrentLevel;
    final progress = pointsInLevel / pointsNeeded;

    final levelTitles = [
      'Người mới',
      'Tập sự',
      'Có kinh nghiệm',
      'Thành thạo',
      'Chuyên gia',
      'Bậc thầy',
      'Huyền thoại',
      'Siêu sao',
      'Thần đoán',
      'Vô địch',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
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
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cấp độ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      levelTitles[level - 1],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPoints điểm',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cấp ${level + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$pointsInLevel / $pointsNeeded',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Còn ${pointsNeeded - pointsInLevel} điểm nữa để lên cấp',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(int totalPoints) {
    final milestones = [
      {'points': 100, 'title': 'Điểm đầu tiên 100', 'icon': Icons.flag},
      {'points': 500, 'title': 'Nửa nghìn điểm', 'icon': Icons.star_border},
      {'points': 1000, 'title': 'Nghìn điểm', 'icon': Icons.star_half},
      {'points': 2500, 'title': 'Chuyên nghiệp', 'icon': Icons.star},
      {'points': 5000, 'title': 'Huyền thoại', 'icon': Icons.emoji_events},
      {'points': 10000, 'title': 'Vô địch', 'icon': Icons.military_tech},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: milestones.asMap().entries.map((entry) {
          final index = entry.key;
          final milestone = entry.value;
          final isReached = totalPoints >= (milestone['points'] as int);
          final isNext = !isReached && 
              (index == 0 || totalPoints >= (milestones[index - 1]['points'] as int));

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isReached 
                        ? AppTheme.success 
                        : (isNext ? AppTheme.primary.withOpacity(0.2) : AppTheme.lightGrey),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isReached ? Icons.check : (milestone['icon'] as IconData),
                    color: isReached 
                        ? Colors.white 
                        : (isNext ? AppTheme.primary : AppTheme.grey),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone['title'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isReached ? AppTheme.black : AppTheme.grey,
                        ),
                      ),
                      Text(
                        '${milestone['points']} điểm',
                        style: TextStyle(
                          fontSize: 13,
                          color: isReached ? AppTheme.success : AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isReached)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đã đạt',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isNext)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Còn ${(milestone['points'] as int) - totalPoints}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsInProgress(int predictions, int streak, int exactPredictions) {
    return Column(
      children: [
        AchievementProgress(
          title: 'Dự đoán viên cấp 1',
          current: predictions,
          total: 50,
          icon: Icons.sports_soccer,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 12),
        AchievementProgress(
          title: 'Streak Master',
          current: streak,
          total: 7,
          icon: Icons.local_fire_department,
          color: AppTheme.accent,
        ),
        const SizedBox(height: 12),
        AchievementProgress(
          title: 'Nhà tiên tri',
          current: exactPredictions,
          total: 25,
          icon: Icons.visibility,
          color: AppTheme.secondary,
        ),
      ],
    );
  }

  Widget _buildWeeklyGoals() {
    final goals = [
      {
        'title': 'Dự đoán 5 trận',
        'current': 3,
        'total': 5,
        'reward': '+50 điểm',
      },
      {
        'title': 'Đăng nhập 7 ngày',
        'current': 4,
        'total': 7,
        'reward': '+30 điểm',
      },
      {
        'title': '3 dự đoán chính xác',
        'current': 1,
        'total': 3,
        'reward': '+100 điểm',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: goals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          final current = goal['current'] as int;
          final total = goal['total'] as int;
          final progress = current / total;
          final isCompleted = current >= total;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? AppTheme.success 
                            : AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.flag_outlined,
                        color: isCompleted ? Colors.white : AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$current / $total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCompleted 
                                      ? AppTheme.success 
                                      : AppTheme.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: AppTheme.lightGrey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted ? AppTheme.success : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        goal['reward'] as String,
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < goals.length - 1)
                Divider(
                  height: 16,
                  color: AppTheme.lightGrey.withOpacity(0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
