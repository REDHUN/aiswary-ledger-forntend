class MeetingReportModel {
  final int meetingId;
  final int meetingNumber;
  final String meetingDate;
  final String interestPeriod;
  final String status;
  final int processedMembers;
  final int totalMembers;
  final double totalCollected;
  final double totalLoanRepayments;
  final double totalDepositsCollected;
  final double totalFinesCollected;
  final double totalMonthlyContributions;
  final double totalFinancialAid;
  final double totalLoansIssued;
  final List<MemberMeetingCollectionModel> memberCollections;

  MeetingReportModel({
    required this.meetingId,
    required this.meetingNumber,
    required this.meetingDate,
    required this.interestPeriod,
    required this.status,
    required this.processedMembers,
    required this.totalMembers,
    required this.totalCollected,
    required this.totalLoanRepayments,
    required this.totalDepositsCollected,
    required this.totalFinesCollected,
    required this.totalMonthlyContributions,
    required this.totalFinancialAid,
    required this.totalLoansIssued,
    required this.memberCollections,
  });

  factory MeetingReportModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['memberCollections'] as List? ?? [];
    var list = rawList.map((x) => MemberMeetingCollectionModel.fromJson(x)).toList();

    return MeetingReportModel(
      meetingId: (json['meetingId'] as num?)?.toInt() ?? 0,
      meetingNumber: (json['meetingNumber'] as num?)?.toInt() ?? 0,
      meetingDate: json['meetingDate'] ?? '',
      interestPeriod: json['interestPeriod'] ?? '',
      status: json['status'] ?? '',
      processedMembers: (json['processedMembers'] as num?)?.toInt() ?? 0,
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      totalLoanRepayments: (json['totalLoanRepayments'] as num?)?.toDouble() ?? 0.0,
      totalDepositsCollected: (json['totalDepositsCollected'] as num?)?.toDouble() ?? 0.0,
      totalFinesCollected: (json['totalFinesCollected'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyContributions: (json['totalMonthlyContributions'] as num?)?.toDouble() ?? 0.0,
      totalFinancialAid: (json['totalFinancialAid'] as num?)?.toDouble() ?? 0.0,
      totalLoansIssued: (json['totalLoansIssued'] as num?)?.toDouble() ?? 0.0,
      memberCollections: list,
    );
  }
}

class MemberMeetingCollectionModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final double loanRepayment;
  final double depositAddition;
  final double finePayment;
  final double contributionAddition;
  final double financialAidPayment;
  final double totalMemberCollected;

  MemberMeetingCollectionModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.loanRepayment,
    required this.depositAddition,
    required this.finePayment,
    required this.contributionAddition,
    required this.financialAidPayment,
    required this.totalMemberCollected,
  });

  factory MemberMeetingCollectionModel.fromJson(Map<String, dynamic> json) {
    return MemberMeetingCollectionModel(
      memberId: (json['memberId'] as num?)?.toInt() ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      loanRepayment: (json['loanRepayment'] as num?)?.toDouble() ?? 0.0,
      depositAddition: (json['depositAddition'] as num?)?.toDouble() ?? 0.0,
      finePayment: (json['finePayment'] as num?)?.toDouble() ?? 0.0,
      contributionAddition: (json['contributionAddition'] as num?)?.toDouble() ?? 0.0,
      financialAidPayment: (json['financialAidPayment'] as num?)?.toDouble() ?? 0.0,
      totalMemberCollected: (json['totalMemberCollected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
