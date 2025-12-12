import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../../data/api/tournament_api.dart';
import '../../../../core/network/dio_client.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _seasonNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _type = 'league';
  String _roundType = 'round_robin'; // New field for round type
  int _maxTeams = 16;
  DateTime _startDate = DateTime.now().add(const Duration(days: 30));
  DateTime _endDate = DateTime.now().add(const Duration(days: 120));
  bool _isLoading = false;

  // Round type options with Vietnamese labels
  final List<Map<String, String>> _roundTypes = const [
    {'value': 'round_robin', 'label': 'Vòng tròn', 'desc': 'Mỗi đội gặp nhau 1 hoặc 2 lần'},
    {'value': 'group_stage', 'label': 'Vòng bảng', 'desc': 'Chia bảng, đấu vòng tròn trong bảng'},
    {'value': 'knockout', 'label': 'Loại trực tiếp', 'desc': 'Thua là bị loại'},
    {'value': 'league', 'label': 'Giải vô địch', 'desc': 'Đấu vòng tròn 2 lượt'},
    {'value': 'mixed', 'label': 'Kết hợp', 'desc': 'Vòng bảng + Loại trực tiếp'},
  ];

  @override
  void initState() {
    super.initState();
    _seasonNameController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seasonNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Giải đấu mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tournament name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên giải đấu *',
                hintText: 'VD: Giải bóng đá sinh viên 2025',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emoji_events),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên giải đấu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tournament type
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Loại giải đấu *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'league', child: Text('Giải vô địch (League)')),
                DropdownMenuItem(value: 'cup', child: Text('Cúp (Cup)')),
              ],
              onChanged: (value) {
                setState(() => _type = value ?? 'league');
              },
            ),
            const SizedBox(height: 16),

            // Round type (NEW) - Hình thức thi đấu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sports_soccer, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Hình thức thi đấu *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._roundTypes.map((rt) => RadioListTile<String>(
                    value: rt['value']!,
                    groupValue: _roundType,
                    title: Text(rt['label']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(rt['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      setState(() => _roundType = value ?? 'round_robin');
                    },
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Season name
            TextFormField(
              controller: _seasonNameController,
              decoration: const InputDecoration(
                labelText: 'Mùa giải *',
                hintText: 'VD: 2025',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên mùa giải';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Max teams
            Text(
              'Số đội tối đa: $_maxTeams',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _maxTeams.toDouble(),
              min: 4,
              max: 32,
              divisions: 14,
              label: '$_maxTeams đội',
              onChanged: (value) {
                setState(() => _maxTeams = value.toInt());
              },
            ),
            Wrap(
              spacing: 8,
              children: [4, 8, 12, 16, 20, 24, 32].map((n) {
                return ChoiceChip(
                  label: Text('$n'),
                  selected: _maxTeams == n,
                  onSelected: (selected) {
                    if (selected) setState(() => _maxTeams = n);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Start date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Ngày bắt đầu'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _selectDate(true),
            ),
            const Divider(),

            // End date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: const Text('Ngày kết thúc'),
              subtitle: Text(
                '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _selectDate(false),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'Nhập mô tả về giải đấu...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTournament,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Tạo Giải đấu',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = isStart 
        ? DateTime.now() 
        : _startDate.add(const Duration(days: 1));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 90));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = TournamentApi(ref.read(dioProvider));
      await api.createTournament(
        name: _nameController.text,
        type: _type,
        roundType: _roundType,
        seasonName: _seasonNameController.text,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
        maxTeams: _maxTeams,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
      );

      if (mounted) {
        ref.invalidate(tournamentsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo giải đấu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
