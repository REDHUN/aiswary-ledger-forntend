class MemberPersonalReportModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final String yearMonth;
  final List<String> availableMonths;
  final double monthInterest;
  final double startMonthRemainingLoanBalance;
  final double monthEndRemainingLoanBalance;
  final double totalDeposits;
  final double totalLoanRepaid;
  final double totalSpecialLoanRepaid;
  final double currentLoanBalance;
  final double currentDepositBalance;
  final double monthEndDepositBalance;
  final double totalMonthlyContributions;
  final double totalFinesPaid;
  final double totalFinancialAidReceived;
  final double totalPaidInPeriod;
  final List<MemberMeetingPaymentEntryModel> meetingPayments;

  MemberPersonalReportModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.yearMonth,
    required this.availableMonths,
    required this.monthInterest,
    required this.startMonthRemainingLoanBalance,
    required this.monthEndRemainingLoanBalance,
    required this.totalDeposits,
    required this.totalLoanRepaid,
    required this.totalSpecialLoanRepaid,
    required this.currentLoanBalance,
    required this.currentDepositBalance,
    required this.monthEndDepositBalance,
    required this.totalMonthlyContributions,
    required this.totalFinesPaid,
    required this.totalFinancialAidReceived,
    required this.totalPaidInPeriod,
    required this.meetingPayments,
  });

  factory MemberPersonalReportModel.fromJson(Map<String, dynamic> json) {
    final availList = (json['availableMonths'] as List? ?? []).map((e) => e.toString()).toList();
    final paymentsList = (json['meetingPayments'] as List? ?? [])
        .map((e) => MemberMeetingPaymentEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MemberPersonalReportModel(
      memberId: json['memberId'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      yearMonth: json['yearMonth'] ?? '',
      availableMonths: availList,
      monthInterest: (json['monthInterest'] ?? 0.0).toDouble(),
      startMonthRemainingLoanBalance: (json['startMonthRemainingLoanBalance'] ?? 0.0).toDouble(),
      monthEndRemainingLoanBalance: (json['monthEndRemainingLoanBalance'] ?? 0.0).toDouble(),
      totalDeposits: (json['totalDeposits'] ?? 0.0).toDouble(),
      totalLoanRepaid: (json['totalLoanRepaid'] ?? 0.0).toDouble(),
      totalSpecialLoanRepaid: (json['totalSpecialLoanRepaid'] ?? 0.0).toDouble(),
      currentLoanBalance: (json['currentLoanBalance'] ?? 0.0).toDouble(),
      currentDepositBalance: (json['currentDepositBalance'] ?? 0.0).toDouble(),
      monthEndDepositBalance: (json['monthEndDepositBalance'] ?? 0.0).toDouble(),
      totalMonthlyContributions: (json['totalMonthlyContributions'] ?? 0.0).toDouble(),
      totalFinesPaid: (json['totalFinesPaid'] ?? 0.0).toDouble(),
      totalFinancialAidReceived: (json['totalFinancialAidReceived'] ?? 0.0).toDouble(),
      totalPaidInPeriod: (json['totalPaidInPeriod'] ?? 0.0).toDouble(),
      meetingPayments: paymentsList,
    );
  }
}

class MemberMeetingPaymentEntryModel {
  final int meetingId;
  final int meetingNumber;
  final String meetingDate;
  final double loanRepayment;
  final double specialLoanRepayment;
  final String? specialLoanTypeName;
  final double depositAddition;
  final double finePayment;
  final double contributionAddition;
  final double financialAidPayment;
  final double totalPaid;

  MemberMeetingPaymentEntryModel({
    required this.meetingId,
    required this.meetingNumber,
    required this.meetingDate,
    required this.loanRepayment,
    required this.specialLoanRepayment,
    this.specialLoanTypeName,
    required this.depositAddition,
    required this.finePayment,
    required this.contributionAddition,
    required this.financialAidPayment,
    required this.totalPaid,
  });

  factory MemberMeetingPaymentEntryModel.fromJson(Map<String, dynamic> json) {
    return MemberMeetingPaymentEntryModel(
      meetingId: json['meetingId'] ?? 0,
      meetingNumber: json['meetingNumber'] ?? 0,
      meetingDate: json['meetingDate'] ?? '',
      loanRepayment: (json['loanRepayment'] ?? 0.0).toDouble(),
      specialLoanRepayment: (json['specialLoanRepayment'] ?? 0.0).toDouble(),
      specialLoanTypeName: json['specialLoanTypeName'],
      depositAddition: (json['depositAddition'] ?? 0.0).toDouble(),
      finePayment: (json['finePayment'] ?? 0.0).toDouble(),
      contributionAddition: (json['contributionAddition'] ?? 0.0).toDouble(),
      financialAidPayment: (json['financialAidPayment'] ?? 0.0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0.0).toDouble(),
    );
  }
}
