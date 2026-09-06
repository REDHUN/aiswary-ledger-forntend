class UserModel {
  final int userId;
  final String username;
  final String role;
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int? memberId;

  UserModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    this.memberId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'] ?? 'Bearer',
      memberId: json['memberId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'role': role,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'memberId': memberId,
    };
  }
}
