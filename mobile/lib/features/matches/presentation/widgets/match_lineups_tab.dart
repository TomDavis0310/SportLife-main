import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';

class MatchLineupsTab extends StatelessWidget {
  final Match match;

  const MatchLineupsTab({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final homeLineup = match.homeLineup ?? [];
    final awayLineup = match.awayLineup ?? [];

    if (homeLineup.isEmpty && awayLineup.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có đội hình',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Formation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                match.homeFormation ?? '4-3-3',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text('Đội hình', style: TextStyle(color: Colors.grey)),
              Text(
                match.awayFormation ?? '4-3-3',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Field
          _buildField(homeLineup, awayLineup),
          const SizedBox(height: 24),
          // Substitutes
          _buildSubstitutes(context),
        ],
      ),
    );
  }

  Widget _buildField(List<dynamic> homeLineup, List<dynamic> awayLineup) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Stack(
        children: [
          // Field markings
          Positioned.fill(child: CustomPaint(painter: FieldPainter())),
          // Players - simplified layout
          Column(
            children: [
              // Home team (top half)
              Expanded(child: _buildTeamLineup(homeLineup, true)),
              // Center line
              Container(height: 2, color: Colors.white30),
              // Away team (bottom half)
              Expanded(child: _buildTeamLineup(awayLineup, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineup(List<dynamic> lineup, bool isHome) {
    if (lineup.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < lineup.length && i < 11; i += 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int j = i; j < i + 4 && j < lineup.length; j++)
                  _buildPlayerIcon(lineup[j]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerIcon(dynamic player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${player['number'] ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 60,
          child: Text(
            player['name'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSubstitutes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dự bị',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.homeTeam?.shortName ?? 'Home',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${i + 12}. Cầu thủ dự bị'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.awayTeam?.shortName ?? 'Away',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${i + 12}. Cầu thủ dự bị'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);

    // Penalty boxes
    final boxWidth = size.width * 0.6;
    final boxHeight = size.height * 0.15;

    // Top box
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 0, boxWidth, boxHeight),
      paint,
    );

    // Bottom box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - boxHeight,
        boxWidth,
        boxHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



