import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _matchReminders = true;
  bool _predictionResults = true;
  bool _newsUpdates = false;
  bool _darkMode = true;
  String _language = 'vi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Thông báo'),
          SwitchListTile(
            title: const Text('Thông báo'),
            subtitle: const Text('Bật/tắt tất cả thông báo'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          if (_notificationsEnabled) ...[
            SwitchListTile(
              title: const Text('Nhắc nhở trận đấu'),
              subtitle: const Text('Nhắc trước khi trận đấu bắt đầu'),
              value: _matchReminders,
              onChanged: (value) {
                setState(() => _matchReminders = value);
              },
            ),
            SwitchListTile(
              title: const Text('Kết quả dự đoán'),
              subtitle: const Text('Thông báo khi có kết quả dự đoán'),
              value: _predictionResults,
              onChanged: (value) {
                setState(() => _predictionResults = value);
              },
            ),
            SwitchListTile(
              title: const Text('Tin tức mới'),
              subtitle: const Text('Cập nhật tin tức mới nhất'),
              value: _newsUpdates,
              onChanged: (value) {
                setState(() => _newsUpdates = value);
              },
            ),
          ],

          const Divider(),

          // Appearance Section
          _buildSectionHeader('Giao diện'),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Sử dụng giao diện tối'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),
          ListTile(
            title: const Text('Ngôn ngữ'),
            subtitle: Text(_language == 'vi' ? 'Tiếng Việt' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader('Dữ liệu'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Tải xuống dữ liệu'),
            subtitle: const Text('Tải xuống dữ liệu cá nhân của bạn'),
            onTap: () {
              // Download data
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('Xóa bộ nhớ đệm'),
            subtitle: const Text('Xóa dữ liệu tạm thời'),
            onTap: _clearCache,
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('Thông tin'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Điều khoản dịch vụ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Chính sách bảo mật'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Phiên bản'),
            subtitle: const Text('1.0.0 (Build 1)'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ đệm'),
        content: const Text('Bạn có chắc muốn xóa bộ nhớ đệm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa bộ nhớ đệm'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

