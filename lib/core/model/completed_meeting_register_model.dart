import 'group_profit_model.dart';
import 'group_expense_model.dart';
import 'loan_issued_register_item_model.dart';

class SpecialLoanRegisterItemModel {
  final int? specialLoanTypeId;
  final String specialLoanTypeName;
  final double amount;

  SpecialLoanRegisterItemModel({
    this.specialLoanTypeId,
    required this.specialLoanTypeName,
    required this.amount,
  });

  factory SpecialLoanRegisterItemModel.fromJson(Map<String, dynamic> json) {
    return SpecialLoanRegisterItemModel(
      specialLoanTypeId: (json['specialLoanTypeId'] as num?)?.toInt(),
      specialLoanTypeName: json['specialLoanTypeName'] ?? 'Special Loan',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CompletedMeetingRegisterModel {
  final int meetingId;
  final int meetingNumber;
  final String meetingDate;
  final String interestPeriod;
  final double totalDepositsCollected;
  final double totalLoanRepaymentsCollected;
  final double totalFinesCollected;
  final double totalMonthlyContributionsCollected;
  final double totalSpecialLoanRepaymentsCollected;
  final List<SpecialLoanRegisterItemModel> specialLoanBreakdown;
  final double totalLoansIssued;
  final List<LoanIssuedRegisterItemModel> loansIssuedBreakdown;
  final double totalFinancialAidDisbursed;
  final double totalGroupExpenses;
  final List<GroupExpenseModel> groupExpensesBreakdown;
  final double totalGroupProfit;
  final List<GroupProfitModel> groupProfitsBreakdown;
  final double totalNetMeetingCollections;
  final double surplusAmount;

  CompletedMeetingRegisterModel({
    required this.meetingId,
    required this.meetingNumber,
    required this.meetingDate,
    required this.interestPeriod,
    required this.totalDepositsCollected,
    required this.totalLoanRepaymentsCollected,
    required this.totalFinesCollected,
    required this.totalMonthlyContributionsCollected,
    required this.totalSpecialLoanRepaymentsCollected,
    required this.specialLoanBreakdown,
    required this.totalLoansIssued,
    required this.loansIssuedBreakdown,
    required this.totalFinancialAidDisbursed,
    required this.totalGroupExpenses,
    required this.groupExpensesBreakdown,
    required this.totalGroupProfit,
    required this.groupProfitsBreakdown,
    required this.totalNetMeetingCollections,
    required this.surplusAmount,
  });

  factory CompletedMeetingRegisterModel.fromJson(Map<String, dynamic> json) {
    var rawSlList = json['specialLoanBreakdown'] as List? ?? [];
    List<SpecialLoanRegisterItemModel> parsedSlList =
        rawSlList.map((i) => SpecialLoanRegisterItemModel.fromJson(i)).toList();

    var rawLoanIssuedList = json['loansIssuedBreakdown'] as List? ?? [];
    List<LoanIssuedRegisterItemModel> parsedLoanIssuedList =
        rawLoanIssuedList.map((i) => LoanIssuedRegisterItemModel.fromJson(i)).toList();

    var rawGeList = json['groupExpensesBreakdown'] as List? ?? [];
    List<GroupExpenseModel> parsedGeList =
        rawGeList.map((i) => GroupExpenseModel.fromJson(i)).toList();

    return CompletedMeetingRegisterModel(
      meetingId: (json['meetingId'] as num?)?.toInt() ?? 0,
      meetingNumber: (json['meetingNumber'] as num?)?.toInt() ?? 0,
      meetingDate: json['meetingDate'] ?? '',
      interestPeriod: json['interestPeriod'] ?? '',
      totalDepositsCollected: (json['totalDepositsCollected'] as num?)?.toDouble() ?? 0.0,
      totalLoanRepaymentsCollected: (json['totalLoanRepaymentsCollected'] as num?)?.toDouble() ?? 0.0,
      totalFinesCollected: (json['totalFinesCollected'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyContributionsCollected: (json['totalMonthlyContributionsCollected'] as num?)?.toDouble() ?? 0.0,
      totalSpecialLoanRepaymentsCollected: (json['totalSpecialLoanRepaymentsCollected'] as num?)?.toDouble() ?? 0.0,
      specialLoanBreakdown: parsedSlList,
      totalLoansIssued: (json['totalLoansIssued'] as num?)?.toDouble() ?? 0.0,
      loansIssuedBreakdown: parsedLoanIssuedList,
      totalFinancialAidDisbursed: (json['totalFinancialAidDisbursed'] as num?)?.toDouble() ?? 0.0,
      totalGroupExpenses: (json['totalGroupExpenses'] as num?)?.toDouble() ?? 0.0,
      groupExpensesBreakdown: parsedGeList,
      totalGroupProfit: (json['totalGroupProfit'] as num?)?.toDouble() ?? 0.0,
      groupProfitsBreakdown: (json['groupProfitsBreakdown'] as List? ?? []).map((x) => GroupProfitModel.fromJson(x)).toList(),
      totalNetMeetingCollections: (json['totalNetMeetingCollections'] as num?)?.toDouble() ?? 0.0,
      surplusAmount: (json['surplusAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
