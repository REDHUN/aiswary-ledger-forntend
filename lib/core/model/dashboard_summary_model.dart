import 'meeting_model.dart';

class DashboardSummaryModel {
  final MeetingModel? nextMeeting;
  final double totalOutstandingLoans;
  final double totalDeposits;
  final double totalOutstandingFines;
  final double totalOutstandingFinancialAid;
  final double totalMonthlyContributions;
  final double totalOutstandingInterest;
  final double currentMeetingCollections;
  final String currentInterestPeriod;
  final int interestCalculatedMembersCount;
  final int interestPendingMembersCount;

  DashboardSummaryModel({
    this.nextMeeting,
    required this.totalOutstandingLoans,
    required this.totalDeposits,
    required this.totalOutstandingFines,
    required this.totalOutstandingFinancialAid,
    required this.totalMonthlyContributions,
    required this.totalOutstandingInterest,
    required this.currentMeetingCollections,
    required this.currentInterestPeriod,
    required this.interestCalculatedMembersCount,
    required this.interestPendingMembersCount,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      nextMeeting: json['nextMeeting'] != null ? MeetingModel.fromJson(json['nextMeeting']) : null,
      totalOutstandingLoans: (json['totalOutstandingLoans'] as num?)?.toDouble() ?? 0.0,
      totalDeposits: (json['totalDeposits'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingFines: (json['totalOutstandingFines'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingFinancialAid: (json['totalOutstandingFinancialAid'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyContributions: (json['totalMonthlyContributions'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingInterest: (json['totalOutstandingInterest'] as num?)?.toDouble() ?? 0.0,
      currentMeetingCollections: (json['currentMeetingCollections'] as num?)?.toDouble() ?? 0.0,
      currentInterestPeriod: json['currentInterestPeriod'] ?? '',
      interestCalculatedMembersCount: json['interestCalculatedMembersCount'] ?? 0,
      interestPendingMembersCount: json['interestPendingMembersCount'] ?? 0,
    );
  }
}
