import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/champion_prediction_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/data/models/user.dart';
import '../../data/models/available_season.dart';

class ChampionPredictionDetailScreen extends ConsumerStatefulWidget {
  final int seasonId;

  const ChampionPredictionDetailScreen({super.key, required this.seasonId});

  @override
  ConsumerState<ChampionPredictionDetailScreen> createState() =>
      _ChampionPredictionDetailScreenState();
}

class _ChampionPredictionDetailScreenState
    extends ConsumerState<ChampionPredictionDetailScreen> {
  int? _selectedTeamId;
  String _reason = '';
  int _confidenceLevel = 50;
  int _pointsWagered = 100;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(seasonTeamsProvider(widget.seasonId));
    final myPredictionAsync = ref.watch(mySeasonPredictionProvider(widget.seasonId));
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Du doan Vo dich'),
      ),
      body: teamsAsync.when(
        data: (data) {
          final season = data['season'] as Map<String, dynamic>;
          final teams = data['teams'] as List<SeasonTeamForPrediction>;
          final totalPredictions = data['total_predictions'] as int;
          final canPredict = season['can_predict'] ?? true;

          return myPredictionAsync.when(
            data: (existingPrediction) {
              // If user already has prediction, show it
              if (existingPrediction != null && _selectedTeamId == null) {
                _selectedTeamId = existingPrediction.predictedTeamId;
                _reason = existingPrediction.reason ?? '';
                _confidenceLevel = existingPrediction.confidenceLevel;
              }

              return Column(
                children: [
                  // Season Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.primary.withOpacity(0.05),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                season['competition_name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                season['name'] ?? '',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$totalPredictions',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const Text(
                              'luot du doan',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Teams List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final isSelected = _selectedTeamId == team.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: canPredict && existingPrediction == null
                                ? () => setState(() => _selectedTeamId = team.id)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Position
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _getPositionColor(team.position),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${team.position}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Team logo
                                  if (team.logo.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        team.logo,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildPlaceholderLogo(),
                                      ),
                                    )
                                  else
                                    _buildPlaceholderLogo(),
                                  const SizedBox(width: 12),

                                  // Team info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          team.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppTheme.primary
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          '${team.points} diem - ${team.played} tran',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Prediction stats
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${team.predictionPercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: team.predictionPercentage > 20
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${team.predictionCount} phieu',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom section - Prediction form
                  if (canPredict && existingPrediction == null && _selectedTeamId != null)
                    _buildPredictionForm(context, userAsync),
                  
                  // Show existing prediction info
                  if (existingPrediction != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                existingPrediction.isPending
                                    ? Icons.pending
                                    : existingPrediction.isWon
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                color: existingPrediction.isPending
                                    ? Colors.orange
                                    : existingPrediction.isWon
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ban da du doan: ${existingPrediction.teamName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Diem dat: ${existingPrediction.pointsWagered}'),
                              Text('Do tin: ${existingPrediction.confidenceLevel}%'),
                              Text(
                                'Thuong du kien: ${existingPrediction.potentialWinnings}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Loi: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Loi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(seasonTeamsProvider(widget.seasonId)),
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.sports_soccer, size: 24),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position <= 4) return Colors.green;
    if (position <= 6) return Colors.blue;
    return Colors.grey;
  }

  Widget _buildPredictionForm(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Do tu tin:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '$_confidenceLevel%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _confidenceLevel.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            onChanged: (value) => setState(() => _confidenceLevel = value.toInt()),
          ),
          Text(
            'He so thuong: x${_getMultiplier(_confidenceLevel).toStringAsFixed(1)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),

          // Points Wagered
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Diem dat cuoc:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '$_pointsWagered diem',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _pointsWagered.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            onChanged: (value) => setState(() => _pointsWagered = value.toInt()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'So du: ${user?.sportPoints ?? 0} diem',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Thuong du kien: ${(_pointsWagered * _getMultiplier(_confidenceLevel)).toInt()} diem',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reason
          TextField(
            decoration: InputDecoration(
              labelText: 'Ly do du doan (tuy chon)',
              hintText: 'Vi sao ban chon doi nay?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 2,
            onChanged: (value) => _reason = value,
          ),
          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitPrediction(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Xac nhan du doan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMultiplier(int confidenceLevel) {
    if (confidenceLevel >= 90) return 3.0;
    if (confidenceLevel >= 70) return 2.0;
    if (confidenceLevel >= 50) return 1.5;
    return 1.0;
  }

  Future<void> _submitPrediction(BuildContext context) async {
    if (_selectedTeamId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(championPredictionApiProvider);
      await api.createPrediction(
        seasonId: widget.seasonId,
        predictedTeamId: _selectedTeamId!,
        reason: _reason.isNotEmpty ? _reason : null,
        confidenceLevel: _confidenceLevel,
        pointsWagered: _pointsWagered,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Du doan thanh cong!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh data
        ref.invalidate(mySeasonPredictionProvider(widget.seasonId));
        ref.invalidate(seasonTeamsProvider(widget.seasonId));
        ref.invalidate(myChampionPredictionsProvider);
        ref.invalidate(currentUserProvider);
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
