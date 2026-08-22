class MeetingMemberModel {
  final int id;
  final int meetingId;
  final int memberId;
  final String memberNumber;
  final String fullName;
  final String processingStatus;
  final String? processedAt;

  MeetingMemberModel({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.processingStatus,
    this.processedAt,
  });

  factory MeetingMemberModel.fromJson(Map<String, dynamic> json) {
    return MeetingMemberModel(
      id: json['id'] ?? 0,
      meetingId: json['meetingId'] ?? 0,
      memberId: json['memberId'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      processingStatus: json['processingStatus'] ?? 'PENDING',
      processedAt: json['processedAt'],
    );
  }
}
