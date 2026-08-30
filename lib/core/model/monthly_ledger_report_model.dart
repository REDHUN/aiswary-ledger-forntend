class MonthlyLedgerReportModel {
  final String yearMonth;
  final List<String> availableMonths;
  final List<String> meetingDates;
  final List<MemberLedgerRowModel> memberRows;
  final Map<String, double> meetingTotals;
  final double grandTotalCollected;
  final double totalSpecialLoanRepayments;
  final double totalGroupExpenses;
  final double surplusAmount;

  MonthlyLedgerReportModel({
    required this.yearMonth,
    required this.availableMonths,
    required this.meetingDates,
    required this.memberRows,
    required this.meetingTotals,
    required this.grandTotalCollected,
    required this.totalSpecialLoanRepayments,
    required this.totalGroupExpenses,
    required this.surplusAmount,
  });

  factory MonthlyLedgerReportModel.fromJson(Map<String, dynamic> json) {
    var rawMonths = json['availableMonths'] as List? ?? [];
    var months = rawMonths.map((e) => e.toString()).toList();

    var rawDates = json['meetingDates'] as List? ?? [];
    var dates = rawDates.map((e) => e.toString()).toList();

    var rawRows = json['memberRows'] as List? ?? [];
    var rows = rawRows.map((e) => MemberLedgerRowModel.fromJson(e)).toList();

    var rawTotals = json['meetingTotals'] as Map<String, dynamic>? ?? {};
    Map<String, double> totals = {};
    rawTotals.forEach((k, v) {
      totals[k] = (v as num).toDouble();
    });

    return MonthlyLedgerReportModel(
      yearMonth: json['yearMonth'] ?? '',
      availableMonths: months,
      meetingDates: dates,
      memberRows: rows,
      meetingTotals: totals,
      grandTotalCollected: (json['grandTotalCollected'] as num?)?.toDouble() ?? 0.0,
      totalSpecialLoanRepayments: (json['totalSpecialLoanRepayments'] as num?)?.toDouble() ?? 0.0,
      totalGroupExpenses: (json['totalGroupExpenses'] as num?)?.toDouble() ?? 0.0,
      surplusAmount: (json['surplusAmount'] as num?)?.toDouble() ?? 0.0,
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
  final double specialLoanRepaymentSum;
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
    required this.specialLoanRepaymentSum,
    required this.fineSum,
    required this.currentLoanBalance,
    required this.currentDepositBalance,
  });

  factory MemberLedgerRowModel.fromJson(Map<String, dynamic> json) {
    var rawCollections = json['meetingCollections'] as Map<String, dynamic>? ?? {};
    Map<String, double> collections = {};
    rawCollections.forEach((k, v) {
      collections[k] = (v as num).toDouble();
    });

    return MemberLedgerRowModel(
      memberId: (json['memberId'] as num?)?.toInt() ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      meetingCollections: collections,
      totalMonthlyCollected: (json['totalMonthlyCollected'] as num?)?.toDouble() ?? 0.0,
      monthlyContributionSum: (json['monthlyContributionSum'] as num?)?.toDouble() ?? 0.0,
      depositSum: (json['depositSum'] as num?)?.toDouble() ?? 0.0,
      loanRepaymentSum: (json['loanRepaymentSum'] as num?)?.toDouble() ?? 0.0,
      specialLoanRepaymentSum: (json['specialLoanRepaymentSum'] as num?)?.toDouble() ?? 0.0,
      fineSum: (json['fineSum'] as num?)?.toDouble() ?? 0.0,
      currentLoanBalance: (json['currentLoanBalance'] as num?)?.toDouble() ?? 0.0,
      currentDepositBalance: (json['currentDepositBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
