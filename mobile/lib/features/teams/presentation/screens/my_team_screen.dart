import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/team_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/team.dart';
import '../../data/models/player.dart';
import '../../data/models/team_staff.dart';
import 'team_lineup_screen.dart';

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTeamAsync = ref.watch(myTeamProvider);

    return Scaffold(
      body: myTeamAsync.when(
        data: (team) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _TeamHeader(team: team),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditTeamDialog(context, ref, team),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _OverviewTab(team: team),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          if (err is DioException && err.response?.statusCode == 404) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    'Bạn chưa quản lý đội bóng nào',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vui lòng liên hệ quản trị viên để được phân công.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Error: $err'));
        },
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, WidgetRef ref, Team team) {
    final nameController = TextEditingController(text: team.name);
    final stadiumController = TextEditingController(text: team.stadium);
    final cityController = TextEditingController(text: team.city);
    final foundedController = TextEditingController(text: team.founded?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đội bóng',
                  prefixIcon: Icon(Icons.shield),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stadiumController,
                decoration: const InputDecoration(
                  labelText: 'Sân vận động',
                  prefixIcon: Icon(Icons.stadium),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Thành phố',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: foundedController,
                decoration: const InputDecoration(
                  labelText: 'Năm thành lập',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
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
                await ref.read(teamApiProvider).updateTeam({
                  'name': nameController.text,
                  'stadium': stadiumController.text,
                  'city': cityController.text,
                  'founded_year': int.tryParse(foundedController.text),
                });
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
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final Team team;

  const _TeamHeader({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey[100],
              backgroundImage: team.logo != null ? NetworkImage(team.logo!) : null,
              child: team.logo == null
                  ? const Icon(Icons.sports_soccer, size: 48, color: AppTheme.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          if (team.city != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    team.city!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Team team;

  const _OverviewTab({required this.team});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Quản lý đội bóng'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildMenuButton(
                context,
                'Đội hình',
                Icons.people,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Đội hình')), body: _SquadTab(team: team))),
                ),
              ),
              _buildMenuButton(
                context,
                'Ban huấn luyện',
                Icons.sports,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Ban huấn luyện')), body: _StaffTab(team: team))),
                ),
              ),
              _buildMenuButton(
                context,
                'Lịch thi đấu',
                Icons.calendar_today,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Lịch thi đấu')), body: _MatchesTab(teamId: team.id))),
                ),
              ),
              _buildMenuButton(
                context,
                'Sơ đồ chiến thuật',
                Icons.grid_on,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamLineupScreen(team: team)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Thông tin CLB'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(Icons.stadium, 'Sân vận động', team.stadium ?? 'Chưa cập nhật'),
                  const Divider(),
                  _buildInfoRow(Icons.people, 'Sức chứa', team.stadiumCapacity != null ? '${team.stadiumCapacity} chỗ ngồi' : 'Chưa cập nhật'),
                  const Divider(),
                  _buildInfoRow(Icons.location_city, 'Thành phố', team.city ?? 'Chưa cập nhật'),
                  const Divider(),
                  _buildInfoRow(Icons.calendar_month, 'Năm thành lập', team.founded?.toString() ?? 'Chưa cập nhật'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Trang phục thi đấu'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKitItem('Sân nhà', team.primaryColor),
                  _buildKitItem('Sân khách', team.secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
      ),
    );
  }

  Widget _buildKitItem(String label, String? hexColor) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _parseColor(hexColor),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.checkroom,
            color: _isLightColor(_parseColor(hexColor)) ? Colors.black54 : Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null) return Colors.grey;
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  bool _isLightColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SquadTab extends ConsumerWidget {
  final Team team;

  const _SquadTab({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalValue = team.players.fold<int>(0, (sum, player) => sum + (player.marketValue ?? 0));
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '€');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppTheme.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá trị đội hình', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalValue),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách cầu thủ (${team.players.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddPlayerDialog(context, ref),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Thêm'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (team.players.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Chưa có cầu thủ nào', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          ...team.players.map((player) => _buildPlayerCard(context, ref, player)),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, WidgetRef ref, Player player) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '€', decimalDigits: 0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPlayerDetails(context, ref, player),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'player_${player.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage: player.avatar != null ? NetworkImage(player.avatar!) : null,
                  child: player.avatar == null
                      ? Text(
                          '${player.jerseyNumber ?? "?"}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            player.position ?? 'N/A',
                            style: TextStyle(color: Colors.grey[800], fontSize: 12),
                          ),
                        ),
                        if (player.marketValue != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            currencyFormat.format(player.marketValue),
                            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDeletePlayer(context, ref, player.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context, WidgetRef ref, Player player) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '€', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primary),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditPlayerDialog(context, ref, player);
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Hero(
                      tag: 'player_${player.id}',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        backgroundImage: player.avatar != null ? NetworkImage(player.avatar!) : null,
                        child: player.avatar == null
                            ? Text(
                                '${player.jerseyNumber ?? "?"}',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    player.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player.position ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow(Icons.numbers, 'Số áo', '${player.jerseyNumber ?? "N/A"}'),
                  const Divider(),
                  _buildDetailRow(Icons.monetization_on, 'Giá trị thị trường', player.marketValue != null ? currencyFormat.format(player.marketValue) : 'Chưa cập nhật'),
                  const Divider(),
                  _buildDetailRow(Icons.description, 'Hợp đồng đến', player.contractUntil ?? 'Chưa cập nhật'),
                  const Divider(),
                  _buildDetailRow(Icons.height, 'Chiều cao', player.height != null ? '${player.height} cm' : 'Chưa cập nhật'),
                  const Divider(),
                  _buildDetailRow(Icons.scale, 'Cân nặng', player.weight != null ? '${player.weight} kg' : 'Chưa cập nhật'),
                  const Divider(),
                  _buildDetailRow(Icons.cake, 'Ngày sinh', player.birthDate ?? 'Chưa cập nhật'),
                  const Divider(),
                  _buildDetailRow(Icons.flag, 'Quốc tịch', player.nationality ?? 'Chưa cập nhật'),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
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

  void _showEditPlayerDialog(BuildContext context, WidgetRef ref, Player player) {
    final nameController = TextEditingController(text: player.name);
    final numberController = TextEditingController(text: player.jerseyNumber?.toString());
    final marketValueController = TextEditingController(text: player.marketValue?.toString());
    final contractController = TextEditingController(text: player.contractUntil);
    String selectedPosition = player.position ?? 'Forward';
    final positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa cầu thủ'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
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
                  value: positions.contains(selectedPosition) ? selectedPosition : positions.first,
                  decoration: const InputDecoration(labelText: 'Vị trí'),
                  items: positions.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedPosition = val!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: marketValueController,
                  decoration: const InputDecoration(labelText: 'Giá trị thị trường (€)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contractController,
                  decoration: const InputDecoration(labelText: 'Hợp đồng đến (YYYY-MM-DD)'),
                ),
              ],
            ),
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
                await ref.read(teamApiProvider).updatePlayer(player.id, {
                  'name': nameController.text,
                  'position': selectedPosition,
                  'jersey_number': int.tryParse(numberController.text),
                  'market_value': int.tryParse(marketValueController.text),
                  'contract_until': contractController.text,
                });
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
            child: const Text('Lưu'),
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

class _StaffTab extends ConsumerWidget {
  final Team team;

  const _StaffTab({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ban huấn luyện (${team.staff.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddStaffDialog(context, ref),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Thêm'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (team.staff.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.group_off, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Chưa có thành viên ban huấn luyện', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          ...team.staff.map((staff) => _buildStaffCard(context, ref, staff)),
      ],
    );
  }

  Widget _buildStaffCard(BuildContext context, WidgetRef ref, TeamStaff staff) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              backgroundImage: staff.avatar != null ? NetworkImage(staff.avatar!) : null,
              child: staff.avatar == null
                  ? Text(
                      staff.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      staff.role,
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteStaff(context, ref, staff.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final nationalityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm thành viên BHL'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên thành viên'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Vai trò (HLV, Trợ lý...)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nationalityController,
                decoration: const InputDecoration(labelText: 'Quốc tịch'),
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
                await ref.read(teamApiProvider).addStaff({
                  'name': nameController.text,
                  'role': roleController.text,
                  'nationality': nationalityController.text,
                });
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

  void _confirmDeleteStaff(BuildContext context, WidgetRef ref, int staffId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa thành viên này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(teamApiProvider).removeStaff(staffId);
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

class _MatchesTab extends ConsumerWidget {
  final int teamId;

  const _MatchesTab({required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(teamMatchesProvider(teamId));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Chưa có trận đấu nào', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          match['start_time'] ?? 'Chưa có lịch',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: match['status'] == 'finished' ? Colors.grey[200] : AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            match['status'] == 'finished' ? 'Kết thúc' : 'Sắp diễn ra',
                            style: TextStyle(
                              color: match['status'] == 'finished' ? Colors.grey[800] : AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage: match['home_team']['logo'] != null 
                                    ? NetworkImage(match['home_team']['logo']) 
                                    : null,
                                child: match['home_team']['logo'] == null 
                                    ? const Icon(Icons.shield, color: Colors.grey) 
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                match['home_team']['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${match['home_score'] ?? '-'} : ${match['away_score'] ?? '-'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage: match['away_team']['logo'] != null 
                                    ? NetworkImage(match['away_team']['logo']) 
                                    : null,
                                child: match['away_team']['logo'] == null 
                                    ? const Icon(Icons.shield, color: Colors.grey) 
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                match['away_team']['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
