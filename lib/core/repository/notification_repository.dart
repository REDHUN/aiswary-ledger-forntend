import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/notification_model.dart';
import '../model/broadcast_notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  /// Fetch paginated user notifications
  Future<List<NotificationItem>> getNotifications({int page = 0, int size = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    if (response is Map && response['success'] == true && response['data'] != null) {
      final data = response['data'];
      List<dynamic> content = [];
      if (data is List) {
        content = data;
      } else if (data is Map && data['content'] is List) {
        content = data['content'] as List<dynamic>;
      }
      return content
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.notificationUnreadCount);
    if (response is Map && response['success'] == true && response['data'] != null) {
      if (response['data'] is Map) {
        return (response['data']['unreadCount'] as num?)?.toInt() ?? 0;
      } else if (response['data'] is num) {
        return (response['data'] as num).toInt();
      }
    }
    return 0;
  }

  /// Mark single notification as read
  Future<NotificationItem?> markAsRead(int id) async {
    final response = await _apiClient.patch(ApiEndpoints.markNotificationAsRead(id));
    if (response is Map && response['success'] == true && response['data'] != null) {
      return NotificationItem.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Mark all notifications as read
  Future<int> markAllAsRead() async {
    final response = await _apiClient.patch(ApiEndpoints.markAllNotificationsAsRead);
    if (response is Map && response['success'] == true) {
      if (response['data'] is Map) {
        return (response['data']?['updatedCount'] as num?)?.toInt() ?? 0;
      }
      return 0;
    }
    return 0;
  }

  /// Admin: Create and send notification
  Future<bool> sendNotification({
    int? userId,
    bool broadcast = false,
    required String title,
    required String body,
    required String notificationType,
    int? referenceId,
    Map<String, String>? data,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.notifications,
      data: {
        'userId': ?userId,
        'broadcast': broadcast,
        'title': title,
        'body': body,
        'notificationType': notificationType,
        'referenceId': ?referenceId,
        'data': ?data,
      },
    );
    return response is Map && response['success'] == true;
  }

  /// Send broadcast notification (legacy / admin tool)
  Future<BroadcastNotificationResult> sendBroadcast({
    required String title,
    required String body,
    String type = 'ANNOUNCEMENT',
    Map<String, dynamic>? extraData,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'body': body,
      'data': {
        'type': type,
        ...?extraData,
      },
    };

    final response = await _apiClient.request(
      path: ApiEndpoints.broadcastNotification,
      method: RequestType.post,
      body: payload,
    );

    if (response is Map && response['data'] != null && response['data'] is Map<String, dynamic>) {
      return BroadcastNotificationResult.fromJson(response['data']);
    }

    return BroadcastNotificationResult(
      totalTargeted: 0,
      successCount: 0,
      failureCount: 0,
      status: (response is Map && response['success'] == true) ? 'SUCCESS' : 'FAILURE',
      message: response is Map ? response['message']?.toString() : null,
    );
  }

  /// Send test notification to own device
  Future<bool> sendTestToMyDevice() async {
    final response = await _apiClient.post(ApiEndpoints.testMyDevice);
    return response is Map && response['success'] == true;
  }

  /// Send general test notification
  Future<bool> sendTestNotification() async {
    final response = await _apiClient.post(ApiEndpoints.testNotification);
    return response is Map && response['success'] == true;
  }
}
