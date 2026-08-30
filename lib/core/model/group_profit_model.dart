class GroupProfitModel {
  final int id;
  final String title;
  final double amount;
  final String profitDate;
  final String? description;
  final int? meetingId;
  final String? createdAt;

  GroupProfitModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.profitDate,
    this.description,
    this.meetingId,
    this.createdAt,
  });

  factory GroupProfitModel.fromJson(Map<String, dynamic> json) {
    return GroupProfitModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] ?? 'Group Profit',
      amount: (json['amount'] as num).toDouble(),
      profitDate: json['profitDate'] ?? '',
      description: json['description'],
      meetingId: json['meetingId'] != null ? (json['meetingId'] as num).toInt() : null,
      createdAt: json['createdAt'],
    );
  }
}
