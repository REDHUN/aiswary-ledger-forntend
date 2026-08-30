class CategoryMemberItemModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final String categoryName;
  final double balance;

  CategoryMemberItemModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.categoryName,
    required this.balance,
  });

  factory CategoryMemberItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryMemberItemModel(
      memberId: (json['memberId'] as num?)?.toInt() ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FinancialAidHistoryItemModel {
  final int transactionId;
  final int? memberId;
  final String memberNumber;
  final String fullName;
  final double amount;
  final String transactionDate;
  final int? meetingId;
  final String meetingNumber;
  final String? notes;

  FinancialAidHistoryItemModel({
    required this.transactionId,
    this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.amount,
    required this.transactionDate,
    this.meetingId,
    required this.meetingNumber,
    this.notes,
  });

  factory FinancialAidHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return FinancialAidHistoryItemModel(
      transactionId: (json['transactionId'] as num?)?.toInt() ?? 0,
      memberId: (json['memberId'] as num?)?.toInt(),
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: json['transactionDate'] ?? '',
      meetingId: (json['meetingId'] as num?)?.toInt(),
      meetingNumber: json['meetingNumber']?.toString() ?? '-',
      notes: json['notes'],
    );
  }
}

class CategoryReportModel {
  final double totalLoansIssued;
  final double totalLoansRepaid;
  final double totalOutstandingLoanBalance;
  final double totalSpecialLoanBalance;
  final List<CategoryMemberItemModel> loanMembers;

  final double totalDepositsCollected;
  final List<CategoryMemberItemModel> depositMembers;

  final double totalFinancialAidDisbursed;
  final List<FinancialAidHistoryItemModel> financialAidDisbursements;

  final double totalContributionsCollected;
  final double totalFinesCollected;

  CategoryReportModel({
    required this.totalLoansIssued,
    required this.totalLoansRepaid,
    required this.totalOutstandingLoanBalance,
    required this.totalSpecialLoanBalance,
    required this.loanMembers,
    required this.totalDepositsCollected,
    required this.depositMembers,
    required this.totalFinancialAidDisbursed,
    required this.financialAidDisbursements,
    required this.totalContributionsCollected,
    required this.totalFinesCollected,
  });

  factory CategoryReportModel.fromJson(Map<String, dynamic> json) {
    final loanM = (json['loanMembers'] as List? ?? [])
        .map((x) => CategoryMemberItemModel.fromJson(x as Map<String, dynamic>))
        .toList();

    final depM = (json['depositMembers'] as List? ?? [])
        .map((x) => CategoryMemberItemModel.fromJson(x as Map<String, dynamic>))
        .toList();

    final aidH = (json['financialAidDisbursements'] as List? ?? [])
        .map((x) => FinancialAidHistoryItemModel.fromJson(x as Map<String, dynamic>))
        .toList();

    return CategoryReportModel(
      totalLoansIssued: (json['totalLoansIssued'] as num?)?.toDouble() ?? 0.0,
      totalLoansRepaid: (json['totalLoansRepaid'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingLoanBalance: (json['totalOutstandingLoanBalance'] as num?)?.toDouble() ?? 0.0,
      totalSpecialLoanBalance: (json['totalSpecialLoanBalance'] as num?)?.toDouble() ?? 0.0,
      loanMembers: loanM,
      totalDepositsCollected: (json['totalDepositsCollected'] as num?)?.toDouble() ?? 0.0,
      depositMembers: depM,
      totalFinancialAidDisbursed: (json['totalFinancialAidDisbursed'] as num?)?.toDouble() ?? 0.0,
      financialAidDisbursements: aidH,
      totalContributionsCollected: (json['totalContributionsCollected'] as num?)?.toDouble() ?? 0.0,
      totalFinesCollected: (json['totalFinesCollected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
