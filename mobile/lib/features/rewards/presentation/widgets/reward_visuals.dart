import 'package:flutter/material.dart';

import '../../data/models/reward.dart';

class RewardVisuals {
  // High-quality images for each reward type
  static const Map<String, String> _imageByType = {
    'voucher':
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=900&q=80',
    'physical':
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80',
    'ticket':
        'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=900&q=80',
    'virtual':
        'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?auto=format&fit=crop&w=900&q=80',
    'gear':
        'https://images.unsplash.com/photo-1614632537190-23e4146777db?auto=format&fit=crop&w=900&q=80',
    'membership':
        'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=900&q=80',
    'food':
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&q=80',
    'drink':
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=900&q=80',
  };

  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80',
  ];

  // Vibrant gradients for each type
  static const Map<String, List<Color>> _gradientByType = {
    'voucher': [Color(0xFFFA709A), Color(0xFFFEE140)],
    'physical': [Color(0xFF00C6FB), Color(0xFF005BEA)],
    'ticket': [Color(0xFFFFA17F), Color(0xFFFF357F)],
    'virtual': [Color(0xFF7F53AC), Color(0xFF647DEE)],
    'gear': [Color(0xFF00C6FB), Color(0xFF005BEA)],
    'membership': [Color(0xFF7F53AC), Color(0xFF647DEE)],
    'food': [Color(0xFFFF9A8B), Color(0xFFFAD0C4)],
    'drink': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  };

  // Vietnamese labels
  static const Map<String, String> _labelByType = {
    'voucher': 'Mã giảm giá',
    'physical': 'Quà vật lý',
    'ticket': 'Vé sự kiện',
    'virtual': 'Gói Premium',
    'gear': 'Phụ kiện',
    'membership': 'Thẻ thành viên',
    'food': 'Ẩm thực',
    'drink': 'Đồ uống',
  };

  // Icons for each type
  static const Map<String, IconData> _iconByType = {
    'voucher': Icons.confirmation_num_outlined,
    'physical': Icons.redeem,
    'ticket': Icons.local_activity_outlined,
    'virtual': Icons.workspace_premium_outlined,
    'gear': Icons.sports_basketball,
    'membership': Icons.card_membership,
    'food': Icons.restaurant,
    'drink': Icons.local_cafe,
  };

  /// Returns the image URL for a reward.
  /// Priority: reward.imageUrl → type-based image → fallback
  static String imageFor(Reward reward) {
    // If the reward has a valid image URL (http/https), use it
    if (reward.imageUrl != null && reward.imageUrl!.isNotEmpty) {
      final url = reward.imageUrl!;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
    }

    // Fall back to type-based image
    final normalized = _normalize(reward.type);
    if (_imageByType.containsKey(normalized)) {
      return _imageByType[normalized]!;
    }

    // Last resort: deterministic fallback based on ID
    final index = reward.id % _fallbackImages.length;
    return _fallbackImages[index];
  }

  /// Returns the gradient colors for a reward type
  static List<Color> gradientForType(String type) {
    final normalized = _normalize(type);
    return _gradientByType[normalized] ??
        const [Color(0xFF485563), Color(0xFF29323C)];
  }

  /// Returns the Vietnamese label for a reward type
  static String labelForType(String type) {
    final normalized = _normalize(type);
    if (normalized.isEmpty) return 'Khác';
    return _labelByType[normalized] ?? _capitalize(type);
  }

  /// Returns the icon for a reward type
  static IconData iconForType(String type) {
    final normalized = _normalize(type);
    return _iconByType[normalized] ?? Icons.card_giftcard;
  }

  /// Returns a description for a reward type (for category headers)
  static String descriptionForType(String type) {
    final normalized = _normalize(type);
    switch (normalized) {
      case 'voucher':
        return 'Mã giảm giá từ các thương hiệu đối tác';
      case 'physical':
        return 'Quà tặng vật lý được giao tận nhà';
      case 'ticket':
        return 'Vé xem trận đấu & sự kiện thể thao';
      case 'virtual':
        return 'Gói đăng ký và dịch vụ số';
      default:
        return 'Các phần thưởng hấp dẫn khác';
    }
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
