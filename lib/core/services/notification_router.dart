import 'package:flutter/material.dart';
import '../model/notification_model.dart';

class NotificationRouter {
  static void navigateFromNotification(
    BuildContext context, {
    required String type,
    String? referenceId,
    Map<String, dynamic>? data,
  }) {
    final notifType = NotificationType.fromString(type);
    final refId = referenceId != null ? int.tryParse(referenceId) : null;

    switch (notifType) {
      case NotificationType.MEETING:
        if (refId != null) {
          Navigator.pushNamed(
            context,
            '/meeting-details',
            arguments: {'meetingId': refId},
          );
        } else {
          Navigator.pushNamed(context, '/meetings');
        }
        break;
      case NotificationType.MEETING_REPORT:
        Navigator.pushNamed(context, '/register-book');
        break;
      case NotificationType.PAYMENT:
        Navigator.pushNamed(context, '/transactions');
        break;
      case NotificationType.LOAN:
        Navigator.pushNamed(context, '/loans');
        break;
      case NotificationType.FINE:
        Navigator.pushNamed(context, '/fines');
        break;
      case NotificationType.ANNOUNCEMENT:
      case NotificationType.GENERAL:
      case NotificationType.TEST:
        //  Navigator.pushNamed(context, '/notifications');
        break;
    }
  }
}
