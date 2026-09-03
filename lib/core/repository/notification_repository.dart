import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/broadcast_notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

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

    if (response['data'] != null && response['data'] is Map<String, dynamic>) {
      return BroadcastNotificationResult.fromJson(response['data']);
    }

    return BroadcastNotificationResult(
      totalTargeted: 0,
      successCount: 0,
      failureCount: 0,
      status: response['success'] == true ? 'SUCCESS' : 'FAILURE',
      message: response['message']?.toString(),
    );
  }
}
