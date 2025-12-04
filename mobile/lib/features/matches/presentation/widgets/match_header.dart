import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/match.dart';

class MatchHeader extends StatelessWidget {
  final Match match;

  const MatchHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isLive = match.status == MatchStatus.live || match.status == MatchStatus.halftime;
    final isFinished = match.status == MatchStatus.finished;
    final matchTime = DateTime.parse(match.matchTime);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryDark, AppTheme.darkGrey],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Competition
              Text(
                match.competitionName ?? match.competition?.name ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),
              // Teams and Score
              Row(
                children: [
                  // Home Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(
                          match.homeTeam?.logo,
                          match.homeTeam?.code ?? 'H',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.homeTeam?.shortName ?? 'Home',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  // Score or Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        if (isLive || isFinished) ...[
                          Text(
                            match.scoreDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.live,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${match.minute}'",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const Text(
                              'Kết thúc',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ] else ...[
                          Text(
                            DateFormat('HH:mm').format(matchTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(matchTime),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Away Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(
                          match.awayTeam?.logo,
                          match.awayTeam?.code ?? 'A',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.awayTeam?.shortName ?? 'Away',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String code) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 8),
        ],
      ),
      child: logoUrl != null
          ? ClipOval(
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                code,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
    );
  }
}



