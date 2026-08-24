class ExpenseTypeModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  ExpenseTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTypeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }
}
