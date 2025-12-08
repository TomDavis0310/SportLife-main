import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../main.dart'; // Import for themeModeProvider

// Settings Providers
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final matchRemindersProvider = StateProvider<bool>((ref) => true);
final predictionResultsProvider = StateProvider<bool>((ref) => true);
final newsUpdatesProvider = StateProvider<bool>((ref) => false);
// darkModeProvider syncs with themeModeProvider
final darkModeProvider = StateProvider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
final languageProvider = StateProvider<String>((ref) => 'vi');
final biometricEnabledProvider = StateProvider<bool>((ref) => false);
final autoPlayVideoProvider = StateProvider<bool>((ref) => true);
final dataUsageProvider = StateProvider<String>((ref) => 'auto');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppTheme.getColors(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          _buildSectionHeader('TÀI KHOẢN'),
          _buildSettingsCard([
            _buildNavigationTile(
              context,
              icon: Icons.person_outline,
              title: 'Chỉnh sửa hồ sơ',
              subtitle: 'Cập nhật thông tin cá nhân',
              onTap: () => context.push('/profile/edit'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu tài khoản',
              onTap: () => _showChangePasswordDialog(context, ref),
            ),
            _buildSwitchTile(
              ref,
              icon: Icons.fingerprint,
              title: 'Đăng nhập sinh trắc học',
              subtitle: 'Sử dụng vân tay hoặc Face ID',
              provider: biometricEnabledProvider,
            ),
          ]),

          // Notifications Section
          _buildSectionHeader('THÔNG BÁO'),
          _buildSettingsCard([
            _buildSwitchTile(
              ref,
              icon: Icons.notifications_outlined,
              title: 'Thông báo',
              subtitle: 'Bật/tắt tất cả thông báo',
              provider: notificationsEnabledProvider,
            ),
            if (ref.watch(notificationsEnabledProvider)) ...[
              _buildSwitchTile(
                ref,
                icon: Icons.alarm,
                title: 'Nhắc nhở trận đấu',
                subtitle: 'Nhắc trước 30 phút khi trận đấu bắt đầu',
                provider: matchRemindersProvider,
              ),
              _buildSwitchTile(
                ref,
                icon: Icons.sports_score,
                title: 'Kết quả dự đoán',
                subtitle: 'Thông báo khi có kết quả dự đoán',
                provider: predictionResultsProvider,
              ),
              _buildSwitchTile(
                ref,
                icon: Icons.newspaper,
                title: 'Tin tức mới',
                subtitle: 'Cập nhật tin tức bóng đá',
                provider: newsUpdatesProvider,
              ),
            ],
            _buildNavigationTile(
              context,
              icon: Icons.schedule,
              title: 'Thời gian nhắc nhở',
              subtitle: 'Chọn thời gian nhắc trước trận đấu',
              onTap: () => _showReminderTimeDialog(context, ref),
            ),
          ]),

          // Appearance Section
          _buildSectionHeader('GIAO DIỆN'),
          _buildSettingsCard([
            _buildSwitchTile(
              ref,
              icon: Icons.dark_mode,
              title: 'Chế độ tối',
              subtitle: 'Sử dụng giao diện tối',
              provider: darkModeProvider,
            ),
            _buildNavigationTile(
              context,
              icon: Icons.language,
              title: 'Ngôn ngữ',
              subtitle: ref.watch(languageProvider) == 'vi' 
                  ? 'Tiếng Việt' 
                  : 'English',
              onTap: () => _showLanguageDialog(context, ref),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.text_fields,
              title: 'Cỡ chữ',
              subtitle: 'Mặc định',
              onTap: () => _showFontSizeDialog(context),
            ),
          ]),

          // Data & Storage Section
          _buildSectionHeader('DỮ LIỆU & LƯU TRỮ'),
          _buildSettingsCard([
            _buildSwitchTile(
              ref,
              icon: Icons.play_circle_outline,
              title: 'Tự động phát video',
              subtitle: 'Tự động phát video highlight',
              provider: autoPlayVideoProvider,
            ),
            _buildNavigationTile(
              context,
              icon: Icons.data_usage,
              title: 'Sử dụng dữ liệu',
              subtitle: _getDataUsageText(ref.watch(dataUsageProvider)),
              onTap: () => _showDataUsageDialog(context, ref),
            ),
            _buildActionTile(
              icon: Icons.download,
              title: 'Tải xuống dữ liệu',
              subtitle: 'Tải xuống dữ liệu cá nhân',
              onTap: () => _downloadData(context),
            ),
            _buildActionTile(
              icon: Icons.delete_sweep,
              title: 'Xóa bộ nhớ đệm',
              subtitle: 'Dung lượng: 45.2 MB',
              onTap: () => _showClearCacheDialog(context),
            ),
          ]),

          // Privacy & Security Section
          _buildSectionHeader('QUYỀN RIÊNG TƯ & BẢO MẬT'),
          _buildSettingsCard([
            _buildNavigationTile(
              context,
              icon: Icons.visibility_outlined,
              title: 'Quyền riêng tư hồ sơ',
              subtitle: 'Ai có thể xem hồ sơ của bạn',
              onTap: () => _showPrivacyDialog(context),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.block,
              title: 'Danh sách chặn',
              subtitle: 'Quản lý người dùng bị chặn',
              onTap: () => context.push('/blocked-users'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.devices,
              title: 'Thiết bị đăng nhập',
              subtitle: 'Quản lý các thiết bị đã đăng nhập',
              onTap: () => _showDevicesDialog(context),
            ),
          ]),

          // About Section
          _buildSectionHeader('THÔNG TIN'),
          _buildSettingsCard([
            _buildNavigationTile(
              context,
              icon: Icons.description_outlined,
              title: 'Điều khoản dịch vụ',
              subtitle: null,
              onTap: () => _openUrl('https://sportlife.app/terms'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách bảo mật',
              subtitle: null,
              onTap: () => _openUrl('https://sportlife.app/privacy'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.help_outline,
              title: 'Trung tâm trợ giúp',
              subtitle: null,
              onTap: () => context.push('/help'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.star_outline,
              title: 'Đánh giá ứng dụng',
              subtitle: 'Hỗ trợ chúng tôi trên App Store',
              onTap: () => _rateApp(context),
            ),
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'Phiên bản',
              value: '1.0.0 (Build 1)',
            ),
          ]),

          // Danger Zone
          _buildSectionHeader('NGUY HIỂM'),
          _buildSettingsCard([
            _buildActionTile(
              icon: Icons.logout,
              title: 'Đăng xuất',
              subtitle: 'Đăng xuất khỏi tài khoản',
              textColor: Colors.orange,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            _buildActionTile(
              icon: Icons.delete_forever,
              title: 'Xóa tài khoản',
              subtitle: 'Xóa vĩnh viễn tài khoản và dữ liệu',
              textColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Builder(
      builder: (context) {
        final colors = AppTheme.getColors(context);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        color: colors.divider,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = AppTheme.getColors(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: colors.textHint),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required StateProvider<bool> provider,
  }) {
    final colors = AppTheme.getColors(ref.context);
    
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: colors.textSecondary,
        ),
      ),
      value: ref.watch(provider),
      activeColor: AppTheme.primary,
      onChanged: (value) {
        ref.read(provider.notifier).state = value;
        // Sync dark mode with theme provider
        if (provider == darkModeProvider) {
          ref.read(themeModeProvider.notifier).state = 
              value ? ThemeMode.dark : ThemeMode.light;
        }
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Builder(
      builder: (context) {
        final colors = AppTheme.getColors(context);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (textColor ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: textColor ?? AppTheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor ?? colors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: textColor?.withOpacity(0.7) ?? colors.textSecondary,
            ),
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Builder(
      builder: (context) {
        final colors = AppTheme.getColors(context);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          trailing: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  String _getDataUsageText(String value) {
    switch (value) {
      case 'wifi':
        return 'Chỉ Wi-Fi';
      case 'mobile':
        return 'Wi-Fi & Di động';
      case 'auto':
      default:
        return 'Tự động';
    }
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_clock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đổi mật khẩu thành công!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  void _showReminderTimeDialog(BuildContext context, WidgetRef ref) {
    String selectedTime = '30';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thời gian nhắc nhở'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nhắc trước khi trận đấu bắt đầu:'),
              const SizedBox(height: 16),
              ...['15', '30', '60', '120'].map((time) {
                final label = time == '120' ? '2 giờ' : '$time phút';
                return RadioListTile<String>(
                  title: Text(label),
                  value: time,
                  groupValue: selectedTime,
                  activeColor: AppTheme.primary,
                  onChanged: (value) {
                    setState(() => selectedTime = value!);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã cập nhật thời gian nhắc nhở: ${selectedTime == '120' ? '2 giờ' : '$selectedTime phút'}',
                  ),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
              title: const Text('Tiếng Việt'),
              trailing: ref.watch(languageProvider) == 'vi'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).state = 'vi';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: ref.watch(languageProvider) == 'en'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).state = 'en';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cỡ chữ'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Nhỏ', 'Mặc định', 'Lớn', 'Rất lớn'].map((size) {
            return ListTile(
              title: Text(size),
              trailing: size == 'Mặc định'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn cỡ chữ: $size'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDataUsageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sử dụng dữ liệu'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tự động'),
              subtitle: const Text('Tự động điều chỉnh theo mạng'),
              trailing: ref.watch(dataUsageProvider) == 'auto'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                ref.read(dataUsageProvider.notifier).state = 'auto';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Chỉ Wi-Fi'),
              subtitle: const Text('Tiết kiệm dữ liệu di động'),
              trailing: ref.watch(dataUsageProvider) == 'wifi'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                ref.read(dataUsageProvider.notifier).state = 'wifi';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Wi-Fi & Di động'),
              subtitle: const Text('Luôn tải nội dung'),
              trailing: ref.watch(dataUsageProvider) == 'mobile'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                ref.read(dataUsageProvider.notifier).state = 'mobile';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chuẩn bị dữ liệu, bạn sẽ nhận email khi hoàn tất'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ đệm'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Bạn có chắc muốn xóa bộ nhớ đệm? Thao tác này sẽ xóa các tệp tạm thời để giải phóng dung lượng.',
        ),
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
                  content: Text('Đã xóa bộ nhớ đệm thành công!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quyền riêng tư hồ sơ'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Công khai'),
              subtitle: const Text('Mọi người có thể xem'),
              trailing: const Icon(Icons.check, color: AppTheme.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Bạn bè'),
              subtitle: const Text('Chỉ bạn bè có thể xem'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Riêng tư'),
              subtitle: const Text('Chỉ bạn có thể xem'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết bị đăng nhập'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android, color: AppTheme.primary),
              title: const Text('iPhone 14'),
              subtitle: const Text('Đang hoạt động'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Hiện tại',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.laptop, color: AppTheme.darkGrey),
              title: const Text('Chrome - Windows'),
              subtitle: const Text('Đăng nhập 2 ngày trước'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất tất cả thiết bị khác'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất tất cả'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cảm ơn bạn đã đánh giá ứng dụng!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
              style: TextStyle(color: AppTheme.darkGrey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhập "XÓA TÀI KHOẢN" để xác nhận:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'XÓA TÀI KHOẢN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'XÓA TÀI KHOẢN') {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tài khoản đã được xóa'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập đúng để xác nhận'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }
}
