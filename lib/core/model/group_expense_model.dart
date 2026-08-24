class GroupExpenseModel {
  final int id;
  final int expenseTypeId;
  final String expenseTypeName;
  final double amount;
  final String expenseDate;
  final String? description;
  final int? meetingId;

  GroupExpenseModel({
    required this.id,
    required this.expenseTypeId,
    required this.expenseTypeName,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.meetingId,
  });

  factory GroupExpenseModel.fromJson(Map<String, dynamic> json) {
    return GroupExpenseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      expenseTypeId: (json['expenseTypeId'] as num?)?.toInt() ?? 0,
      expenseTypeName: json['expenseTypeName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expenseDate'] ?? '',
      description: json['description'],
      meetingId: (json['meetingId'] as num?)?.toInt(),
    );
  }
}
