class MonthlyLedgerReportModel {
  final String yearMonth;
  final List<String> availableMonths;
  final List<String> meetingDates;
  final List<MemberLedgerRowModel> memberRows;
  final Map<String, double> meetingTotals;
  final double grandTotalCollected;

  MonthlyLedgerReportModel({
    required this.yearMonth,
    required this.availableMonths,
    required this.meetingDates,
    required this.memberRows,
    required this.meetingTotals,
    required this.grandTotalCollected,
  });

  factory MonthlyLedgerReportModel.fromJson(Map<String, dynamic> json) {
    final availList = (json['availableMonths'] as List? ?? []).map((e) => e.toString()).toList();
    final datesList = (json['meetingDates'] as List? ?? []).map((e) => e.toString()).toList();
    final rowsList = (json['memberRows'] as List? ?? [])
        .map((e) => MemberLedgerRowModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final totalsMap = <String, double>{};
    final rawTotals = json['meetingTotals'] as Map<String, dynamic>? ?? {};
    rawTotals.forEach((k, v) {
      totalsMap[k] = (v as num).toDouble();
    });

    return MonthlyLedgerReportModel(
      yearMonth: json['yearMonth'] ?? '',
      availableMonths: availList,
      meetingDates: datesList,
      memberRows: rowsList,
      meetingTotals: totalsMap,
      grandTotalCollected: (json['grandTotalCollected'] ?? 0.0).toDouble(),
    );
  }
}

class MemberLedgerRowModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final Map<String, double> meetingCollections;
  final double totalMonthlyCollected;
  final double monthlyContributionSum;
  final double depositSum;
  final double loanRepaymentSum;
  final double fineSum;
  final double currentLoanBalance;
  final double currentDepositBalance;

  MemberLedgerRowModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.meetingCollections,
    required this.totalMonthlyCollected,
    required this.monthlyContributionSum,
    required this.depositSum,
    required this.loanRepaymentSum,
    required this.fineSum,
    required this.currentLoanBalance,
    required this.currentDepositBalance,
  });

  factory MemberLedgerRowModel.fromJson(Map<String, dynamic> json) {
    final collectionsMap = <String, double>{};
    final rawCollections = json['meetingCollections'] as Map<String, dynamic>? ?? {};
    rawCollections.forEach((k, v) {
      collectionsMap[k] = (v as num).toDouble();
    });

    return MemberLedgerRowModel(
      memberId: json['memberId'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      meetingCollections: collectionsMap,
      totalMonthlyCollected: (json['totalMonthlyCollected'] ?? 0.0).toDouble(),
      monthlyContributionSum: (json['monthlyContributionSum'] ?? 0.0).toDouble(),
      depositSum: (json['depositSum'] ?? 0.0).toDouble(),
      loanRepaymentSum: (json['loanRepaymentSum'] ?? 0.0).toDouble(),
      fineSum: (json['fineSum'] ?? 0.0).toDouble(),
      currentLoanBalance: (json['currentLoanBalance'] ?? 0.0).toDouble(),
      currentDepositBalance: (json['currentDepositBalance'] ?? 0.0).toDouble(),
    );
  }
}
