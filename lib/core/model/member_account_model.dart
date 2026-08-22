class MemberAccountModel {
  final int id;
  final int memberId;
  final String accountType;
  final double currentBalance;

  MemberAccountModel({
    required this.id,
    required this.memberId,
    required this.accountType,
    required this.currentBalance,
  });

  factory MemberAccountModel.fromJson(Map<String, dynamic> json) {
    return MemberAccountModel(
      id: json['id'] ?? 0,
      memberId: json['memberId'] ?? 0,
      accountType: json['accountType'] ?? '',
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
    );
  }
}
