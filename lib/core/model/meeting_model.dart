class MeetingModel {
  final int id;
  final int meetingNumber;
  final String meetingDate;
  final String status;
  final String interestPeriod;
  final bool isFirstMeetingOfMonth;
  final String? notes;
  final String? openedAt;
  final String? completedAt;
  final int totalMembers;
  final int processedMembers;
  final int pendingMembers;

  MeetingModel({
    required this.id,
    required this.meetingNumber,
    required this.meetingDate,
    required this.status,
    required this.interestPeriod,
    required this.isFirstMeetingOfMonth,
    this.notes,
    this.openedAt,
    this.completedAt,
    required this.totalMembers,
    required this.processedMembers,
    required this.pendingMembers,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] ?? 0,
      meetingNumber: json['meetingNumber'] ?? 0,
      meetingDate: json['meetingDate'] ?? '',
      status: json['status'] ?? 'SCHEDULED',
      interestPeriod: json['interestPeriod'] ?? '',
      isFirstMeetingOfMonth: json['isFirstMeetingOfMonth'] ?? false,
      notes: json['notes'],
      openedAt: json['openedAt'],
      completedAt: json['completedAt'],
      totalMembers: json['totalMembers'] ?? 0,
      processedMembers: json['processedMembers'] ?? 0,
      pendingMembers: json['pendingMembers'] ?? 0,
    );
  }
}
