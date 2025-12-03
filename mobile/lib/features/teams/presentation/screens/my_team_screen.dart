import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/team_provider.dart';
import '../../../../core/theme/app_theme.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTeamAsync = ref.watch(myTeamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Đội bóng')),
      body: myTeamAsync.when(
        data: (team) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: team.logo != null 
                            ? NetworkImage(team.logo!) 
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: team.logo == null 
                            ? const Icon(Icons.sports_soccer, size: 50, color: Colors.grey) 
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        team.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Sân vận động: ${team.stadium}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Players List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách cầu thủ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      onPressed: () => _showAddPlayerDialog(context, ref),
                      icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (team.players.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Chưa có cầu thủ nào'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: team.players.length,
                    itemBuilder: (context, index) {
                      final player = team.players[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            child: Text(
                              '${player['jersey_number']}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(player['name']),
                          subtitle: Text(player['position']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmDeletePlayer(context, ref, player['id']),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    String selectedPosition = 'Forward';
    final positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm cầu thủ'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên cầu thủ'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Số áo'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPosition,
                decoration: const InputDecoration(labelText: 'Vị trí'),
                items: positions.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) => setState(() => selectedPosition = val!),
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
              try {
                await ref.read(teamApiProvider).addPlayer(
                      name: nameController.text,
                      position: selectedPosition,
                      jerseyNumber: int.parse(numberController.text),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.refresh(myTeamProvider);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlayer(BuildContext context, WidgetRef ref, int playerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa cầu thủ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(teamApiProvider).removePlayer(playerId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.refresh(myTeamProvider);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
