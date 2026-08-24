class GroupLoanMemberDetailModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final double issuedAmount;
  final double repaidAmount;
  final double currentBalance;
  final bool isFullyRepaid;

  GroupLoanMemberDetailModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.issuedAmount,
    required this.repaidAmount,
    required this.currentBalance,
    required this.isFullyRepaid,
  });

  factory GroupLoanMemberDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupLoanMemberDetailModel(
      memberId: json['memberId'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      issuedAmount: (json['issuedAmount'] ?? 0.0).toDouble(),
      repaidAmount: (json['repaidAmount'] ?? 0.0).toDouble(),
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      isFullyRepaid: json['isFullyRepaid'] ?? false,
    );
  }
}

class GroupLoanSummaryModel {
  final int id;
  final int? groupId;
  final String? groupName;
  final String accountType;
  final int? specialLoanTypeId;
  final String? specialLoanTypeName;
  final double totalAmount;
  final double perMemberAmount;
  final int memberCount;
  final double totalRepaidAmount;
  final double totalRemainingBalance;
  final String? notes;
  final String transactionDate;
  final List<GroupLoanMemberDetailModel> memberDetails;

  GroupLoanSummaryModel({
    required this.id,
    this.groupId,
    this.groupName,
    required this.accountType,
    this.specialLoanTypeId,
    this.specialLoanTypeName,
    required this.totalAmount,
    required this.perMemberAmount,
    required this.memberCount,
    this.totalRepaidAmount = 0.0,
    this.totalRemainingBalance = 0.0,
    this.notes,
    required this.transactionDate,
    this.memberDetails = const [],
  });

  factory GroupLoanSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['memberDetails'] as List? ?? [];
    return GroupLoanSummaryModel(
      id: json['id'] ?? 0,
      groupId: json['groupId'],
      groupName: json['groupName'],
      accountType: json['accountType'] ?? 'LOAN',
      specialLoanTypeId: json['specialLoanTypeId'],
      specialLoanTypeName: json['specialLoanTypeName'],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      perMemberAmount: (json['perMemberAmount'] ?? 0.0).toDouble(),
      memberCount: json['memberCount'] ?? 0,
      totalRepaidAmount: (json['totalRepaidAmount'] ?? 0.0).toDouble(),
      totalRemainingBalance: (json['totalRemainingBalance'] ?? 0.0).toDouble(),
      notes: json['notes'],
      transactionDate: json['transactionDate'] ?? '',
      memberDetails: list.map((e) => GroupLoanMemberDetailModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
