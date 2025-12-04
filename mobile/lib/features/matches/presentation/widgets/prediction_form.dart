import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/prediction_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/match_provider.dart';
import '../../data/models/match.dart';

class PredictionForm extends ConsumerStatefulWidget {
  final Match match;

  const PredictionForm({super.key, required this.match});

  @override
  ConsumerState<PredictionForm> createState() => _PredictionFormState();
}

class _PredictionFormState extends ConsumerState<PredictionForm> {
  int _homeScore = 0;
  int _awayScore = 0;
  int? _firstScorerId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final canPredict = widget.match.canPredict;
    final players = _availablePlayers();

    if (!isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Đăng nhập để dự đoán', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      );
    }

    if (widget.match.userPrediction != null) {
      final prediction = widget.match.userPrediction;
      final homeScore = prediction['predicted_home_score'] ?? prediction['home_score'];
      final awayScore = prediction['predicted_away_score'] ?? prediction['away_score'];
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Bạn đã dự đoán trận đấu này',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Dự đoán: $homeScore - $awayScore',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/predictions'),
              child: const Text('Xem tất cả dự đoán'),
            ),
          ],
        ),
      );
    }

    if (!canPredict) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.match.status == MatchStatus.finished
                  ? 'Trận đấu đã kết thúc'
                  : 'Không thể dự đoán lúc này',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Prediction
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Dự đoán tỉ số',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home Score
                    Column(
                      children: [
                        Text(
                          widget.match.homeTeam?.shortName ?? 'Home',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildScoreSelector(
                          value: _homeScore,
                          onChanged: (value) {
                            setState(() => _homeScore = value);
                          },
                        ),
                      ],
                    ),
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Away Score
                    Column(
                      children: [
                        Text(
                          widget.match.awayTeam?.shortName ?? 'Away',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildScoreSelector(
                          value: _awayScore,
                          onChanged: (value) {
                            setState(() => _awayScore = value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // First Scorer (Optional)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Người ghi bàn đầu tiên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '+5 điểm',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                players.isEmpty
                    ? const Text(
                        'Danh sách cầu thủ sẽ được cập nhật khi có đội hình chính thức.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    : DropdownButtonFormField<int?>(
                        initialValue: _firstScorerId,
                        decoration: const InputDecoration(
                          hintText: 'Chọn cầu thủ (không bắt buộc)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Không chọn'),
                          ),
                          ...players.map(
                            (player) => DropdownMenuItem<int?>(
                              value: player['id'] as int,
                              child: Text(player['name'] as String),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _firstScorerId = value);
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Points Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Cách tính điểm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPointRow('Đoán đúng tỉ số', '+10 điểm'),
                _buildPointRow('Đoán đúng kết quả', '+5 điểm'),
                _buildPointRow('Đoán đúng người ghi bàn', '+5 điểm'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPrediction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Gửi dự đoán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSelector({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: value < 15 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildPointRow(String label, String points) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            points,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _availablePlayers() {
    final players = <Map<String, dynamic>>[];
    final seen = <int>{};

    void extract(List<dynamic>? lineup) {
      if (lineup == null) return;
      for (final player in lineup) {
        if (player is Map<String, dynamic>) {
          final id = player['id'] ?? player['player_id'];
          final name = player['name'] ?? player['player_name'];
          if (id is int && name is String && !seen.contains(id)) {
            seen.add(id);
            players.add({'id': id, 'name': name});
          }
        }
      }
    }

    extract(widget.match.homeLineup);
    extract(widget.match.awayLineup);

    return players;
  }

  Future<void> _submitPrediction() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(predictionApiProvider).createPrediction(
            matchId: widget.match.id,
            predictedHomeScore: _homeScore,
            predictedAwayScore: _awayScore,
            firstScorerId: _firstScorerId,
          );
      ref.invalidate(myPredictionsProvider);
      // Also invalidate match detail to update UI if needed
      ref.invalidate(matchDetailProvider(widget.match.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dự đoán thành công!'),
            backgroundColor: AppTheme.primary,
          ),
        );
        // Don't reset score immediately so user sees what they predicted
        // Or navigate away? For now, just keep state.
      }
    } on DioException catch (e) {
      if (mounted) {
        String message = 'Đã có lỗi xảy ra';
        if (e.response?.statusCode == 422) {
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            message = data['message'] ?? 'Dữ liệu không hợp lệ';
          }
          if (message == 'Predictions are closed for this match') {
            message = 'Đã hết thời gian dự đoán cho trận đấu này';
          } else if (message == 'You have already made a prediction for this match') {
            message = 'Bạn đã dự đoán trận đấu này rồi';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}



