import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

// Notification API Provider
final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(dioProvider));
});

// Notifications List Provider
final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(notificationApiProvider).getNotifications();
});

// Unread Count Provider
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(notificationApiProvider).getUnreadCount();
});

class NotificationApi {
  final dynamic _dio;

  NotificationApi(this._dio);

  Future<List<dynamic>> getNotifications({int page = 1}) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {'page': page},
    );
    return response.data['data'] ?? [];
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data['count'] ?? 0;
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.post('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/notifications/read-all');
  }

  Future<void> deleteNotification(int notificationId) async {
    await _dio.delete('/notifications/$notificationId');
  }

  Future<void> updateFcmToken(String token) async {
    await _dio.post('/notifications/fcm-token', data: {'token': token});
  }
}

