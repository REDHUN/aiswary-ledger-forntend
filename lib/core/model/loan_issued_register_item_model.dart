class LoanIssuedRegisterItemModel {
  final String categoryName;
  final double amount;

  LoanIssuedRegisterItemModel({
    required this.categoryName,
    required this.amount,
  });

  factory LoanIssuedRegisterItemModel.fromJson(Map<String, dynamic> json) {
    return LoanIssuedRegisterItemModel(
      categoryName: json['categoryName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
