import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/competition_provider.dart';
import '../../../../core/theme/app_theme.dart';

class CreateCompetitionScreen extends ConsumerStatefulWidget {
  const CreateCompetitionScreen({super.key});

  @override
  ConsumerState<CreateCompetitionScreen> createState() => _CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState extends ConsumerState<CreateCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'league';
  String _selectedRoundType = 'round_robin'; // Hình thức thi đấu
  
  // Season info
  final _seasonController = TextEditingController(text: '2025');
  final _maxTeamsController = TextEditingController(text: '16');
  final _minTeamsController = TextEditingController(text: '4');
  
  // Dates
  DateTime _registrationStartDate = DateTime.now();
  DateTime _registrationEndDate = DateTime.now().add(const Duration(days: 30));
  DateTime _startDate = DateTime.now().add(const Duration(days: 45));
  DateTime _endDate = DateTime.now().add(const Duration(days: 135));
  
  // Additional info
  final _locationController = TextEditingController();
  final _prizeController = TextEditingController();
  final _rulesController = TextEditingController();
  final _contactController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _seasonController.dispose();
    _maxTeamsController.dispose();
    _minTeamsController.dispose();
    _locationController.dispose();
    _prizeController.dispose();
    _rulesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime initialDate;
    DateTime firstDate;
    
