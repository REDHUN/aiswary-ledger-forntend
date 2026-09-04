enum NotificationType {
  MEETING,
  MEETING_REPORT,
  PAYMENT,
  LOAN,
  FINE,
  GENERAL,
  ANNOUNCEMENT,
  TEST;

  static NotificationType fromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'MEETING':
        return NotificationType.MEETING;
      case 'MEETING_REPORT':
      case 'MEETING REPORT':
      case 'MEETINGREPORT':
      case 'REGISTER_BOOK':
      case 'REGISTERBOOK':
        return NotificationType.MEETING_REPORT;
      case 'PAYMENT':
        return NotificationType.PAYMENT;
      case 'LOAN':
        return NotificationType.LOAN;
      case 'FINE':
        return NotificationType.FINE;
      case 'ANNOUNCEMENT':
        return NotificationType.ANNOUNCEMENT;
      case 'TEST':
        return NotificationType.TEST;
      default:
        return NotificationType.GENERAL;
    }
  }
}

class NotificationItem {
  final int id;
  final int? userId;
  final String title;
  final String body;
  final NotificationType notificationType;
  final int? referenceId;
  final Map<String, String> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationItem({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.notificationType,
    this.referenceId,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedData = {};
    if (json['data'] != null && json['data'] is Map) {
      (json['data'] as Map).forEach((key, value) {
        if (key != null && value != null) {
          parsedData[key.toString()] = value.toString();
        }
      });
    }

    return NotificationItem(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int?,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      notificationType: NotificationType.fromString(
        json['notificationType']?.toString(),
      ),
      referenceId: json['referenceId'] as int?,
      data: parsedData,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      body: body,
      notificationType: notificationType,
      referenceId: referenceId,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
