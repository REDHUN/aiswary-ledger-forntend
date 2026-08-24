class FinancialTransactionModel {
  final int id;
  final String? transactionId;
  final int memberId;
  final String? memberName;
  final int? meetingId;
  final String accountType;
  final String transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final String? createdByUsername;
  final String createdAt;
  final bool isReversed;

  FinancialTransactionModel({
    required this.id,
    this.transactionId,
    required this.memberId,
    this.memberName,
    this.meetingId,
    required this.accountType,
    required this.transactionType,
    required this.amount,
    this.balanceBefore = 0.0,
    required this.balanceAfter,
    this.description,
    this.createdByUsername,
    required this.createdAt,
    this.isReversed = false,
  });

  factory FinancialTransactionModel.fromJson(Map<String, dynamic> json) {
    return FinancialTransactionModel(
      id: json['id'] ?? 0,
      transactionId: json['transactionId'],
      memberId: json['memberId'] ?? 0,
      memberName: json['memberName'],
      meetingId: json['meetingId'],
      accountType: json['accountType'] ?? '',
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0.0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0.0).toDouble(),
      description: json['description'],
      createdByUsername: json['createdByUsername'],
      createdAt: json['createdAt'] ?? '',
      isReversed: json['isReversed'] ?? json['reversed'] ?? false,
    );
  }
}
