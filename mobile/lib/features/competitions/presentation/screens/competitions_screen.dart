import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/providers/competition_provider.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/theme/app_theme.dart';

class CompetitionsScreen extends ConsumerStatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  ConsumerState<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends ConsumerState<CompetitionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final competitionsAsync = ref.watch(competitionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Giải VĐQG'),
            Tab(text: 'Cúp'),
          ],
        ),
      ),
      body: competitionsAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerNewsCard(),
        ),
        error: (error, stack) => ErrorState(
          message: 'Không thể tải danh sách giải đấu',
          onRetry: () => ref.invalidate(competitionsProvider),
        ),
        data: (competitions) {
          if (competitions.isEmpty) {
            return _buildEmptyState(theme);
          }

          final leagues = competitions.where((c) => c['type'] == 'league').toList();
          final cups = competitions.where((c) => c['type'] == 'cup').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _CompetitionList(competitions: competitions),
              _CompetitionList(competitions: leagues),
              _CompetitionList(competitions: cups),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có giải đấu nào',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionList extends ConsumerWidget {
  final List<dynamic> competitions;

  const _CompetitionList({required this.competitions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (competitions.isEmpty) {
      return const Center(child: Text('Không có dữ liệu'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(competitionsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          return _CompetitionCard(competition: competitions[index]);
        },
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final dynamic competition;

  const _CompetitionCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seasons = competition['seasons'] as List? ?? [];
    final currentSeason = seasons.isNotEmpty ? seasons[0] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/competition/${competition['id']}', extra: competition),
        child: Column(
          children: [
            // Header with gradient or image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                image: competition['banner'] != null
                    ? DecorationImage(
                        image: NetworkImage(competition['banner']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (competition['banner'] == null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primary.withOpacity(0.7),
                            AppTheme.primary.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (competition['logoUrl'] != null)
                          CachedNetworkImage(
                            imageUrl: competition['logoUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(),
                            errorWidget: (_, __, ___) => const Icon(Icons.emoji_events, size: 48, color: Colors.white),
                          )
                        else
                          const Icon(Icons.emoji_events, size: 48, color: Colors.white),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        competition['type'] == 'league' ? 'VĐQG' : 'Cúp',
                        style: TextStyle(
                          color: competition['type'] == 'league' ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition['name'] ?? 'Tên giải đấu',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (currentSeason != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${currentSeason['name'] ?? ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (competition['sponsor'] != null)
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Tài trợ bởi: ${competition['sponsor']['name']}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


