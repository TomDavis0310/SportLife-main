import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'tournament_registration_screen.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionsAsync = ref.watch(managedCompetitionsProvider);
    final user = ref.watch(currentUserProvider);
    final isManager = user?.roles.contains('club_manager') ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Giải Đấu')),
      body: competitionsAsync.when(
        data: (competitions) {
          if (competitions.isEmpty) {
            return const Center(child: Text('Hiện chưa có giải đấu nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: competitions.length,
            itemBuilder: (context, index) {
              final comp = competitions[index];
              final seasons = comp['seasons'] as List;
              final currentSeason = seasons.isNotEmpty ? seasons[0] : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: AppTheme.primary, size: 40),
                      title: Text(comp['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comp['type'] == 'league'
                              ? 'Giải Vô Địch Quốc Gia'
                              : 'Cúp Quốc Gia'),
                          // Mock sponsor display if data exists, or just a placeholder for demo
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.verified,
                                  size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                'Tài trợ bởi: ${comp['sponsor']?['name'] ?? 'SportLife Premium'}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (currentSeason != null) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mùa giải: ${currentSeason['name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                                'Thời gian: ${currentSeason['start_date']} - ${currentSeason['end_date']}'),
                            const SizedBox(height: 16),
                            if (isManager)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TournamentRegistrationScreen(
                                        season: currentSeason,
                                        competitionName: comp['name'],
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Đăng ký tham gia'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _registerForSeason(
      BuildContext context, WidgetRef ref, int seasonId) async {
    try {
      await ref.read(managementCompetitionApiProvider).registerTeam(seasonId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng chờ duyệt.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Handle specific error messages if possible
        String message = 'Đăng ký thất bại';
        if (e.toString().contains('Team already registered')) {
          message = 'Đội của bạn đã đăng ký giải này rồi';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }
}
