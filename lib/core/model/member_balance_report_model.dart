class MemberBalanceReportModel {
  final int memberId;
  final String memberNumber;
  final String fullName;
  final String? phone;
  final bool isActive;
  final double loanBalance;
  final double depositBalance;
  final double fineBalance;
  final double contributionBalance;
  final double financialAidBalance;
  final double interestBalance;

  MemberBalanceReportModel({
    required this.memberId,
    required this.memberNumber,
    required this.fullName,
    this.phone,
    required this.isActive,
    required this.loanBalance,
    required this.depositBalance,
    required this.fineBalance,
    required this.contributionBalance,
    required this.financialAidBalance,
    required this.interestBalance,
  });

  double get netBalance => (depositBalance + contributionBalance) - (loanBalance + fineBalance + financialAidBalance + interestBalance);

  factory MemberBalanceReportModel.fromJson(Map<String, dynamic> json) {
    return MemberBalanceReportModel(
      memberId: (json['memberId'] as num?)?.toInt() ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      loanBalance: (json['loanBalance'] as num?)?.toDouble() ?? 0.0,
      depositBalance: (json['depositBalance'] as num?)?.toDouble() ?? 0.0,
      fineBalance: (json['fineBalance'] as num?)?.toDouble() ?? 0.0,
      contributionBalance: (json['contributionBalance'] as num?)?.toDouble() ?? 0.0,
      financialAidBalance: (json['financialAidBalance'] as num?)?.toDouble() ?? 0.0,
      interestBalance: (json['interestBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
