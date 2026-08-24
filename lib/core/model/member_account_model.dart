class MemberAccountModel {
  final int id;
  final int memberId;
  final String accountType;
  final int? specialLoanTypeId;
  final String? specialLoanTypeName;
  final double currentBalance;

  MemberAccountModel({
    required this.id,
    required this.memberId,
    required this.accountType,
    this.specialLoanTypeId,
    this.specialLoanTypeName,
    required this.currentBalance,
  });

  factory MemberAccountModel.fromJson(Map<String, dynamic> json) {
    return MemberAccountModel(
      id: json['id'] ?? 0,
      memberId: json['memberId'] ?? 0,
      accountType: json['accountType'] ?? '',
      specialLoanTypeId: json['specialLoanTypeId'],
      specialLoanTypeName: json['specialLoanTypeName'],
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
    );
  }
}
