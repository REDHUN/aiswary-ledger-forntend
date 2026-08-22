class FinancialTransactionModel {
  final int id;
  final String transactionId;
  final int memberId;
  final int? meetingId;
  final String accountType;
  final String transactionType;
  final double amount;
  final double balanceAfter;
  final String? description;
  final String? createdByName;
  final String createdAt;
  final bool isReversed;

  FinancialTransactionModel({
    required this.id,
    required this.transactionId,
    required this.memberId,
    this.meetingId,
    required this.accountType,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    this.description,
    this.createdByName,
    required this.createdAt,
    required this.isReversed,
  });

  factory FinancialTransactionModel.fromJson(Map<String, dynamic> json) {
    return FinancialTransactionModel(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'] ?? '',
      memberId: json['memberId'] ?? 0,
      meetingId: json['meetingId'],
      accountType: json['accountType'] ?? '',
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0.0).toDouble(),
      description: json['description'],
      createdByName: json['createdByName'],
      createdAt: json['createdAt'] ?? '',
      isReversed: json['isReversed'] ?? false,
    );
  }
}
