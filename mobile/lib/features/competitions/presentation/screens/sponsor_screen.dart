import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SponsorScreen extends ConsumerWidget {
  const SponsorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionsAsync = ref.watch(managedCompetitionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhà tài trợ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTournamentDialog(context, ref),
        label: const Text('Tạo giải đấu'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
      body: competitionsAsync.when(
        data: (competitions) {
          if (competitions.isEmpty) {
            return const Center(child: Text('Bạn chưa tạo giải đấu nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: competitions.length,
            itemBuilder: (context, index) {
              final comp = competitions[index];
              final currentSeason = (comp['seasons'] as List).isNotEmpty
                  ? comp['seasons'][0]
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: AppTheme.primary, size: 40),
                      title: Text(comp['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(comp['type'] == 'league'
                          ? 'Giải Vô Địch Quốc Gia'
                          : 'Cúp Quốc Gia'),
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
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Số đội đăng ký: ${currentSeason['teams_count'] ?? 0}'),
                                ElevatedButton(
                                  onPressed: () => _showRegistrations(
                                      context, ref, currentSeason['id']),
                                  child: const Text('Duyệt đăng ký'),
                                ),
                              ],
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

  void _showCreateTournamentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final seasonController = TextEditingController(text: '2025');
    String selectedType = 'league';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo giải đấu mới'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên giải đấu'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Loại giải'),
                items: const [
                  DropdownMenuItem(value: 'league', child: Text('League')),
                  DropdownMenuItem(value: 'cup', child: Text('Cup')),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: seasonController,
                decoration: const InputDecoration(labelText: 'Tên mùa giải'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final reader = ref;
              try {
                await reader
                    .read(managementCompetitionApiProvider)
                    .createCompetition(
                      name: nameController.text,
                      type: selectedType,
                      seasonName: seasonController.text,
                      startDate: DateTime.now().toIso8601String(),
                      endDate: DateTime.now()
                          .add(const Duration(days: 365))
                          .toIso8601String(),
                    );
                if (!navigator.mounted) return;
                navigator.pop();
                final _ = reader.refresh(managedCompetitionsProvider);
              } catch (e) {
                if (navigator.mounted) {
                  ScaffoldMessenger.of(navigator.context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showRegistrations(BuildContext context, WidgetRef ref, int seasonId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) => _RegistrationsList(
          seasonId: seasonId,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _RegistrationsList extends ConsumerWidget {
  final int seasonId;
  final ScrollController scrollController;

  const _RegistrationsList({
    required this.seasonId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need a provider for registrations, let's create a temporary future here
    final registrationsFuture =
        ref.watch(managementCompetitionApiProvider).getRegistrations(seasonId);

    return FutureBuilder(
      future: registrationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final teams = snapshot.data as List<dynamic>;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Text(
                'Danh sách đăng ký',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: teams.isEmpty
                    ? const Center(child: Text('Chưa có đội nào đăng ký'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          final status = team.pivot?['status'] ?? 'pending';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: team.logo != null ? NetworkImage(team.logo!) : null,
                              child: team.logo == null ? const Icon(Icons.sports_soccer) : null,
                            ),
                            title: Text(team.name),
                            subtitle: Text('Trạng thái: $status'),
                                trailing: status == 'pending'
                                ? ElevatedButton(
                                    onPressed: () async {
                                      final navigator = Navigator.of(context);
                                      final reader = ref;
                                      await reader
                                          .read(managementCompetitionApiProvider)
                                          .approveRegistration(
                                              seasonId, team.id);
                                      if (!navigator.mounted) return;
                                      navigator.pop();
                                      final _ = reader.refresh(managedCompetitionsProvider);
                                    },
                                    child: const Text('Duyệt'),
                                  )
                                : const Icon(Icons.check_circle,
                                    color: Colors.green),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
