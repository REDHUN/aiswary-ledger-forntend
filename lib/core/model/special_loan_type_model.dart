class SpecialLoanTypeModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final String? createdAt;

  SpecialLoanTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory SpecialLoanTypeModel.fromJson(Map<String, dynamic> json) {
    return SpecialLoanTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
    );
  }
}
