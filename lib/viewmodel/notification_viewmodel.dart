import 'package:flutter/foundation.dart';
import '../core/model/broadcast_notification_model.dart';
import '../core/model/notification_model.dart';
import '../core/repository/notification_repository.dart';
import '../core/state/load_state.dart';

class NotificationTemplate {
  final String labelMl;
  final String labelEn;
  final String titleMl;
  final String titleEn;
  final String bodyMl;
  final String bodyEn;
  final String type;

  const NotificationTemplate({
    required this.labelMl,
    required this.labelEn,
    required this.titleMl,
    required this.titleEn,
    required this.bodyMl,
    required this.bodyEn,
    required this.type,
  });
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;
  final LoadState loadState = LoadState();

  BroadcastNotificationResult? _lastResult;
  BroadcastNotificationResult? get lastResult => _lastResult;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  static const List<NotificationTemplate> templates = [
    NotificationTemplate(
      labelMl: 'യോഗ അറിയിപ്പ്',
      labelEn: 'Meeting Notice',
      titleMl: 'പ്രധാന യോഗ അറിയിപ്പ്',
      titleEn: 'Important Meeting Notice',
      bodyMl: 'അടുത്ത ഐശ്വര്യ സംഘം യോഗം നിശ്ചിത തീയതിയിൽ കൃത്യസമയത്ത് ആരംഭിക്കുന്നതാണ്. എല്ലാ അംഗങ്ങളും പങ്കെടുക്കുക.',
      bodyEn: 'The next Aiswarya Sangham meeting will start on schedule. All members are requested to attend on time.',
      type: 'MEETING',
    ),
    NotificationTemplate(
      labelMl: 'അടവ് ഓർമ്മപ്പെടുത്തൽ',
      labelEn: 'Payment Reminder',
      titleMl: 'മാസ അടവ് ഓർമ്മപ്പെടുത്തൽ',
      titleEn: 'Monthly Payment Reminder',
      bodyMl: 'ഈ മാസത്തെ വരിസംഖ്യയും വായ്പാ തിരിച്ചടവുകളും യോഗത്തിൽ കൃത്യമായി അടയ്ക്കണമെന്ന് അഭ്യർത്ഥിക്കുന്നു.',
      bodyEn: 'Please ensure your monthly contributions and loan repayments are submitted during the upcoming meeting.',
      type: 'PAYMENT',
    ),
    NotificationTemplate(
      labelMl: 'വായ്പ അറിയിപ്പ്',
      labelEn: 'Loan Notice',
      titleMl: 'വായ്പ സംബന്ധിച്ച വിവരം',
      titleEn: 'Loan Update Notification',
      bodyMl: 'നിങ്ങളുടെ വായ്പാ അക്കൗണ്ടുമായി ബന്ധപ്പെട്ട പുതിയ വിവരം ലഭ്യമായിട്ടുണ്ട്. പരിശോധിക്കുക.',
      bodyEn: 'An update regarding your loan account is available. Please check the ledger for details.',
      type: 'LOAN',
    ),
    NotificationTemplate(
      labelMl: 'പിഴ അറിയിപ്പ്',
      labelEn: 'Fine Alert',
      titleMl: 'യോഗം / അടവ് പിഴ അറിയിപ്പ്',
      titleEn: 'Fine Notice',
      bodyMl: 'കഴിഞ്ഞ യോഗത്തിൽ പങ്കെടുക്കാത്തതിനാലോ അടവ് മുടങ്ങിയതിനാലോ പിഴ രേഖപ്പെടുത്തിയിട്ടുണ്ട്.',
      bodyEn: 'A fine has been recorded for meeting absence or payment delay. Please review your account.',
      type: 'FINE',
    ),
    NotificationTemplate(
      labelMl: 'പൊതു അറിയിപ്പ്',
      labelEn: 'Announcement',
      titleMl: 'ഐശ്വര്യ സംഘം അറിയിപ്പ്',
      titleEn: 'Important Announcement',
      bodyMl: 'സംഘത്തിലെ എല്ലാ അംഗങ്ങളുടെയും ശ്രദ്ധയ്ക്കായി പുതിയ അറിയിപ്പ് പ്രസിദ്ധീകരിച്ചിരിക്കുന്നു.',
      bodyEn: 'A new announcement has been published for all members of Aiswarya Sangham.',
      type: 'ANNOUNCEMENT',
    ),
  ];

  NotificationViewModel(this._repository);

  /// Fetch unread notifications count
  Future<int> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
      return _unreadCount;
    } catch (_) {
      return _unreadCount;
    }
  }

  /// Fetch user notifications
  Future<List<NotificationItem>> fetchNotifications({int page = 0, int size = 20}) async {
    loadState.loading();
    notifyListeners();

    try {
      final items = await _repository.getNotifications(page: page, size: size);
      if (page == 0) {
        _notifications = items;
      } else {
        _notifications.addAll(items);
      }
      loadState.success();
      return items;
    } catch (e) {
      loadState.error(e.toString());
      return [];
    } finally {
      notifyListeners();
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Admin: Send targeted or broadcast notification
  Future<bool> sendNotification({
    int? userId,
    bool broadcast = false,
    required String title,
    required String body,
    required String notificationType,
    int? referenceId,
    Map<String, String>? data,
  }) async {
    loadState.loading();
    notifyListeners();

    try {
      final success = await _repository.sendNotification(
        userId: userId,
        broadcast: broadcast,
        title: title.trim(),
        body: body.trim(),
        notificationType: notificationType,
        referenceId: referenceId,
        data: data,
      );

      if (success) {
        loadState.success('Notification sent successfully');
      } else {
        loadState.error('Failed to send notification');
      }
      return success;
    } catch (e) {
      loadState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Send broadcast notification (legacy / admin tool)
  Future<BroadcastNotificationResult?> sendBroadcast({
    required String title,
    required String body,
    String type = 'ANNOUNCEMENT',
    Map<String, dynamic>? extraData,
  }) async {
    loadState.loading();
    _lastResult = null;
    notifyListeners();

    try {
      final result = await _repository.sendBroadcast(
        title: title.trim(),
        body: body.trim(),
        type: type,
        extraData: extraData,
      );
      _lastResult = result;
      loadState.success(result.message ?? 'Notification broadcast sent successfully');
      return result;
    } catch (e) {
      loadState.error(e.toString());
      return null;
    } finally {
      notifyListeners();
    }
  }

  /// Send test notification to own device
  Future<bool> sendTestToMyDevice() async {
    loadState.loading();
    notifyListeners();

    try {
      final success = await _repository.sendTestToMyDevice();
      if (success) {
        loadState.success('Test notification sent to your device!');
      } else {
        loadState.error('Failed to send test notification');
      }
      return success;
    } catch (e) {
      loadState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }

  void clearResult() {
    _lastResult = null;
    loadState.clear();
    notifyListeners();
  }
}
