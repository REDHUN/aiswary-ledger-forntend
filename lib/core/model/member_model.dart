class MemberModel {
  final int id;
  final String memberNumber;
  final String fullName;
  final String? phone;
  final String? address;
  final bool isActive;
  final String? joiningDate;

  MemberModel({
    required this.id,
    required this.memberNumber,
    required this.fullName,
    this.phone,
    this.address,
    required this.isActive,
    this.joiningDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      memberNumber: json['memberNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      joiningDate: json['joiningDate'],
    );
  }
}
