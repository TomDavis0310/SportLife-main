import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'SportLife';
  static const String appVersion = '1.0.0';

  // API Configuration
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.sportlife.com/api/v1';
    }
    if (kIsWeb) {
      // Use localhost instead of 127.0.0.1 for better CORS compatibility
      return 'http://localhost:8000/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get imageUrl {
    final base = baseUrl;
    return base.replaceAll('/api/v1', '');
  }

  // Pusher Configuration
  static const String pusherAppId = 'your-pusher-app-id';
  static const String pusherKey = 'your-pusher-key';
  static const String pusherSecret = 'your-pusher-secret';
  static const String pusherCluster = 'ap1';

  // Social Auth
  static const String googleClientId = 'your-google-client-id';
  static const String appleClientId = 'your-apple-client-id';

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Points Configuration
  static const int pointsExactScore = 10;
  static const int pointsCorrectOutcome = 5;
  static const int pointsGoalDifference = 3;
}

