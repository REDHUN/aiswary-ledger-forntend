class ApiEndpoints {
  static const String baseUrl = "http://localhost:8080/api/v1";
  // static const String baseUrl = "http://192.168.1.6:8080/api/v1";


  // Auth
  static const String login = "/auth/login";

  // Members
  static const String members = "/members";
  static String memberDetails(int id) => "/members/$id";
  static String memberAccounts(int id) => "/members/$id/accounts";
  static String memberTransactions(int id) => "/members/$id/transactions";
  static String memberLoans(int id) => "/members/$id/loans";
  static String memberDeposits(int id) => "/members/$id/deposits";
  static String memberFines(int id) => "/members/$id/fines";
  static String memberContributions(int id) => "/members/$id/contributions";
  static String memberFinancialAid(int id) => "/members/$id/financial-aid";
  static String memberCalculateInterest(int id) =>
      "/members/$id/interest/calculate";

  // Meetings
  static const String meetings = "/meetings";
  static String meetingDetails(int id) => "/meetings/$id";
  static String openMeeting(int id) => "/meetings/$id/open";
  static String completeMeeting(int id) => "/meetings/$id/complete";
  static String rescheduleMeeting(int id) => "/meetings/$id/reschedule";
  static String meetingMembers(int id) => "/meetings/$id/members";

  // Processing
  static String memberProcessingForm(int meetingId, int memberId) =>
      "/meetings/$meetingId/members/$memberId/processing";
  static String processMember(int meetingId, int memberId) =>
      "/meetings/$meetingId/members/$memberId/process";

  // Dashboard
  static const String dashboardSummary = "/dashboard/summary";

  // Transactions
  static String reverseTransaction(int id) => "/transactions/$id/reverse";
}
