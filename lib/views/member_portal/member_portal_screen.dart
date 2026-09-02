import '../reports/meeting_register_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/common/app_formatters.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/api_client.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/member_portal_viewmodel.dart';
import '../../core/model/member_model.dart';
import '../../core/model/member_account_model.dart';
import '../../core/model/member_personal_report_model.dart';
import '../auth/login_screen.dart';
import 'member_all_transactions_screen.dart';

class MemberPortalScreen extends StatelessWidget {
  const MemberPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberPortalViewModel(sl<ApiClient>())..fetchMyData(),
      child: const _MemberPortalBody(),
    );
  }
}

class _MemberPortalBody extends StatefulWidget {
  const _MemberPortalBody();

  @override
  State<_MemberPortalBody> createState() => _MemberPortalBodyState();
}

class _MemberPortalBodyState extends State<_MemberPortalBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportMonth = '';
  int _selectedSubReportIndex =
      0; // 0: All, 1: Standard Loans, 2: Special Loans, 3: Deposits, 4: Contributions, 5: Fines

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isMl ? 'അംഗങ്ങളുടെ പോർട്ടൽ' : 'Member Portal',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<MemberPortalViewModel>().fetchMyData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await authVm.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: isMl ? 'എന്റെ അക്കൗണ്ട്' : 'My Account'),
            Tab(text: isMl ? 'എന്റെ റിപ്പോർട്ടുകൾ' : 'My Reports'),
            Tab(text: isMl ? 'രജിസ്റ്റർ ബുക്ക്' : 'Register Book'),
          ],
        ),
      ),
      body: Consumer<MemberPortalViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const MemberPortalShimmerLoading();
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load profile',
              onRetry: () => vm.fetchMyData(),
            );
          }

          final member = vm.memberProfile;
          if (member == null) return const SizedBox();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildLedgerTab(context, vm, member, isMl),
              _buildReportsTab(context, vm, member, isMl),
              const MeetingRegisterBookScreen(isReadOnly: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLedgerTab(
    BuildContext context,
    MemberPortalViewModel vm,
    MemberModel member,
    bool isMl,
  ) {
    return RefreshIndicator(
      onRefresh: () => vm.fetchMyData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMemberHeader(member, isMl),
          const SizedBox(height: 20),
          Text(
            '${member.accounts.length} ${isMl ? "അക്കൗണ്ട് ബാലൻസുകൾ" : "Account Balances"}',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildAccountsList(member, isMl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isMl ? 'എന്റെ ഇടപാടുകൾ' : 'My Transactions',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (vm.myTransactions.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<MemberPortalViewModel>(),
                          child: const MemberAllTransactionsScreen(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isMl ? 'എല്ലാം കാണുക' : 'View All',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTransactionsList(vm, isMl),
        ],
      ),
    );
  }

  Widget _buildReportsTab(
    BuildContext context,
    MemberPortalViewModel vm,
    MemberModel member,
    bool isMl,
  ) {
    final report = vm.myReport;
    final monthsList = report?.availableMonths ?? [];

    if (_selectedReportMonth.isEmpty && monthsList.isNotEmpty) {
      _selectedReportMonth = report?.yearMonth ?? monthsList.first;
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.fetchMyReport(_selectedReportMonth);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sub-Report Category Selection Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReportFilterChip(
                  0,
                  isMl ? 'എല്ലാം (Overview)' : 'Overview',
                  Icons.summarize_rounded,
                  isMl,
                ),
                const SizedBox(width: 8),
                _buildReportFilterChip(
                  1,
                  isMl ? 'സാധാരണ വായ്പ' : 'Standard Loans',
                  Icons.add_card_rounded,
                  isMl,
                ),
                const SizedBox(width: 8),
                _buildReportFilterChip(
                  2,
                  isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loans',
                  Icons.stars_rounded,
                  isMl,
                ),
                const SizedBox(width: 8),
                _buildReportFilterChip(
                  3,
                  isMl ? 'നിക്ഷേപങ്ങൾ' : 'Deposits / Savings',
                  Icons.savings_rounded,
                  isMl,
                ),
                const SizedBox(width: 8),
                _buildReportFilterChip(
                  4,
                  isMl ? 'വരിസംഖ്യ' : 'Contributions',
                  Icons.calendar_today_rounded,
                  isMl,
                ),
                const SizedBox(width: 8),
                _buildReportFilterChip(
                  5,
                  isMl ? 'പിഴ' : 'Fines',
                  Icons.gavel_rounded,
                  isMl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Month Selection Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMl ? 'മാസം തിരഞ്ഞെടുക്കുക:' : 'Select Month:',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (monthsList.isNotEmpty)
                  DropdownButton<String>(
                    value: monthsList.contains(_selectedReportMonth)
                        ? _selectedReportMonth
                        : monthsList.first,
                    items: monthsList.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          m,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedReportMonth = val;
                        });
                        vm.fetchMyReport(val);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (report == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Render specific sub-report content according to selection
            if (_selectedSubReportIndex == 0)
              _buildOverviewReportSection(report, isMl),
            if (_selectedSubReportIndex == 1)
              _buildLoanRepaymentsReportSection(report, member, isMl),
            if (_selectedSubReportIndex == 2)
              _buildSpecialLoanReportSection(report, member, isMl),
            if (_selectedSubReportIndex == 3)
              _buildDepositsReportSection(report, member, isMl),
            if (_selectedSubReportIndex == 4)
              _buildContributionsReportSection(report, isMl),
            if (_selectedSubReportIndex == 5)
              _buildFinesReportSection(report, isMl),
          ],
        ],
      ),
    );
  }

  Widget _buildReportFilterChip(
    int index,
    String label,
    IconData icon,
    bool isMl,
  ) {
    final isSelected = _selectedSubReportIndex == index;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedSubReportIndex = index);
      },
    );
  }

  // 1. Overview Sub-Report
  Widget _buildOverviewReportSection(
    MemberPersonalReportModel report,
    bool isMl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMl ? 'ഈ മാസത്തെ ആകെ അടവ്:' : 'Month Total Paid:',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '₹${report.totalPaidInPeriod.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMl ? 'സാധാരണ വായ്പ അടവ്:' : 'Standard Loan Repaid:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${report.totalLoanRepaid.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accountLoan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMl ? 'സ്പെഷ്യൽ വായ്പ അടവ്:' : 'Special Loan Repaid:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${report.totalSpecialLoanRepaid.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMl ? 'നിക്ഷേപങ്ങൾ:' : 'Deposits Added:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹${report.totalDeposits.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accountDeposit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl ? 'മീറ്റിംഗ് അടവുകൾ' : 'Meeting Payment Entries',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (report.meetingPayments.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തെ അടവുകൾ ലഭ്യമല്ല.'
                : 'No payment entries recorded for this month.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: report.meetingPayments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = report.meetingPayments[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '₹${item.totalPaid.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      if (item.loanRepayment > 0)
                        _buildReceiptRow(
                          isMl ? 'സാധാരണ വായ്പ അടവ്' : 'Loan Repay',
                          item.loanRepayment,
                          AppColors.accountLoan,
                        ),
                      if (item.specialLoanRepayment > 0)
                        _buildReceiptRow(
                          item.specialLoanTypeName != null &&
                                  item.specialLoanTypeName!.isNotEmpty
                              ? item.specialLoanTypeName!
                              : (isMl
                                    ? 'സ്പെഷ്യൽ വായ്പ അടവ്'
                                    : 'Special Loan Repay'),
                          item.specialLoanRepayment,
                          Colors.purple,
                        ),
                      if (item.depositAddition > 0)
                        _buildReceiptRow(
                          isMl ? 'നിക്ഷേപം' : 'Deposit',
                          item.depositAddition,
                          AppColors.accountDeposit,
                        ),
                      if (item.contributionAddition > 0)
                        _buildReceiptRow(
                          isMl ? 'വരിസംഖ്യ' : 'Contribution',
                          item.contributionAddition,
                          AppColors.accountContribution,
                        ),
                      if (item.finePayment > 0)
                        _buildReceiptRow(
                          isMl ? 'പിഴ' : 'Fine',
                          item.finePayment,
                          AppColors.accountFine,
                        ),
                      if (item.financialAidPayment > 0)
                        _buildReceiptRow(
                          isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid',
                          item.financialAidPayment,
                          AppColors.accountFinancialAid,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // 2. Standard Loan Repayments Sub-Report
  Widget _buildLoanRepaymentsReportSection(
    MemberPersonalReportModel report,
    MemberModel member,
    bool isMl,
  ) {
    final loanEntries = report.meetingPayments
        .where((e) => e.loanRepayment > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLoanSummaryCard(report, isMl),
        const SizedBox(height: 16),
        // Loan Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accountLoan.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accountLoan.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accountLoan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_card_rounded,
                      color: AppColors.accountLoan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? 'സാധാരണ വായ്പ അടവ് (ആകെ)'
                            : 'Standard Loan Repayments',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${report.totalLoanRepaid.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountLoan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl ? 'വായ്പ തിരിച്ചടവ് വിവരങ്ങൾ' : 'Standard Loan Breakdown',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (loanEntries.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തിൽ വായ്പ തിരിച്ചടവുകളൊന്നും ഉണ്ടായിട്ടില്ല.'
                : 'No loan repayments in this period.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loanEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = loanEntries[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '₹${item.loanRepayment.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.accountLoan,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      _buildReceiptRow(
                        isMl ? 'സാധാരണ വായ്പ അടവ്' : 'Standard Loan Repay',
                        item.loanRepayment,
                        AppColors.accountLoan,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // 3. Special Loan Sub-Report
  Widget _buildSpecialLoanReportSection(
    MemberPersonalReportModel report,
    MemberModel member,
    bool isMl,
  ) {
    final specialLoanEntries = report.meetingPayments
        .where((e) => e.specialLoanRepayment > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Special Loan Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.deepOrange.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? 'സ്പെഷ്യൽ വായ്പ തിരിച്ചടവുകൾ'
                            : 'Special Loan Repayments',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${report.totalSpecialLoanRepaid.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl
              ? 'സ്പെഷ്യൽ വായ്പ തിരിച്ചടവ് വിവരങ്ങൾ'
              : 'Special Loan Breakdown',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (specialLoanEntries.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തിൽ സ്പെഷ്യൽ വായ്പ തിരിച്ചടവുകളൊന്നും ഉണ്ടായിട്ടില്ല.'
                : 'No special loan repayments in this period.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specialLoanEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = specialLoanEntries[index];
              final typeName = item.specialLoanTypeName?.isNotEmpty == true
                  ? item.specialLoanTypeName!
                  : (isMl ? 'സ്പെഷ്യൽ വായ്പ അടവ്' : 'Special Loan Repay');

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '₹${item.specialLoanRepayment.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      _buildReceiptRow(
                        typeName,
                        item.specialLoanRepayment,
                        Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // 4. Deposits Sub-Report
  Widget _buildDepositsReportSection(
    MemberPersonalReportModel report,
    MemberModel member,
    bool isMl,
  ) {
    final depositEntries = report.meetingPayments
        .where((e) => e.depositAddition > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Deposit Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accountDeposit.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accountDeposit.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accountDeposit.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.accountDeposit,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMl
                          ? 'നിക്ഷേപങ്ങൾ (ആകെ)'
                          : 'Deposits Added in Month',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${report.totalDeposits.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountDeposit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accountDeposit.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isMl ? 'മാസാന്ത്യ ബാക്കി' : 'Month End',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: AppColors.accountDeposit,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '₹${report.monthEndDepositBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountDeposit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl ? 'നിക്ഷേപ അടവ് വിവരങ്ങൾ' : 'Deposit Additions History',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (depositEntries.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തിൽ നിക്ഷേപങ്ങൾ ഒന്നും അടച്ചിട്ടില്ല.'
                : 'No deposits added in this period.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: depositEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = depositEntries[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accountDeposit.withValues(
                      alpha: 0.12,
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: AppColors.accountDeposit,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Text(
                    isMl ? 'നിക്ഷേപ തുക കൂട്ടിച്ചേർത്തു' : 'Deposit Added',
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Text(
                    '+₹${item.depositAddition.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.accountDeposit,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // 5. Contributions Sub-Report
  Widget _buildContributionsReportSection(
    MemberPersonalReportModel report,
    bool isMl,
  ) {
    final entries = report.meetingPayments
        .where((e) => e.contributionAddition > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly Contribution Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accountContribution.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accountContribution.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accountContribution.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.accountContribution,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? 'മാസ വരിസംഖ്യ (ആകെ)'
                            : 'Monthly Contributions',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${report.totalMonthlyContributions.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountContribution,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl
              ? 'വരിസംഖ്യ അടവ് വിവരങ്ങൾ'
              : 'Contributions Breakdown',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തിൽ വരിസംഖ്യ അടവുകളൊന്നും ഇല്ല.'
                : 'No contribution payments in this period.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = entries[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '₹${item.contributionAddition.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.accountContribution,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      _buildReceiptRow(
                        isMl ? 'മാസ വരിസംഖ്യ' : 'Monthly Contribution',
                        item.contributionAddition,
                        AppColors.accountContribution,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // 6. Fines Sub-Report
  Widget _buildFinesReportSection(
    MemberPersonalReportModel report,
    bool isMl,
  ) {
    final entries = report.meetingPayments
        .where((e) => e.finePayment > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fines Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accountFine.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accountFine.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accountFine.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: AppColors.accountFine,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'അടച്ച പിഴ (ആകെ)' : 'Total Fines Paid',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${report.totalFinesPaid.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountFine,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isMl ? 'പിഴ അടവ് വിവരങ്ങൾ' : 'Fines Breakdown',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _buildEmptyReportCard(
            isMl
                ? 'ഈ മാസത്തിൽ പിഴ അടവുകളൊന്നും ഇല്ല.'
                : 'No fine payments in this period.',
            isMl,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = entries[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meeting #${item.meetingNumber} (${AppFormatters.formatDate(item.meetingDate)})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '₹${item.finePayment.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.accountFine,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14),
                      _buildReceiptRow(
                        isMl ? 'പിഴ അടവ്' : 'Fine Payment',
                        item.finePayment,
                        AppColors.accountFine,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyReportCard(String message, bool isMl) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        message,
        style: GoogleFonts.outfit(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildLoanSummaryCard(MemberPersonalReportModel report, bool isMl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isMl ? 'വായ്പ വിവരങ്ങൾ' : 'Loan Details',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (report.yearMonth.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    report.yearMonth,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _buildLoanStatItem(
                title: isMl ? 'മാസാരംഭ ബാക്കി' : 'Start Balance',
                subtitle: isMl ? 'Start Balance' : null,
                amount: report.startMonthRemainingLoanBalance,
                color: const Color(0xFF1565C0),
              ),
              Container(
                height: 36,
                width: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              _buildLoanStatItem(
                title: isMl ? 'ഈ മാസ പലിശ' : 'Month Interest',
                subtitle: isMl ? 'Interest' : null,
                amount: report.monthInterest,
                color: const Color(0xFFE65100),
              ),
              Container(
                height: 36,
                width: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              _buildLoanStatItem(
                title: isMl ? 'മാസാന്ത്യ ബാക്കി' : 'End Balance',
                subtitle: isMl ? 'End Balance' : null,
                amount: report.monthEndRemainingLoanBalance,
                color: const Color(0xFFC62828),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanStatItem({
    required String title,
    String? subtitle,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              '($subtitle)',
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberHeader(MemberModel member, bool isMl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF198754)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  member.memberNumber,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            member.fullName,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          if (member.phone != null)
            Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  member.phone!,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          if (member.address != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.address!,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountsList(MemberModel member, bool isMl) {
    if (member.accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          isMl ? 'അക്കൗണ്ടുകളൊന്നും ലഭ്യമല്ല.' : 'No accounts found.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: member.accounts
          .map((acc) => _buildAccountTile(acc, isMl))
          .toList(),
    );
  }

  Widget _buildAccountTile(MemberAccountModel acc, bool isMl) {
    Color color = AppColors.primary;
    IconData icon = Icons.account_balance_wallet_rounded;

    if (acc.accountType == 'LOAN') {
      color = AppColors.accountLoan;
      icon = Icons.add_card_rounded;
    } else if (acc.accountType == 'DEPOSIT') {
      color = AppColors.accountDeposit;
      icon = Icons.savings_rounded;
    } else if (acc.accountType == 'FINE') {
      color = AppColors.accountFine;
      icon = Icons.gavel_rounded;
    } else if (acc.accountType == 'FINANCIAL_AID') {
      color = AppColors.accountFinancialAid;
      icon = Icons.volunteer_activism_rounded;
    } else if (acc.accountType == 'MONTHLY_CONTRIBUTION') {
      color = AppColors.accountContribution;
      icon = Icons.calendar_today_rounded;
    } else if (acc.accountType == 'INTEREST') {
      color = AppColors.accountInterest;
      icon = Icons.calculate_rounded;
    } else if (acc.accountType == 'SPECIAL_LOAN') {
      color = Colors.deepOrange;
      icon = Icons.stars_rounded;
    }

    String title = acc.accountType;
    if (acc.accountType == 'LOAN') title = isMl ? 'വായ്പ' : 'Standard Loan';
    if (acc.accountType == 'DEPOSIT') title = isMl ? 'നിക്ഷേപം' : 'Deposit';
    if (acc.accountType == 'MONTHLY_CONTRIBUTION')
      title = isMl ? 'മാസ വരി' : 'Monthly Contribution';
    if (acc.accountType == 'FINE') title = isMl ? 'ഫൈൻ' : 'Fine';
    if (acc.accountType == 'FINANCIAL_AID')
      title = isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid';
    if (acc.accountType == 'INTEREST') title = isMl ? 'പലിശ' : 'Interest';

    if (acc.accountType == 'SPECIAL_LOAN') {
      title =
          acc.specialLoanTypeName != null && acc.specialLoanTypeName!.isNotEmpty
          ? acc.specialLoanTypeName!
          : (isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan');
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: acc.accountType == 'SPECIAL_LOAN'
            ? Text(
                isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan Account',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Text(
          '₹${acc.currentBalance.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(MemberPortalViewModel vm, bool isMl) {
    if (vm.myTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          isMl ? 'ഇടപാടുകളൊന്നും ലഭ്യമല്ല.' : 'No transactions recorded.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
      );
    }

    final displayTxs = vm.myTransactions.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayTxs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = displayTxs[index];
        final isAddition =
            tx.transactionType == 'REPAYMENT' ||
            tx.transactionType == 'ADDITION';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor:
                  (isAddition ? AppColors.success : AppColors.error).withValues(
                    alpha: 0.1,
                  ),
              child: Icon(
                isAddition
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isAddition ? AppColors.success : AppColors.error,
                size: 18,
              ),
            ),
            title: Text(
              tx.accountType,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              AppFormatters.formatDateTime(tx.createdAt),
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
            ),
            trailing: Text(
              '${isAddition ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isAddition ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }
}
