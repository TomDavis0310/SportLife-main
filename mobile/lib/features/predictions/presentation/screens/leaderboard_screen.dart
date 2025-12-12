import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/prediction_provider.dart';
import '../../data/models/leaderboard_entry.dart';

final leaderboardPeriodProvider = StateProvider<String>((ref) => 'all_time');

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(leaderboardPeriodProvider);
    final leaderboardAsync =
        ref.watch(leaderboardProvider(LeaderboardParams(period: period)));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildTab(ref, 'weekly', 'Tuần này', period == 'weekly'),
                  _buildTab(ref, 'season', 'Mùa giải', period == 'season'),
                  _buildTab(ref, 'all_time', 'Tất cả', period == 'all_time'),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: leaderboardAsync.when(
              data: (leaderboard) {
                if (leaderboard.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(leaderboardProvider(LeaderboardParams(period: period)));
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Top 3 Section
                      SliverToBoxAdapter(
                        child: _buildTopThreeSection(leaderboard.take(3).toList()),
                      ),
                      
                      // List Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              const SizedBox(width: 40, child: Text('Hạng', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 16),
                              const Expanded(child: Text('Người chơi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                              const Text('Điểm', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      // Remaining List
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = leaderboard[index + 3];
                            return _buildLeaderboardItem(context, entry, index + 4);
                          },
                          childCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
                        ),
                      ),
                      
                      const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(ref, error, period),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(WidgetRef ref, String value, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(leaderboardPeriodProvider.notifier).state = value;
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu xếp hạng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tham gia dự đoán để có tên trên bảng vàng!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error, String period) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception:', '').trim(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(leaderboardProvider(LeaderboardParams(period: period))),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreeSection(List<LeaderboardEntry> topThree) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (topThree.length > 1) _buildTopThreeItem(topThree[1], 2),
          if (topThree.isNotEmpty) _buildTopThreeItem(topThree[0], 1),
          if (topThree.length > 2) _buildTopThreeItem(topThree[2], 3),
        ],
      ),
    );
  }

  Widget _buildTopThreeItem(LeaderboardEntry entry, int rank) {
    final isFirst = rank == 1;
    final double avatarSize = isFirst ? 80 : 60;
    final double podiumHeight = isFirst ? 140 : (rank == 2 ? 110 : 80);
    
    Color medalColor;
    String medalIcon;
    
    switch (rank) {
      case 1:
        medalColor = const Color(0xFFFFD700);
        medalIcon = '🥇';
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0);
        medalIcon = '🥈';
        break;
      default:
        medalColor = const Color(0xFFCD7F32);
        medalIcon = '🥉';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Crown/Medal
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: medalColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: Colors.grey[200],
                backgroundImage: entry.userAvatar.isNotEmpty && !entry.userAvatar.contains('default-avatar')
                    ? NetworkImage(entry.userAvatar)
                    : null,
                child: (entry.userAvatar.isEmpty || entry.userAvatar.contains('default-avatar'))
                    ? Text(
                        (entry.userName.isNotEmpty ? entry.userName[0] : 'U').toUpperCase(),
                        style: TextStyle(
                          fontSize: isFirst ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
            if (isFirst)
              Positioned(
                top: -10,
                right: 0,
                left: 0,
                child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 24)),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black12)],
                ),
                child: Text(medalIcon, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        
        // Name
        SizedBox(
          width: 90,
          child: Text(
            entry.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Points Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${entry.totalPoints} pts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Podium
        Container(
          width: isFirst ? 90 : 70,
          height: podiumHeight * 0.4, // Reduced height for better proportion
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withOpacity(0.8),
                medalColor.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry, int rank) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to user profile if needed
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: (entry.userAvatar.isNotEmpty && !entry.userAvatar.contains('default-avatar'))
                        ? Image.network(entry.userAvatar, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              (entry.userName.isNotEmpty ? entry.userName[0] : 'U').toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 14, color: Colors.green[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.correctScores} tỉ số đúng',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Points
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.totalPoints}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

