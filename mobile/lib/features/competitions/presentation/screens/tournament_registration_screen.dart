import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/theme/app_theme.dart';

class TournamentRegistrationScreen extends ConsumerStatefulWidget {
  final dynamic season;
  final String competitionName;

  const TournamentRegistrationScreen({
    super.key,
    required this.season,
    required this.competitionName,
  });

  @override
  ConsumerState<TournamentRegistrationScreen> createState() =>
      _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState
    extends ConsumerState<TournamentRegistrationScreen> {
  bool _agreedToTerms = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản giải đấu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(managementCompetitionApiProvider)
          .registerTeam(widget.season['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng chờ duyệt.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String message = 'Đăng ký thất bại';
        if (e.toString().contains('Team already registered')) {
          message = 'Đội bóng của bạn đã đăng ký giải đấu này rồi';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tham gia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildTermsSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'XÁC NHẬN ĐĂNG KÝ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 64, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            widget.competitionName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Mùa giải: ${widget.season['name']}',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin giải đấu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Thời gian bắt đầu',
                widget.season['start_date'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.event, 'Thời gian kết thúc',
                widget.season['end_date'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.groups, 'Số đội hiện tại',
                '${widget.season['teams_count'] ?? 0}'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.monetization_on, size: 20, color: Colors.grey),
                SizedBox(width: 12),
                Text('Lệ phí tham gia: ',
                    style: TextStyle(color: Colors.grey)),
                Text('Miễn phí',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điều khoản & Quy định',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            '1. Các đội bóng tham gia phải tuân thủ quy định của ban tổ chức.\n'
            '2. Đội hình đăng ký phải đảm bảo đủ số lượng cầu thủ tối thiểu.\n'
            '3. Mọi hành vi gian lận sẽ bị loại khỏi giải đấu ngay lập tức.\n'
            '4. Ban tổ chức có quyền thay đổi lịch thi đấu khi cần thiết.',
            style: TextStyle(height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _agreedToTerms,
          onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
          title: const Text('Tôi đồng ý với các điều khoản trên'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
