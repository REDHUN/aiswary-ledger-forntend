import '../profits/add_group_profit_dialog.dart';
import '../groups/issue_group_loan_dialog.dart';
import '../../viewmodel/group_viewmodel.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../viewmodel/member_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/repository/reports_repository.dart';
import 'package:ashgledger/viewmodel/reports_viewmodel.dart';
import 'package:ashgledger/viewmodel/expense_viewmodel.dart';
import 'package:ashgledger/core/model/completed_meeting_register_model.dart';
import '../expenses/add_group_expense_dialog.dart';

enum RegisterFilterMode { all, varavu, expense }

class MeetingRegisterBookScreen extends StatelessWidget {
  final bool isReadOnly;

  const MeetingRegisterBookScreen({super.key, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(sl<ReportsRepository>())..fetchMeetings(),
      child: _MeetingRegisterBookBody(isReadOnly: isReadOnly),
    );
  }
}

class _MeetingRegisterBookBody extends StatefulWidget {
  final bool isReadOnly;

  const _MeetingRegisterBookBody({this.isReadOnly = false});

  @override
  State<_MeetingRegisterBookBody> createState() => _MeetingRegisterBookBodyState();
}

class _MeetingRegisterBookBodyState extends State<_MeetingRegisterBookBody> {
  int? _selectedMeetingId;
  RegisterFilterMode _filterMode = RegisterFilterMode.all;