    switch (type) {
      case 'regStart':
        initialDate = _registrationStartDate;
        firstDate = DateTime.now();
        break;
      case 'regEnd':
        initialDate = _registrationEndDate;
        firstDate = _registrationStartDate;
        break;
      case 'start':
        initialDate = _startDate;
        firstDate = _registrationEndDate;
        break;
      case 'end':
        initialDate = _endDate;
        firstDate = _startDate;
        break;
      default:
        return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'regStart':
            _registrationStartDate = picked;
            if (_registrationEndDate.isBefore(_registrationStartDate)) {
              _registrationEndDate = _registrationStartDate.add(const Duration(days: 30));
            }
            if (_startDate.isBefore(_registrationEndDate)) {
              _startDate = _registrationEndDate.add(const Duration(days: 15));
            }
            break;
          case 'regEnd':
            _registrationEndDate = picked;
            if (_startDate.isBefore(_registrationEndDate)) {
              _startDate = _registrationEndDate.add(const Duration(days: 15));
            }
            break;
          case 'start':
            _startDate = picked;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(days: 90));
            }
            break;
          case 'end':
            _endDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(managementCompetitionApiProvider).createCompetition(
            name: _nameController.text,
            type: _selectedType,
            roundType: _selectedRoundType,
            seasonName: _seasonController.text,
            startDate: _startDate.toIso8601String(),
            endDate: _endDate.toIso8601String(),
            maxTeams: int.tryParse(_maxTeamsController.text) ?? 16,
            minTeams: int.tryParse(_minTeamsController.text) ?? 4,
            registrationStartDate: _registrationStartDate.toIso8601String(),
            registrationEndDate: _registrationEndDate.toIso8601String(),
            description: _descriptionController.text.isNotEmpty 
                ? _descriptionController.text : null,
            location: _locationController.text.isNotEmpty 
                ? _locationController.text : null,
            prize: _prizeController.text.isNotEmpty 
                ? _prizeController.text : null,
            rules: _rulesController.text.isNotEmpty 
                ? _rulesController.text : null,
            contact: _contactController.text.isNotEmpty 
                ? _contactController.text : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo giải đấu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo giải đấu mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== THÔNG TIN CƠ BẢN =====
              _buildSectionTitle(context, 'Thông tin cơ bản', Icons.info_outline),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên giải đấu *',
                  hintText: 'Ví dụ: V.League 1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_events_outlined),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập tên giải đấu' : null,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại giải đấu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'league', child: Text('Giải Vô Địch (League)')),
                  DropdownMenuItem(value: 'cup', child: Text('Cúp (Cup)')),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              
              // Hình thức thi đấu
              DropdownButtonFormField<String>(
                value: _selectedRoundType,
                decoration: const InputDecoration(
                  labelText: 'Hình thức thi đấu *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                items: const [
                  DropdownMenuItem(value: 'round_robin', child: Text('Vòng tròn - Mỗi đội gặp nhau 1-2 lần')),
                  DropdownMenuItem(value: 'group_stage', child: Text('Vòng bảng - Chia bảng, đấu vòng tròn')),
                  DropdownMenuItem(value: 'knockout', child: Text('Loại trực tiếp - Thua là bị loại')),
                  DropdownMenuItem(value: 'league', child: Text('Giải vô địch - Vòng tròn 2 lượt')),
                  DropdownMenuItem(value: 'mixed', child: Text('Kết hợp - Vòng bảng + Loại trực tiếp')),
                ],
                onChanged: (val) => setState(() => _selectedRoundType = val!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả giải đấu',
                  hintText: 'Giới thiệu về giải đấu...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // ===== THÔNG TIN MÙA GIẢI =====
              _buildSectionTitle(context, 'Thông tin mùa giải', Icons.calendar_month),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(
                  labelText: 'Tên mùa giải *',
                  hintText: 'Ví dụ: 2025-2026',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập tên mùa giải' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minTeamsController,
                      decoration: const InputDecoration(
                        labelText: 'Số đội tối thiểu *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Bắt buộc';
                        final num = int.tryParse(value);
                        if (num == null || num < 2) return 'Tối thiểu 2';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxTeamsController,
                      decoration: const InputDecoration(
                        labelText: 'Số đội tối đa *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Bắt buộc';
                        final num = int.tryParse(value);
                        if (num == null || num < 2 || num > 64) return '2-64';
                        final minTeams = int.tryParse(_minTeamsController.text) ?? 2;
                        if (num < minTeams) return '>= $minTeams';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // ===== THỜI GIAN ĐĂNG KÝ =====
              _buildSectionTitle(context, 'Thời gian đăng ký', Icons.app_registration),
              const SizedBox(height: 8),
              Text(
                'Khoảng thời gian các đội có thể đăng ký tham gia giải đấu',
                style: TextStyle(
                  color: isDark ? colorScheme.onSurfaceVariant : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      'Mở đăng ký',
                      _registrationStartDate,
                      () => _selectDate(context, 'regStart'),
                      Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      'Đóng đăng ký',
                      _registrationEndDate,
                      () => _selectDate(context, 'regEnd'),
                      Icons.stop,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // ===== THỜI GIAN THI ĐẤU =====
              _buildSectionTitle(context, 'Thời gian thi đấu', Icons.sports_soccer),
              const SizedBox(height: 8),
              Text(
                'Thời gian diễn ra các trận đấu chính thức',
                style: TextStyle(
                  color: isDark ? colorScheme.onSurfaceVariant : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      'Ngày bắt đầu',
                      _startDate,
                      () => _selectDate(context, 'start'),
                      Icons.flag,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      'Ngày kết thúc',
                      _endDate,
                      () => _selectDate(context, 'end'),
                      Icons.emoji_flags,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // ===== THÔNG TIN BỔ SUNG =====
              _buildSectionTitle(context, 'Thông tin bổ sung', Icons.add_circle_outline),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Địa điểm thi đấu',
                  hintText: 'Ví dụ: Sân vận động Mỹ Đình, Hà Nội',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _prizeController,
                decoration: const InputDecoration(
                  labelText: 'Giải thưởng',
                  hintText: 'Ví dụ: Vô địch: 500 triệu VNĐ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _rulesController,
                decoration: const InputDecoration(
                  labelText: 'Điều lệ giải đấu',
                  hintText: 'Các quy định, luật thi đấu...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.rule_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Thông tin liên hệ',
                  hintText: 'Email, số điện thoại BTC...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // ===== NÚT TẠO =====
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _isLoading ? 'ĐANG TẠO...' : 'TẠO GIẢI ĐẤU',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context, 
    String label, 
    DateTime date, 
    VoidCallback onTap,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(
            fontSize: 15,
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
      ),
    );
  }
}
