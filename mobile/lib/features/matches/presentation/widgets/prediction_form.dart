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
  String? _selectedOutcome; // 'home', 'draw', 'away'
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final canPredict = widget.match.canPredict;

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
      final predictedOutcome = prediction['predicted_outcome'] ?? '';
      final outcomeLabel = _getOutcomeLabel(predictedOutcome);
      
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getOutcomeColor(predictedOutcome).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getOutcomeColor(predictedOutcome)),
              ),
              child: Text(
                outcomeLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getOutcomeColor(predictedOutcome),
                ),
              ),
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
          // Outcome Prediction
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Dự đoán kết quả',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Three outcome options
                Row(
                  children: [
                    Expanded(
                      child: _buildOutcomeOption(
                        outcome: 'home',
                        label: widget.match.homeTeam?.shortName ?? 'Đội nhà',
                        sublabel: 'Thắng',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOutcomeOption(
                        outcome: 'draw',
                        label: 'Hòa',
                        sublabel: '',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOutcomeOption(
                        outcome: 'away',
                        label: widget.match.awayTeam?.shortName ?? 'Đội khách',
                        sublabel: 'Thắng',
                        color: Colors.red,
                      ),
                    ),
                  ],
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
                _buildPointRow('Đoán đúng kết quả', '+10 điểm'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedOutcome == null
                  ? null
                  : _submitPrediction,
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
                  : Text(
                      _selectedOutcome == null
                          ? 'Chọn kết quả để dự đoán'
                          : 'Gửi dự đoán',
                      style: const TextStyle(
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

  Widget _buildOutcomeOption({
    required String outcome,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    final isSelected = _selectedOutcome == outcome;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedOutcome = outcome);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (sublabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey[400],
              size: 28,
            ),
          ],
        ),
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

  String _getOutcomeLabel(String outcome) {
    switch (outcome) {
      case 'home':
        return '${widget.match.homeTeam?.shortName ?? "Đội nhà"} thắng';
      case 'draw':
        return 'Hòa';
      case 'away':
        return '${widget.match.awayTeam?.shortName ?? "Đội khách"} thắng';
      default:
        return outcome;
    }
  }

  Color _getOutcomeColor(String outcome) {
    switch (outcome) {
      case 'home':
        return Colors.green;
      case 'draw':
        return Colors.orange;
      case 'away':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitPrediction() async {
    if (_isSubmitting || _selectedOutcome == null) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(predictionApiProvider).createPrediction(
            matchId: widget.match.id,
            predictedOutcome: _selectedOutcome!,
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