  void _showIssueGroupLoanDialog(BuildContext context, int meetingId, ReportsViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<GroupViewModel>()..fetchGroups()..fetchLoanHistory()),
          ChangeNotifierProvider(create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes()),
          ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()..fetchMembers()),
        ],
        child: IssueGroupLoanDialog(preselectedMeetingId: meetingId),
      ),
    ).then((_) {
      if (context.mounted) {
        vm.fetchCompletedMeetingRegister(meetingId);
        vm.fetchMeetings();
      }
    });
  }

  

    void _showAddProfitDialog(BuildContext context, int meetingId, ReportsViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AddGroupProfitDialog(preselectedMeetingId: meetingId),
    ).then((val) {
      if (val == true && context.mounted) {
        vm.fetchCompletedMeetingRegister(meetingId);
        vm.fetchMeetings();
      }
    });
  }

  void _showAddExpenseDialog(BuildContext context, int meetingId, ReportsViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<ExpenseViewModel>()..fetchExpenseTypes()),
        ],
        child: AddGroupExpenseDialog(preselectedMeetingId: meetingId),
      ),
    ).then((_) {
      if (context.mounted) {
        vm.fetchCompletedMeetingRegister(meetingId);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: widget.isReadOnly
          ? null
          : AppBar(
              title: Text(
                isMl ? 'മീറ്റിംഗ് രജിസ്റ്റർ ബുക്ക്' : 'Meeting Register Book',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
      body: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading && vm.meetingReports.isEmpty) {
            return const MemberListShimmerLoading();
          }

          if (vm.meetingReports.isNotEmpty) {
            final validIds = vm.meetingReports.map((m) => m.meetingId).toList();
            if (_selectedMeetingId == null || !validIds.contains(_selectedMeetingId)) {
              final defaultMeeting = vm.meetingReports.firstWhere(
                (m) => m.status.toUpperCase() == 'OPEN',
                orElse: () => vm.meetingReports.firstWhere(
                  (m) => m.status.toUpperCase() == 'COMPLETED',
                  orElse: () => vm.meetingReports.first,
                ),
              );
              _selectedMeetingId = defaultMeeting.meetingId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                vm.fetchCompletedMeetingRegister(_selectedMeetingId!);
              });
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meeting Selector Dropdown
                Card(
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isMl ? 'മീറ്റിംഗ് തിരഞ്ഞെടുക്കുക:' : 'Select Meeting:',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedMeetingId,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.bgLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true,
                          items: vm.meetingReports.map((m) {
                            final isCompleted = m.status.toUpperCase() == 'COMPLETED';
                            return DropdownMenuItem<int>(
                              value: m.meetingId,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isMl
                                          ? 'മീറ്റിംഗ് #${m.meetingNumber} (${m.meetingDate})'
                                          : 'Meeting #${m.meetingNumber} (${m.meetingDate})',
                                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.success.withValues(alpha: 0.1) : AppColors.info.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      m.status.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? AppColors.success : AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMeetingId = val;
                              });
                              vm.fetchCompletedMeetingRegister(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register Book Details Card
                if (vm.registerState.isLoading)
                  const AppShimmer(width: double.infinity, height: 320, borderRadius: 16)
                else if (vm.registerState.hasError)
                  CommonErrorWidget(
                    message: vm.registerState.message ?? (isMl ? 'ലെഡ്ജർ വിവരങ്ങൾ ലഭ്യമാക്കാൻ സാധിച്ചില്ല' : 'Failed to load register book'),
                    onRetry: () {
                      if (_selectedMeetingId != null) {
                        vm.fetchCompletedMeetingRegister(_selectedMeetingId!);
                      }
                    },
                  )
                else if (vm.completedRegister != null)
                  _buildRegisterCard(context, vm.completedRegister!, vm, isMl)
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      isMl ? 'ഈ മീറ്റിംഗിന്റെ വിവരങ്ങൾ ലഭ്യമായിട്ടില്ല.' : 'No register details available for this meeting.',
                      style: GoogleFonts.outfit(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterCard(BuildContext context, CompletedMeetingRegisterModel reg, ReportsViewModel vm, bool isMl) {
    final showVaravu = _filterMode == RegisterFilterMode.all || _filterMode == RegisterFilterMode.varavu;
    final showExpense = _filterMode == RegisterFilterMode.all || _filterMode == RegisterFilterMode.expense;

    double totalVaravu = reg.totalLoanRepaymentsCollected +
        reg.totalDepositsCollected +
        reg.totalMonthlyContributionsCollected +
        reg.totalSpecialLoanRepaymentsCollected +
        reg.totalFinesCollected +
        reg.totalGroupProfit;

    double totalChelavu = reg.totalFinancialAidDisbursed + reg.totalGroupExpenses;
    int? activeActionMeetingId;
    final openMeeting = vm.meetingReports.where((m) => m.status.toUpperCase() == "OPEN").firstOrNull;
    if (openMeeting != null) {
      activeActionMeetingId = openMeeting.meetingId;
    } else {
      final completed = vm.meetingReports.where((m) => m.status.toUpperCase() == "COMPLETED").toList();
      if (completed.isNotEmpty) {
        completed.sort((a, b) => b.meetingNumber.compareTo(a.meetingNumber));
        activeActionMeetingId = completed.first.meetingId;
      }
    }
    final bool canShowActions = !widget.isReadOnly && reg.meetingId == activeActionMeetingId;
    final selectedReport = vm.meetingReports.where((m) => m.meetingId == reg.meetingId).firstOrNull;
    final bool isCompleted = selectedReport != null && selectedReport.status.toUpperCase() == "COMPLETED";

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMl ? 'മീറ്റിംഗ് രജിസ്റ്റർ ബുക്ക്' : 'Meeting Register Book',
                              style: GoogleFonts.outfit(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isMl
                                  ? 'തീയതി: ${reg.meetingDate} | പിരീഡ്: ${reg.interestPeriod}'
                                  : 'Date: ${reg.meetingDate} | Period: ${reg.interestPeriod}',
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    isMl ? 'മീറ്റിംഗ് #${reg.meetingNumber}' : 'Meeting #${reg.meetingNumber}',
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Row: Add Expense, Issue Group Loan & Record Profit Buttons (Only shown for Admin, hidden for Member)
            if (canShowActions) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddExpenseDialog(context, reg.meetingId, vm),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isMl ? 'ചെലവ് നൽകുക' : 'Add Expense',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accountLoan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showIssueGroupLoanDialog(context, reg.meetingId, vm),
                      icon: const Icon(Icons.handshake_rounded, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isMl ? 'ഗ്രൂപ്പ് വായ്പ' : 'Group Loan',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF047857),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddProfitDialog(context, reg.meetingId, vm),
                      icon: const Icon(Icons.trending_up_rounded, size: 15),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isMl ? 'ലാഭം ലഭിച്ചു' : 'Add Profit',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
                        // Filter Options (All, Varavu, Expense)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildFilterTab(
                    label: isMl ? 'എല്ലാം' : 'All',
                    mode: RegisterFilterMode.all,
                    dotColor: Colors.transparent,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    label: isMl ? 'വരവ്' : 'Collections',
                    mode: RegisterFilterMode.varavu,
                    dotColor: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    label: isMl ? 'ചെലവ്' : 'Expenses',
                    mode: RegisterFilterMode.expense,
                    dotColor: AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // SECTION 1: VARAVU (COLLECTIONS)
            if (showVaravu) ...[
              _buildSectionHeader(
                title: isMl ? 'വരവ് ഇനങ്ങൾ (കളക്ഷൻ)' : 'Collections / Income',
                dotColor: AppColors.success,
                textColor: Colors.teal.shade900,
                bgColor: Colors.teal.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 10),
              _buildRow(
                label: isMl ? 'വായ്പ തിരികെ അടവ്' : 'Loan Repayments',
                amount: reg.totalLoanRepaymentsCollected,
                isVaravu: true,
                icon: Icons.payments_rounded,
                color: AppColors.success,
              ),
              const SizedBox(height: 8),
              _buildRow(
                label: isMl ? 'നിക്ഷേപം' : 'Deposits',
                amount: reg.totalDepositsCollected,
                isVaravu: true,
                icon: Icons.savings_rounded,
                color: AppColors.info,
              ),
              const SizedBox(height: 8),
              _buildRow(
                label: isMl ? 'പ്രതിമാസ വരിസംഖ്യ' : 'Monthly Contributions',
                amount: reg.totalMonthlyContributionsCollected,
                isVaravu: true,
                icon: Icons.date_range_rounded,
                color: AppColors.accountContribution,
              ),
              const SizedBox(height: 8),
              if (reg.specialLoanBreakdown.isNotEmpty) ...[
                for (var item in reg.specialLoanBreakdown) ...[
                  _buildRow(
                    label: isMl ? '${item.specialLoanTypeName} അടവ്' : '${item.specialLoanTypeName} Repayment',
                    amount: item.amount,
                    isVaravu: true,
                    icon: Icons.stars_rounded,
                    color: AppColors.accountFinancialAid,
                  ),
                  const SizedBox(height: 8),
                ]
              ] else ...[
                _buildRow(
                  label: isMl ? 'സ്പെഷ്യൽ വായ്പ തിരികെ അടവ്' : 'Special Loan Repayments',
                  amount: reg.totalSpecialLoanRepaymentsCollected,
                  isVaravu: true,
                  icon: Icons.stars_rounded,
                  color: AppColors.accountFinancialAid,
                ),
                const SizedBox(height: 8),
              ],
              _buildRow(
                label: isMl ? 'പിഴ' : 'Fines Collected',
                amount: reg.totalFinesCollected,
                isVaravu: true,
                icon: Icons.gavel_rounded,
                color: AppColors.accountFine,
              ),
              if (reg.groupProfitsBreakdown.isNotEmpty) ...[
                for (var prof in reg.groupProfitsBreakdown) ...[
                  const SizedBox(height: 8),
                  _buildRow(
                    label: isMl ? 'ലാഭം: ${prof.title}' : 'Profit: ${prof.title}',
                    amount: prof.amount,
                    isVaravu: true,
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF047857),
                  ),
                ]
              ] else if (reg.totalGroupProfit > 0) ...[
                const SizedBox(height: 8),
                _buildRow(
                  label: isMl ? 'ലാഭം ലഭിച്ചത്' : 'Group Profit Received',
                  amount: reg.totalGroupProfit,
                  isVaravu: true,
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF047857),
                ),
              ],
              const SizedBox(height: 10),
              _buildSubtotalBar(isMl ? 'ആകെ വരവ്:' : 'Total Collections:', totalVaravu, Colors.teal.shade800, '+'),
              const SizedBox(height: 18),
            ],

            // SECTION 2: CHELAVU (EXPENSES & PAYOUTS)
            if (showExpense) ...[
              _buildSectionHeader(
                title: isMl ? 'ചെലവ് ഇനങ്ങൾ' : 'Expenses & Payouts',
                dotColor: AppColors.error,
                textColor: Colors.deepOrange.shade900,
                bgColor: Colors.deepOrange.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 10),
              if (reg.loansIssuedBreakdown.isNotEmpty) ...[
                for (var loanItem in reg.loansIssuedBreakdown) ...[
                  _buildRow(
                    label: isMl ? 'വായ്പ വിതരണം: ${loanItem.categoryName}' : 'Loan Issued: ${loanItem.categoryName}',
                    amount: loanItem.amount,
                    isVaravu: false,
                    icon: Icons.handshake_rounded,
                    color: AppColors.accountLoan,
                  ),
                  const SizedBox(height: 8),
                ],
              ] else if (reg.totalLoansIssued > 0) ...[
                _buildRow(
                  label: isMl ? 'വായ്പ വിതരണം നൽകിയത്' : 'Loans Issued',
                  amount: reg.totalLoansIssued,
                  isVaravu: false,
                  icon: Icons.handshake_rounded,
                  color: AppColors.accountLoan,
                ),
                const SizedBox(height: 8),
              ],
              _buildRow(
                label: isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid Disbursed',
                amount: reg.totalFinancialAidDisbursed,
                isVaravu: false,
                icon: Icons.volunteer_activism_rounded,
                color: AppColors.error,
              ),
              if (reg.groupExpensesBreakdown.isNotEmpty) ...[
                for (var expItem in reg.groupExpensesBreakdown) ...[
                  const SizedBox(height: 8),
                  _buildRow(
                    label: isMl
                        ? 'ചെലവ്: ${expItem.expenseTypeName}${expItem.description != null && expItem.description!.isNotEmpty ? " (${expItem.description})" : ""}'
                        : 'Expense: ${expItem.expenseTypeName}${expItem.description != null && expItem.description!.isNotEmpty ? " (${expItem.description})" : ""}',
                    amount: expItem.amount,
                    isVaravu: false,
                    icon: Icons.receipt_long_rounded,
                    color: Colors.deepOrangeAccent,
                  ),
                ],
              ] else if (reg.totalGroupExpenses > 0) ...[
                const SizedBox(height: 8),
                _buildRow(
                  label: isMl ? 'ഗ്രൂപ്പ് ചെലവുകൾ' : 'Group Expenses',
                  amount: reg.totalGroupExpenses,
                  isVaravu: false,
                  icon: Icons.receipt_long_rounded,
                  color: Colors.deepOrangeAccent,
                ),
              ],
              const SizedBox(height: 10),
              _buildSubtotalBar(isMl ? 'ആകെ ചെലവ്:' : 'Total Expenses:', totalChelavu, Colors.deepOrange.shade900, '-'),
              const SizedBox(height: 18),
            ],

            const Divider(color: AppColors.borderLight, height: 24),

            // Summary Totals Metric Cards (Overflow Protected)
            Column(
              children: [
                // Net Collection Metric
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isMl ? 'ആകെ സ്വീകരിച്ച തുക' : 'Net Collection',
                                style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${reg.totalNetMeetingCollections.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 10),
                  // Surplus Fund Highlighted Metric Card (Only shown for COMPLETED meetings)
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.savings_rounded, color: Color(0xFFB78103), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMl ? '\u0d2e\u0d3f\u0d1a\u0d4d\u0d1a \u0d24\u0d41\u0d15' : 'Surplus Fund',
                                      style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      isMl ? '\u0d07\u0d28\u0d4d\u0d28\u0d24\u0d46 \u0d2e\u0d40\u0d31\u0d4d\u0d31\u0d3f\u0d19\u0d4d\u0d19\u0d3f\u0d28\u0d4d\u0d31\u0d46 \u0d2e\u0d3f\u0d1a\u0d4d\u0d1a \u0d24\u0d41\u0d15' : 'Surplus for this meeting',
                                      style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '₹${reg.surplusAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF8A5A00),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Color dotColor,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalBar(String title, double amount, Color textColor, String sign) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required RegisterFilterMode mode,
    required Color dotColor,
  }) {
    final isSelected = _filterMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != Colors.transparent) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required double amount,
    required bool isVaravu,
    required IconData icon,
    required Color color,
  }) {
    final sign = isVaravu ? '+' : '-';
    final bgColor = isVaravu ? Colors.green.withValues(alpha: 0.03) : Colors.red.withValues(alpha: 0.03);
    final borderColor = isVaravu ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVaravu ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$sign₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                color: isVaravu ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
