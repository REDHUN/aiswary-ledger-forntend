class FinancialReportModel {
  final int totalMembers;
  final int activeMembers;
  final double totalOutstandingLoans;
  final double totalDeposits;
  final double totalOutstandingFines;
  final double totalOutstandingFinancialAid;
  final double totalMonthlyContributions;
  final double totalOutstandingInterest;
  final double periodCollections;
  final double periodDisbursals;
  final int totalTransactionsCount;
  final String? startDate;
  final String? endDate;

  FinancialReportModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.totalOutstandingLoans,
    required this.totalDeposits,
    required this.totalOutstandingFines,
    required this.totalOutstandingFinancialAid,
    required this.totalMonthlyContributions,
    required this.totalOutstandingInterest,
    required this.periodCollections,
    required this.periodDisbursals,
    required this.totalTransactionsCount,
    this.startDate,
    this.endDate,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      activeMembers: (json['activeMembers'] as num?)?.toInt() ?? 0,
      totalOutstandingLoans: (json['totalOutstandingLoans'] as num?)?.toDouble() ?? 0.0,
      totalDeposits: (json['totalDeposits'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingFines: (json['totalOutstandingFines'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingFinancialAid: (json['totalOutstandingFinancialAid'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyContributions: (json['totalMonthlyContributions'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingInterest: (json['totalOutstandingInterest'] as num?)?.toDouble() ?? 0.0,
      periodCollections: (json['periodCollections'] as num?)?.toDouble() ?? 0.0,
      periodDisbursals: (json['periodDisbursals'] as num?)?.toDouble() ?? 0.0,
      totalTransactionsCount: (json['totalTransactionsCount'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}
