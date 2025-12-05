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
  final _nameController = TextEditingController();
  final _seasonController = TextEditingController(text: '2025');
  String _selectedType = 'league';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 90));
          }
        } else {
          _endDate = picked;
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
            seasonName: _seasonController.text,
            startDate: _startDate.toIso8601String(),
            endDate: _endDate.toIso8601String(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo giải đấu thành công!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
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
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên giải đấu',
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
                  labelText: 'Loại giải đấu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'league', child: Text('Giải Vô Địch (League)')),
                  DropdownMenuItem(value: 'cup', child: Text('Cúp (Cup)')),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Thông tin mùa giải'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(
                  labelText: 'Tên mùa giải',
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
                    child: _buildDatePicker(
                      context,
                      'Ngày bắt đầu',
                      _startDate,
                      () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      'Ngày kết thúc',
                      _endDate,
                      () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
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
                          'TẠO GIẢI ĐẤU',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.date_range),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
