import 'member_account_model.dart';

class MemberModel {
  final int id;
  final int userId;
  final String memberNumber;
  final String fullName;
  final String? phone;
  final String? address;
  final bool isActive;
  final String? joiningDate;
  final List<MemberAccountModel> accounts;

  double get loanBalance => getAccountBalance('LOAN');
  double get specialLoanBalance => getAccountBalance('SPECIAL_LOAN');
  double get depositBalance => getAccountBalance('DEPOSIT');
  double get monthlyContributionBalance =>
      getAccountBalance('MONTHLY_CONTRIBUTION');
  double get fineBalance => getAccountBalance('FINE');
  double get financialAidBalance => getAccountBalance('FINANCIAL_AID');
  double get interestBalance => getAccountBalance('INTEREST');

  double getAccountBalance(String type) {
    try {
      final acc = accounts.firstWhere((a) => a.accountType == type);
      return acc.currentBalance;
    } catch (_) {
      return 0.0;
    }
  }

  MemberModel({
    required this.userId,
    required this.id,
    required this.memberNumber,
    required this.fullName,
    this.phone,
    this.address,
    required this.isActive,
    this.joiningDate,
    this.accounts = const [],
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final accList = (json['accounts'] as List? ?? [])
        .map((x) => MemberAccountModel.fromJson(x as Map<String, dynamic>))
        .toList();
    return MemberModel(
      userId: json['userId'] ?? 0,
      id: json['id'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      joiningDate: json['joiningDate'],
      accounts: accList,
    );
  }
}
