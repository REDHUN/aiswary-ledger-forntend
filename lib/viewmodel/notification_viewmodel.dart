import 'package:flutter/foundation.dart';
import '../core/model/broadcast_notification_model.dart';
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

  static const List<NotificationTemplate> templates = [
    NotificationTemplate(
      labelMl: 'യോഗ അറിയിപ്പ്',
      labelEn: 'Meeting Reminder',
      titleMl: 'പ്രധാന യോഗ അറിയിപ്പ്',
      titleEn: 'Important Meeting Notice',
      bodyMl: 'അടുത്ത ഐശ്വര്യ സംഘം യോഗം നിശ്ചിത തീയതിയിൽ കൃത്യസമയത്ത് ആരംഭിക്കുന്നതാണ്. എല്ലാ അംഗങ്ങളും പങ്കെടുക്കുക.',
      bodyEn: 'The next Aiswarya Sangham meeting will start on schedule. All members are requested to attend on time.',
      type: 'MEETING_REMINDER',
    ),
    NotificationTemplate(
      labelMl: 'അടവ് ഓർമ്മപ്പെടുത്തൽ',
      labelEn: 'Payment Reminder',
      titleMl: 'മാസ അടവ് ഓർമ്മപ്പെടുത്തൽ',
      titleEn: 'Monthly Payment Reminder',
      bodyMl: 'ഈ മാസത്തെ വരിസംഖ്യയും വായ്പാ തിരിച്ചടവുകളും യോഗത്തിൽ കൃത്യമായി അടയ്ക്കണമെന്ന് അഭ്യർത്ഥിക്കുന്നു.',
      bodyEn: 'Please ensure your monthly contributions and loan repayments are submitted during the upcoming meeting.',
      type: 'PAYMENT_REMINDER',
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
    NotificationTemplate(
      labelMl: 'സമയ മാറ്റം',
      labelEn: 'Schedule Update',
      titleMl: 'യോഗ സമയത്തിൽ മാറ്റം',
      titleEn: 'Meeting Schedule Rescheduled',
      bodyMl: 'പ്രത്യേക കാരണങ്ങളാൽ യോഗ സമയത്തിൽ മാറ്റം വന്നിരിക്കുന്നു. വിവരങ്ങൾക്ക് ആപ്പ് പരിശോധിക്കുക.',
      bodyEn: 'The meeting time has been rescheduled. Please check the app for the updated timing.',
      type: 'SCHEDULE_UPDATE',
    ),
  ];

  NotificationViewModel(this._repository);

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

  void clearResult() {
    _lastResult = null;
    loadState.clear();
    notifyListeners();
  }
}
