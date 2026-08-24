class MemberProcessingDataModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final double loanRemaining;
  final double interestRemaining;
  final double calculatedInterestAmount;
  final double depositCurrent;
  final double fineRemaining;
  final double financialAidRemaining;
  final double monthlyContributionCurrent;
  final String processingStatus;
  final bool interestCalculationRequired;
  final bool interestCalculated;
  final bool processingAllowed;
  final String? activeInterestPeriod;
  final double lastLoanRepayment;
  final double lastDepositAddition;
  final double lastFinePayment;
  final double lastFinancialAidPayment;
  final double lastMonthlyContributionAddition;
  final String? lastNotes;
  final List<String> pendingInterestPeriods;
  final List<SpecialLoanBalanceInfoModel> specialLoans;
  List<SpecialLoanBalanceInfoModel> get specialLoanBalances => specialLoans;

  MemberProcessingDataModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    required this.loanRemaining,
    required this.interestRemaining,
    this.calculatedInterestAmount = 0.0,
    required this.depositCurrent,
    required this.fineRemaining,
    required this.financialAidRemaining,
    required this.monthlyContributionCurrent,
    required this.processingStatus,
    required this.interestCalculationRequired,
    required this.interestCalculated,
    required this.processingAllowed,
    this.activeInterestPeriod,
    this.lastLoanRepayment = 0.0,
    this.lastDepositAddition = 0.0,
    this.lastFinePayment = 0.0,
    this.lastFinancialAidPayment = 0.0,
    this.lastMonthlyContributionAddition = 0.0,
    this.lastNotes,
    this.pendingInterestPeriods = const [],
    this.specialLoans = const [],
  });

  factory MemberProcessingDataModel.fromJson(Map<String, dynamic> json) {
    final pendingList = json['pendingInterestPeriods'] as List? ?? [];
    final slRaw = json['specialLoans'] ?? json['specialLoanBalances'] ?? [];
    return MemberProcessingDataModel(
      memberId: json['memberId'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      loanRemaining: (json['loanRemaining'] ?? 0.0).toDouble(),
      interestRemaining: (json['interestRemaining'] ?? 0.0).toDouble(),
      calculatedInterestAmount: (json['calculatedInterestAmount'] ?? json['interestRemaining'] ?? 0.0).toDouble(),
      depositCurrent: (json['depositCurrent'] ?? 0.0).toDouble(),
      fineRemaining: (json['fineRemaining'] ?? 0.0).toDouble(),
      financialAidRemaining: (json['financialAidRemaining'] ?? 0.0).toDouble(),
      monthlyContributionCurrent: (json['monthlyContributionCurrent'] ?? 0.0).toDouble(),
      processingStatus: json['processingStatus'] ?? 'PENDING',
      interestCalculationRequired: json['interestCalculationRequired'] ?? false,
      interestCalculated: json['interestCalculated'] ?? false,
      processingAllowed: json['processingAllowed'] ?? true,
      activeInterestPeriod: json['activeInterestPeriod'],
      lastLoanRepayment: (json['lastLoanRepayment'] ?? 0.0).toDouble(),
      lastDepositAddition: (json['lastDepositAddition'] ?? 0.0).toDouble(),
      lastFinePayment: (json['lastFinePayment'] ?? 0.0).toDouble(),
      lastFinancialAidPayment: (json['lastFinancialAidPayment'] ?? 0.0).toDouble(),
      lastMonthlyContributionAddition: (json['lastMonthlyContributionAddition'] ?? 0.0).toDouble(),
      lastNotes: json['lastNotes'],
      pendingInterestPeriods: pendingList.map((e) => e.toString()).toList(),
      specialLoans: (slRaw as List)
          .map((e) => SpecialLoanBalanceInfoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpecialLoanBalanceInfoModel {
  final int specialLoanTypeId;
  final String specialLoanTypeName;
  final double currentBalance;
  final double lastRepaymentAmount;

  SpecialLoanBalanceInfoModel({
    required this.specialLoanTypeId,
    required this.specialLoanTypeName,
    required this.currentBalance,
    this.lastRepaymentAmount = 0.0,
  });

  factory SpecialLoanBalanceInfoModel.fromJson(Map<String, dynamic> json) {
    return SpecialLoanBalanceInfoModel(
      specialLoanTypeId: json['specialLoanTypeId'] ?? 0,
      specialLoanTypeName: json['specialLoanTypeName'] ?? '',
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      lastRepaymentAmount: (json['lastRepaymentAmount'] ?? json['lastRepayment'] ?? 0.0).toDouble(),
    );
  }
}
