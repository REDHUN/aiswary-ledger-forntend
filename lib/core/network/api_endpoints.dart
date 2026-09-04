class ApiEndpoints {
  //static const String baseUrl = "http://localhost:8080/api/v1";
  // static const String baseUrl = "http://192.168.1.6:8080/api/v1";
  static const String baseUrl =
      "https://aiswary-ledger-backend-177358050271.asia-south1.run.app/api/v1";

  // Auth
  static const String login = "/auth/login";

  // FCM Tokens & Notifications
  static const String fcmTokens = "/fcm-tokens";
  static String deleteFcmToken(String token) =>
      "/fcm-tokens?fcmToken=${Uri.encodeQueryComponent(token)}";
  static const String notifications = "/notifications";
  static const String notificationUnreadCount = "/notifications/unread-count";
  static String markNotificationAsRead(int id) => "/notifications/$id/read";
  static const String markAllNotificationsAsRead = "/notifications/read-all";
  static const String testNotification = "/notifications/test";
  static const String testMyDevice = "/notifications/test-my-device";
  static const String broadcastNotification = "/notifications/broadcast";

  // Members
  static const String membersPath = "/members";
  static String members({int page = 0, int size = 20, String? query}) {
    if (query != null && query.trim().isNotEmpty) {
      final encoded = Uri.encodeComponent(query.trim());
      return "/members?page=$page&size=$size&query=$encoded";
    }
    return "/members?page=$page&size=$size";
  }

  static String memberDetails(int id) => "/members/$id";
  static const String myProfile = "/members/me";
  static String myTransactions({int page = 0, int size = 20}) =>
      "/members/me/transactions?page=$page&size=$size";
  static String myReport(String? yearMonth) =>
      yearMonth != null && yearMonth.isNotEmpty
      ? "/members/me/report?yearMonth=$yearMonth"
      : "/members/me/report";
  static String memberReport(int id, String? yearMonth) =>
      yearMonth != null && yearMonth.isNotEmpty
      ? "/members/$id/report?yearMonth=$yearMonth"
      : "/members/$id/report";
  static const String specialLoanTypes = "/settings/special-loan-types";
  static const String surplusAmount = "/settings/surplus-amount";
  static const String expenseTypes = "/settings/expense-types";
  static const String groupProfits = "/group-profits";
  static const String groupExpenses = "/expenses";
  static const String groups = "/groups";
  static const String groupLoans = "/groups/loans";
  static const String issueGroupLoan = "/groups/issue-loan";
  static String groupDetails(int id) => "/groups/$id";
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
  static String meetingRegisterBook(int id) => "/meetings/$id/register-book";

  // Processing
  static String memberProcessingForm(int meetingId, int memberId) =>
      "/meetings/$meetingId/members/$memberId/processing";
  static String processMember(
    int meetingId,
    int memberId, {
    bool isUpdate = false,
  }) => isUpdate
      ? "/meetings/$meetingId/members/$memberId/process?isUpdate=true"
      : "/meetings/$meetingId/members/$memberId/process";

  // Reports
  static const String reportSummary = "/reports/summary";
  static String reportPeriod(String? startDate, String? endDate) {
    final params = <String, String>{};
    if (startDate != null && startDate.isNotEmpty) {
      params['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) params['endDate'] = endDate;
    final q = Uri(queryParameters: params).query;
    return q.isNotEmpty ? "/reports/period?$q" : "/reports/period";
  }

  static const String reportMemberBalances = "/reports/member-balances";
  static const String reportCategory = "/reports/category";
  static const String reportMeetingsList = "/reports/meetings";
  static String reportMeetingDetails(int id) => "/reports/meetings/$id";
  static String reportMonthlyLedger(String yearMonth) =>
      "/reports/monthly-ledger?yearMonth=$yearMonth";

  // Dashboard & Transactions
  static const String dashboardSummary = "/dashboard/summary";
  static const String recentTransactions = "/transactions/recent";

  static String allTransactions({
    int page = 0,
    int size = 50,
    String? query,
    String? accountType,
    String? transactionType,
    bool? isReversed,
    String? startDate,
    String? endDate,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      params['query'] = query.trim();
    }
    if (accountType != null && accountType.isNotEmpty) {
      params['accountType'] = accountType;
    }
    if (transactionType != null && transactionType.isNotEmpty) {
      params['transactionType'] = transactionType;
    }
    if (isReversed != null) {
      params['isReversed'] = isReversed.toString();
    }
    if (startDate != null && startDate.isNotEmpty) {
      params['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) params['endDate'] = endDate;

    final queryString = Uri(queryParameters: params).query;
    return "/transactions?$queryString";
  }

  static String reverseTransaction(int id) => "/transactions/$id/reverse";
  static const String bulkImport = "/import/bulk";
}
