import 'member_account_model.dart';

class MemberProcessingDataModel {
  final int memberId;
  final String fullName;
  final String memberNumber;
  final double loanRemaining;
  final double interestRemaining;
  final double depositCurrent;
  final double fineRemaining;
  final double financialAidRemaining;
  final double monthlyContributionCurrent;
  final String processingStatus;
  final bool interestCalculationRequired;
  final bool interestCalculated;
  final bool processingAllowed;
  final String? activeInterestPeriod;
  final List<MemberAccountModel> accountBalances;
  final List<String> pendingInterestPeriods;

  MemberProcessingDataModel({
    required this.memberId,
    required this.fullName,
    required this.memberNumber,
    required this.loanRemaining,
    required this.interestRemaining,
    required this.depositCurrent,
    required this.fineRemaining,
    required this.financialAidRemaining,
    required this.monthlyContributionCurrent,
    required this.processingStatus,
    required this.interestCalculationRequired,
    required this.interestCalculated,
    required this.processingAllowed,
    this.activeInterestPeriod,
    required this.accountBalances,
    required this.pendingInterestPeriods,
  });

  factory MemberProcessingDataModel.fromJson(Map<String, dynamic> json) {
    var rawAccounts = json['accountBalances'] as List? ?? [];
    List<MemberAccountModel> accounts =
        rawAccounts.map((a) => MemberAccountModel.fromJson(a)).toList();

    var rawPeriods = json['pendingInterestPeriods'] as List? ?? [];
    List<String> periods = rawPeriods.map((p) => p.toString()).toList();

    return MemberProcessingDataModel(
      memberId: json['memberId'] ?? 0,
      fullName: json['fullName'] ?? '',
      memberNumber: json['memberNumber'] ?? '',
      loanRemaining: (json['loanRemaining'] as num?)?.toDouble() ?? 0.0,
      interestRemaining: (json['interestRemaining'] as num?)?.toDouble() ?? 0.0,
      depositCurrent: (json['depositCurrent'] as num?)?.toDouble() ?? 0.0,
      fineRemaining: (json['fineRemaining'] as num?)?.toDouble() ?? 0.0,
      financialAidRemaining: (json['financialAidRemaining'] as num?)?.toDouble() ?? 0.0,
      monthlyContributionCurrent: (json['monthlyContributionCurrent'] as num?)?.toDouble() ?? 0.0,
      processingStatus: json['processingStatus'] ?? 'PENDING',
      interestCalculationRequired: json['interestCalculationRequired'] ?? false,
      interestCalculated: json['interestCalculated'] ?? false,
      processingAllowed: json['processingAllowed'] ?? true,
      activeInterestPeriod: json['activeInterestPeriod'],
      accountBalances: accounts,
      pendingInterestPeriods: periods,
    );
  }
}

