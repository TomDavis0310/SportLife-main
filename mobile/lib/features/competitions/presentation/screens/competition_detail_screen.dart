import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_state.dart';

class CompetitionDetailScreen extends ConsumerWidget {
  final int competitionId;
  final dynamic initialData;

  const CompetitionDetailScreen({
    super.key,
    required this.competitionId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionAsync = ref.watch(competitionDetailProvider(competitionId));

    return Scaffold(
      body: competitionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải thông tin giải đấu',
          onRetry: () => ref.invalidate(competitionDetailProvider(competitionId)),
        ),
        data: (competition) {
          final data = competition ?? initialData;
          if (data == null) return const ErrorState(message: 'Không tìm thấy giải đấu');

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, data),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(context, data),
                      const SizedBox(height: 24),
                      _buildTeamsSection(context, data),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic data) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(data['name'] ?? 'Chi tiết giải đấu'),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (data['banner'] != null)
              CachedNetworkImage(
                imageUrl: data['banner'],
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppTheme.primary),
              )
            else
              Container(color: AppTheme.primary),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Center(
               child: data['logoUrl'] != null
                  ? CachedNetworkImage(
                      imageUrl: data['logoUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.emoji_events, size: 60, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic data) {
    final theme = Theme.of(context);
    final seasons = data['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin giải đấu', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.category, 'Loại giải', data['type'] == 'league' ? 'Giải Vô Địch Quốc Gia' : 'Cúp'),
        if (data['sponsor'] != null)
          _buildInfoRow(Icons.verified, 'Nhà tài trợ', data['sponsor']['name']),
        if (currentSeason != null) ...[
           _buildInfoRow(Icons.calendar_today, 'Mùa giải', currentSeason['name']),
           _buildInfoRow(Icons.date_range, 'Thời gian', '${currentSeason['start_date']} - ${currentSeason['end_date']}'),
        ],
        if (data['description'] != null) ...[
          const SizedBox(height: 16),
          Text('Mô tả', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(data['description']),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(BuildContext context, dynamic data) {
    final theme = Theme.of(context);
    final teams = data['teams'] as List? ?? [];

    if (teams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Đội tham gia (${teams.length})', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teams.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final team = teams[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: team['logo'] != null ? NetworkImage(team['logo']) : null,
                child: team['logo'] == null ? Text(team['name'][0]) : null,
              ),
              title: Text(team['name']),
              subtitle: Text(team['stadium'] ?? 'Sân vận động chưa cập nhật'),
            );
          },
        ),
      ],
    );
  }
}
