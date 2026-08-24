import 'member_model.dart';

class MemberGroupModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int memberCount;
  final List<MemberModel> members;
  final String? createdAt;

  MemberGroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.memberCount,
    this.members = const [],
    this.createdAt,
  });

  factory MemberGroupModel.fromJson(Map<String, dynamic> json) {
    final memList = json['members'] as List? ?? [];
    return MemberGroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      memberCount: json['memberCount'] ?? memList.length,
      members: memList.map((e) => MemberModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['createdAt'],
    );
  }
}
