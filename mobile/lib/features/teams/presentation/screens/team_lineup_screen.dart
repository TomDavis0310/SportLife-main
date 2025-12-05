import 'package:flutter/material.dart';
import '../../data/models/team.dart';
import '../../data/models/player.dart';
import '../../../../core/theme/app_theme.dart';

class TeamLineupScreen extends StatefulWidget {
  final Team team;

  const TeamLineupScreen({super.key, required this.team});

  @override
  State<TeamLineupScreen> createState() => _TeamLineupScreenState();
}

class _TeamLineupScreenState extends State<TeamLineupScreen> {
  String _selectedFormation = '4-4-2';
  final Map<String, List<Offset>> _formations = {
    '4-4-2': [
      const Offset(0.5, 0.9), // GK
      const Offset(0.2, 0.7), // LB
      const Offset(0.4, 0.75), // CB
      const Offset(0.6, 0.75), // CB
      const Offset(0.8, 0.7), // RB
      const Offset(0.2, 0.45), // LM
      const Offset(0.4, 0.5), // CM
      const Offset(0.6, 0.5), // CM
      const Offset(0.8, 0.45), // RM
      const Offset(0.35, 0.2), // ST
      const Offset(0.65, 0.2), // ST
    ],
    '4-3-3': [
      const Offset(0.5, 0.9), // GK
      const Offset(0.2, 0.7), // LB
      const Offset(0.4, 0.75), // CB
      const Offset(0.6, 0.75), // CB
      const Offset(0.8, 0.7), // RB
      const Offset(0.3, 0.5), // CM
      const Offset(0.5, 0.55), // CDM
      const Offset(0.7, 0.5), // CM
      const Offset(0.2, 0.25), // LW
      const Offset(0.5, 0.2), // ST
      const Offset(0.8, 0.25), // RW
    ],
  };

  // Map position index (0-10) to Player ID
  final Map<int, int?> _lineup = {};

  @override
  void initState() {
    super.initState();
    // Auto-fill lineup with first 11 players for demo
    for (int i = 0; i < 11 && i < widget.team.players.length; i++) {
      _lineup[i] = widget.team.players[i].id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội hình thi đấu'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu đội hình (Mô phỏng)')),
              );
            },
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: AppTheme.primary,
              value: _selectedFormation,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFormation = newValue;
                  });
                }
              },
              items: _formations.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Field markings
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 2,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Players
                  ...List.generate(11, (index) {
                    final positions = _formations[_selectedFormation]!;
                    final offset = positions[index];
                    return Align(
                      alignment: Alignment(
                        (offset.dx - 0.5) * 2, // Convert 0..1 to -1..1
                        (offset.dy - 0.5) * 2,
                      ),
                      child: _buildPlayerNode(index),
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildSubstitutesList(),
        ],
      ),
    );
  }

  Widget _buildPlayerNode(int index) {
    final playerId = _lineup[index];
    final player = playerId != null 
        ? widget.team.players.firstWhere((p) => p.id == playerId, orElse: () => widget.team.players.first) 
        : null;

    return GestureDetector(
      onTap: () => _showPlayerSelectionDialog(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 2),
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: player?.avatar != null
                ? CircleAvatar(backgroundImage: NetworkImage(player!.avatar!))
                : Center(
                    child: Text(
                      player?.jerseyNumber?.toString() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player?.name.split(' ').last ?? 'Chọn',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstitutesList() {
    final fieldedPlayerIds = _lineup.values.where((id) => id != null).toSet();
    final substitutes = widget.team.players.where((p) => !fieldedPlayerIds.contains(p.id)).toList();

    return Container(
      height: 120,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Dự bị', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: substitutes.length,
              itemBuilder: (context, index) {
                final player = substitutes[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: player.avatar != null ? NetworkImage(player.avatar!) : null,
                        child: player.avatar == null ? Text('${player.jerseyNumber ?? "?"}') : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerSelectionDialog(int positionIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: widget.team.players.length,
          itemBuilder: (context, index) {
            final player = widget.team.players[index];
            final isSelected = _lineup.containsValue(player.id);
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: player.avatar != null ? NetworkImage(player.avatar!) : null,
                child: player.avatar == null ? Text('${player.jerseyNumber ?? "?"}') : null,
              ),
              title: Text(player.name),
              subtitle: Text(player.position ?? 'N/A'),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() {
                  // If player is already in another position, swap or remove? 
                  // For simplicity, just set.
                  _lineup[positionIndex] = player.id;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
