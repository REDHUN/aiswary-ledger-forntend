class BroadcastNotificationResult {
  final int totalTargeted;
  final int successCount;
  final int failureCount;
  final String status;
  final String? message;
  final List<String> errors;

  BroadcastNotificationResult({
    required this.totalTargeted,
    required this.successCount,
    required this.failureCount,
    required this.status,
    this.message,
    this.errors = const [],
  });

  factory BroadcastNotificationResult.fromJson(Map<String, dynamic> json) {
    return BroadcastNotificationResult(
      totalTargeted: json['totalTargeted'] is int ? json['totalTargeted'] : 0,
      successCount: json['successCount'] is int ? json['successCount'] : 0,
      failureCount: json['failureCount'] is int ? json['failureCount'] : 0,
      status: json['status']?.toString() ?? 'UNKNOWN',
      message: json['message']?.toString(),
      errors: (json['errors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  bool get isFullSuccess => failureCount == 0 && successCount > 0;
  bool get isPartialSuccess => status == 'PARTIAL_SUCCESS' || (successCount > 0 && failureCount > 0);
  bool get isFailure => successCount == 0 && totalTargeted > 0;
}
