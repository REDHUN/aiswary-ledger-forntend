import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/common/app_formatters.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/repository/reports_repository.dart';
import 'package:ashgledger/viewmodel/reports_viewmodel.dart';
import 'package:ashgledger/core/model/member_personal_report_model.dart';
import 'package:ashgledger/core/model/meeting_report_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ReportsViewModel(sl<ReportsRepository>())..fetchAllReports(),
      child: const _ReportsScreenBody(),
    );
  }
}

class _ReportsScreenBody extends StatefulWidget {
  const _ReportsScreenBody();

  @override
  State<_ReportsScreenBody> createState() => _ReportsScreenBodyState();
}

class _ReportsScreenBodyState extends State<_ReportsScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _memberSearchCtrl = TextEditingController();
  String _selectedCategoryFilter = 'ALL';
  String _selectedPersonalReportMonth = '';
  int _selectedMemberSubReportIndex = 0; // 0: All, 1: Standard Loans, 2: Special Loans, 3: Deposits, 4: Contributions, 5: Fines

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memberSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'റിപ്പോർട്ടുകൾ (Reports)' : 'Reports & Analytics',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: isMl ? 'അംഗ റിപ്പോർട്ട്' : 'Member Report'),
            Tab(text: isMl ? 'വായ്പ & നിക്ഷേപം' : 'Loans & Deposits'),
            Tab(text: isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid'),
            Tab(text: isMl ? 'അംഗങ്ങളുടെ ബാലൻസ്' : 'Member Balances'),
            Tab(text: isMl ? 'മീറ്റിംഗ് റിപ്പോർട്ട്' : 'Meeting Report'),
          ],
        ),
      ),
      body: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading)
            return const ReportsDashboardShimmerLoading();
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load reports',
              onRetry: () => vm.fetchAllReports(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMemberReportTab(context, vm, isMl),
              _buildCategoryLoansDepositsTab(context, vm, isMl),
              _buildFinancialAidReportTab(context, vm, isMl),
              _buildMemberBalancesTab(context, vm, isMl),
              _buildMeetingReportsTab(context, vm, isMl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryLoansDepositsTab(
    BuildContext context,
    ReportsViewModel vm,
    bool isMl,
  ) {
    final cat = vm.categoryReport;
    if (cat == null) return const MemberListShimmerLoading();

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl
                ? 'വായ്പ & നിക്ഷേപ റിപ്പോർട്ടുകൾ'
                : 'Loans & Deposits Category Report',
            subtitle: isMl
                ? 'എല്ലാ സാമ്പത്തിക വായ്പകളുടെയും നിക്ഷേപങ്ങളുടെയും വിവരങ്ങൾ'
                : 'Detailed summary of active loans and member deposits',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 16),

          // Loans Overview Cards (Row 1)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountLoan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accountLoan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add_card_rounded,
                            size: 16,
                            color: AppColors.accountLoan,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'സാധാരണ വായ്പ' : 'Regular Loans',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalOutstandingLoanBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accountLoan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loans',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalSpecialLoanBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deposits & Contributions (Row 2)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountDeposit.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accountDeposit.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.savings_rounded,
                            size: 16,
                            color: AppColors.accountDeposit,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'ആകെ നിക്ഷേപം' : 'Total Deposits',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalDepositsCollected.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accountDeposit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountContribution.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accountContribution.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: AppColors.accountContribution,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'മാസ വരിസംഖ്യ' : 'Monthly Contrib',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalContributionsCollected.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accountContribution,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fines & Financial Aid (Row 3)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountFine.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accountFine.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            size: 16,
                            color: AppColors.accountFine,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'പിഴ' : 'Fines Collected',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalFinesCollected.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accountFine,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountFinancialAid.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accountFinancialAid.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.volunteer_activism_rounded,
                            size: 16,
                            color: AppColors.accountFinancialAid,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${cat.totalFinancialAidDisbursed.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accountFinancialAid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Loan Members Section
          Text(
            isMl
                ? 'വായ്പയുള്ള അംഗങ്ങൾ (${cat.loanMembers.length})'
                : 'Active Loan Members (${cat.loanMembers.length})',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          if (cat.loanMembers.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    isMl
                        ? 'നിലവിൽ വായ്പകളൊന്നും കുടിശ്ശികയില്ല'
                        : 'No active loans outstanding',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cat.loanMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = cat.loanMembers[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accountLoan.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        '#${item.memberNumber}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountLoan,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(
                      item.fullName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      item.categoryName,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '₹${item.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.accountLoan,
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Deposit Members Section
          Text(
            isMl
                ? 'നിക്ഷേപമുള്ള അംഗങ്ങൾ (${cat.depositMembers.length})'
                : 'Deposit Members (${cat.depositMembers.length})',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          if (cat.depositMembers.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    isMl
                        ? 'നിക്ഷേപങ്ങളൊന്നും വിവരങ്ങളില്ല'
                        : 'No deposits recorded',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cat.depositMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = cat.depositMembers[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accountDeposit.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        '#${item.memberNumber}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accountDeposit,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(
                      item.fullName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      item.categoryName,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '₹${item.balance.toStringAsFixed(2)}',
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
      ),
    );
  }

  Widget _buildFinancialAidReportTab(
    BuildContext context,
    ReportsViewModel vm,
    bool isMl,
  ) {
    final cat = vm.categoryReport;
    if (cat == null) return const MemberListShimmerLoading();

    final aidList = cat.financialAidDisbursements;

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl
                ? 'സാമ്പത്തിക സഹായ റിപ്പോർട്ട്'
                : 'Financial Aid Disbursed Report',
            subtitle: isMl
                ? 'അംഗങ്ങൾക്ക് നൽകിയ സാമ്പത്തിക സഹായങ്ങളുടെ സമ്പൂർണ്ണ വിവരങ്ങൾ'
                : 'Complete record of financial aid grants given to members',
            icon: Icons.volunteer_activism_rounded,
          ),
          const SizedBox(height: 16),

          // Total Aid Disbursed KPI Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accountFinancialAid,
                  AppColors.accountFinancialAid.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accountFinancialAid.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? 'ആകെ നൽകിയ സാമ്പത്തിക സഹായം'
                            : 'Total Financial Aid Given',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${cat.totalFinancialAidDisbursed.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Disbursements History List Header
          Text(
            isMl
                ? 'സഹായ വിതരണ ഹിസ്റ്ററി (${aidList.length})'
                : 'Financial Aid Disbursements (${aidList.length})',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          if (aidList.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    isMl
                        ? 'ഇതുവരെ സാമ്പത്തിക സഹായങ്ങൾ വിതരണം ചെയ്തിട്ടില്ല'
                        : 'No financial aid disbursements recorded yet',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: aidList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = aidList[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accountFinancialAid
                              .withValues(alpha: 0.12),
                          child: Text(
                            '#${item.memberNumber}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accountFinancialAid,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fullName,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  if (item.transactionDate.isNotEmpty)
                                    Text(
                                      AppFormatters.formatDate(item.transactionDate),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  if (item.meetingNumber != '-') ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '| Meeting #${item.meetingNumber}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.notes != null &&
                                  item.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.notes!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.accountFinancialAid,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMemberBalancesTab(
    BuildContext context,
    ReportsViewModel vm,
    bool isMl,
  ) {
    final categories = [
      {'key': 'ALL', 'labelMl': 'എല്ലാം (All)', 'labelEn': 'All'},
      {'key': 'LOAN', 'labelMl': 'സാധാരണ വായ്പ', 'labelEn': 'Regular Loans'},
      {
        'key': 'SPECIAL_LOAN',
        'labelMl': 'സ്പെഷ്യൽ വായ്പ',
        'labelEn': 'Special Loans',
      },
      {'key': 'DEPOSIT', 'labelMl': 'നിക്ഷേപം', 'labelEn': 'Deposits'},
      {
        'key': 'CONTRIBUTION',
        'labelMl': 'വരിസംഖ്യ',
        'labelEn': 'Contributions',
      },
      {'key': 'FINE', 'labelMl': 'പിഴ', 'labelEn': 'Fines'},
      {'key': 'AID', 'labelMl': 'സാമ്പത്തിക സഹായം', 'labelEn': 'Financial Aid'},
    ];

    final rawList = vm.filteredMemberBalances;
    final filteredMembers = rawList.where((m) {
      switch (_selectedCategoryFilter) {
        case 'LOAN':
          return m.loanBalance > 0;
        case 'SPECIAL_LOAN':
          return m.specialLoanBalance > 0 || m.specialLoanBalances.isNotEmpty;
        case 'DEPOSIT':
          return m.depositBalance > 0;
        case 'CONTRIBUTION':
          return m.contributionBalance > 0;
        case 'FINE':
          return m.fineBalance > 0;
        case 'AID':
          return m.financialAidBalance > 0;
        default:
          return true;
      }
    }).toList();

    double categoryTotal = 0.0;
    for (var m in filteredMembers) {
      switch (_selectedCategoryFilter) {
        case 'LOAN':
          categoryTotal += m.loanBalance;
          break;
        case 'SPECIAL_LOAN':
          categoryTotal += m.specialLoanBalance;
          break;
        case 'DEPOSIT':
          categoryTotal += m.depositBalance;
          break;
        case 'CONTRIBUTION':
          categoryTotal += m.contributionBalance;
          break;
        case 'FINE':
          categoryTotal += m.fineBalance;
          break;
        case 'AID':
          categoryTotal += m.financialAidBalance;
          break;
        default:
          categoryTotal += m.netBalance;
          break;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _memberSearchCtrl,
            onChanged: (val) => vm.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: isMl
                  ? 'അംഗത്തിന്റെ പേര് അല്ലെങ്കിൽ നമ്പർ...'
                  : 'Search member name or number...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Category Report Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategoryFilter == cat['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    isMl ? cat['labelMl']! : cat['labelEn']!,
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategoryFilter = cat['key']!;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Category Summary Banner (when a specific category filter is active)
        if (_selectedCategoryFilter != 'ALL')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? '${categories.firstWhere((c) => c['key'] == _selectedCategoryFilter)['labelMl']} റിപ്പോർട്ട്'
                            : '${categories.firstWhere((c) => c['key'] == _selectedCategoryFilter)['labelEn']} Report',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '${filteredMembers.length} ${isMl ? "അംഗങ്ങൾ" : "members"} | Total: ₹${categoryTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${categoryTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

        // Itemized Member List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredMembers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final m = filteredMembers[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      '#${m.memberNumber}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    m.fullName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Loan: ₹${m.loanBalance.toStringAsFixed(2)} | Deposit: ₹${m.depositBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'സാധാരണ വായ്പ (Loan Balance)',
                            m.loanBalance,
                            AppColors.accountLoan,
                          ),
                          ...m.specialLoanBalances.map((spl) {
                            String splTitle = spl.specialLoanTypeName;
                            if (splTitle == 'Special Loan') {
                              splTitle = isMl
                                  ? 'സ്പെഷ്യൽ വായ്പ'
                                  : 'Special Loan';
                            }
                            return Column(
                              children: [
                                const SizedBox(height: 6),
                                _buildDetailRow(
                                  splTitle,
                                  spl.currentBalance,
                                  Colors.deepOrange,
                                ),
                              ],
                            );
                          }),
                          if (m.specialLoanBalances.isEmpty &&
                              m.specialLoanBalance > 0) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow(
                              isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan',
                              m.specialLoanBalance,
                              Colors.deepOrange,
                            ),
                          ],
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'നിക്ഷേപം (Deposit Balance)',
                            m.depositBalance,
                            AppColors.accountDeposit,
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'വരിസംഖ്യ (Contribution)',
                            m.contributionBalance,
                            AppColors.accountContribution,
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'പിഴ (Fines Balance)',
                            m.fineBalance,
                            AppColors.accountFine,
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'സാമ്പത്തിക സഹായം (Financial Aid)',
                            m.financialAidBalance,
                            AppColors.accountFinancialAid,
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'പലിശ (Interest Balance)',
                            m.interestBalance,
                            AppColors.accountInterest,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.assessment_rounded,
                                size: 18,
                              ),
                              label: Text(
                                isMl
                                    ? 'വ്യക്തിഗത റിപ്പോർട്ട് കാണുക'
                                    : 'View Monthly Report',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                vm.selectMemberForReport(m);
                                _tabController.animateTo(0);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingReportsTab(
    BuildContext context,
    ReportsViewModel vm,
    bool isMl,
  ) {
    final reports = vm.meetingReports;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final m = reports[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                '#${m.meetingNumber}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Meeting #${m.meetingNumber} (${AppFormatters.formatDate(m.meetingDate)})',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Total Collected: ₹${m.totalCollected.toStringAsFixed(2)} | Surplus: ₹${m.surplusAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (m.totalGroupExpenses > 0)
                  Text(
                    'Expenses: ₹${m.totalGroupExpenses.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.deepOrange,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showMeetingDetailModal(context, m, isMl),
          ),
        );
      },
    );
  }

  void _showMeetingDetailModal(
    BuildContext context,
    MeetingReportModel m,
    bool isMl,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting #${m.meetingNumber} (${AppFormatters.formatDate(m.meetingDate)}) Details',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow(
                    'സാധാരണ വയ്പ അടവ്',
                    m.totalLoanRepayments,
                    AppColors.success,
                  ),
                  if (m.totalSpecialLoanRepayments > 0) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      'സ്പെഷ്യൽ വായ്പ അടവ്',
                      m.totalSpecialLoanRepayments,
                      AppColors.accountFinancialAid,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    'നിക്ഷേപം (Deposits)',
                    m.totalDepositsCollected,
                    AppColors.info,
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    'വരിസംഖ്യ (Monthly Contribution)',
                    m.totalMonthlyContributions,
                    AppColors.accountContribution,
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    'പിഴ (Fines)',
                    m.totalFinesCollected,
                    AppColors.accountFine,
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    'സാമ്പത്തിക സഹായം',
                    m.totalFinancialAid,
                    AppColors.error,
                  ),
                  if (m.totalGroupExpenses > 0) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      'ഗ്രൂപ്പ് ചെലവുകൾ',
                      m.totalGroupExpenses,
                      Colors.deepOrange,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    'മിച്ച തുക (Surplus Reserve)',
                    m.surplusAmount,
                    Colors.teal,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Member Collections:',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var c in m.memberCollections)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '#${c.memberNumber} ${c.fullName}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      trailing: Text(
                        '₹${c.totalMemberCollected.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
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

  // ==========================================
  // Member Personal Report Tab (Admin Side)
  // ==========================================

  Widget _buildMemberReportTab(
    BuildContext context,
    ReportsViewModel vm,
    bool isMl,
  ) {
    final members = vm.memberBalances;
    final selectedMember = vm.selectedMemberForReport;
    final report = vm.memberPersonalReport;
    
    // Deduplicate and prepare months list
    final uniqueMonths = <String>{};
    if (report?.availableMonths != null) {
      for (final m in report!.availableMonths) {
        if (m.trim().isNotEmpty) {
          uniqueMonths.add(m.trim());
        }
      }
    }
    if (report != null && report.yearMonth.trim().isNotEmpty) {
      uniqueMonths.add(report.yearMonth.trim());
    }
    final monthsList = uniqueMonths.toList();

    // Determine current active month
    String? activeMonth;
    if (_selectedPersonalReportMonth.isNotEmpty && monthsList.contains(_selectedPersonalReportMonth)) {
      activeMonth = _selectedPersonalReportMonth;
    } else if (report != null && report.yearMonth.isNotEmpty && monthsList.contains(report.yearMonth)) {
      activeMonth = report.yearMonth;
      _selectedPersonalReportMonth = report.yearMonth;
    } else if (monthsList.isNotEmpty) {
      activeMonth = monthsList.first;
      _selectedPersonalReportMonth = monthsList.first;
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (selectedMember != null) {
          await vm.fetchMemberPersonalReport(
            selectedMember.memberId,
            _selectedPersonalReportMonth.isNotEmpty ? _selectedPersonalReportMonth : null,
          );
        } else {
          await vm.fetchAllReports();
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Member Selection Dropdown Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: Text(
                        isMl ? 'അംഗത്തെ തിരഞ്ഞെടുക്കുക' : 'Select Member',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: selectedMember?.memberId,
                      items: members.map((m) {
                        return DropdownMenuItem<int>(
                          value: m.memberId,
                          child: Text(
                            '#${m.memberNumber} - ${m.fullName}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final member = members.firstWhere((m) => m.memberId == val);
                          setState(() {
                            _selectedPersonalReportMonth = '';
                          });
                          vm.selectMemberForReport(member);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (selectedMember == null)
            _buildEmptyReportCard(
              isMl
                  ? 'ദയവായി ഒരു അംഗത്തെ തിരഞ്ഞെടുക്കുക.'
                  : 'Please select a member to view report.',
              isMl,
            )
          else ...[
            // Sub-Report Category Selection Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMemberReportFilterChip(
                    0,
                    isMl ? 'എല്ലാം (Overview)' : 'Overview',
                    Icons.summarize_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMemberReportFilterChip(
                    1,
                    isMl ? 'സാധാരണ വായ്പ' : 'Standard Loans',
                    Icons.add_card_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMemberReportFilterChip(
                    2,
                    isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loans',
                    Icons.stars_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMemberReportFilterChip(
                    3,
                    isMl ? 'നിക്ഷേപങ്ങൾ' : 'Deposits / Savings',
                    Icons.savings_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMemberReportFilterChip(
                    4,
                    isMl ? 'വരിസംഖ്യ' : 'Contributions',
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildMemberReportFilterChip(
                    5,
                    isMl ? 'പിഴ' : 'Fines',
                    Icons.gavel_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Month Selection Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      value: activeMonth,
                      underline: const SizedBox.shrink(),
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.primary,
                      ),
                      items: monthsList.map((m) {
                        return DropdownMenuItem<String>(
                          value: m,
                          child: Text(
                            m,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPersonalReportMonth = val;
                          });
                          vm.fetchMemberPersonalReport(
                            selectedMember.memberId,
                            val,
                          );
                        }
                      },
                    )
                  else
                    Text(
                      report?.yearMonth.isNotEmpty == true
                          ? report!.yearMonth
                          : '-',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (vm.memberPersonalReportState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (vm.memberPersonalReportState.hasError)
              CommonErrorWidget(
                message: vm.memberPersonalReportState.message ??
                    'Failed to load member report',
                onRetry: () => vm.fetchMemberPersonalReport(
                  selectedMember.memberId,
                  _selectedPersonalReportMonth.isNotEmpty
                      ? _selectedPersonalReportMonth
                      : null,
                ),
              )
            else if (report == null)
              _buildEmptyReportCard(
                isMl
                    ? 'ഈ മാസത്തെ റിപ്പോർട്ട് ലഭ്യമായിട്ടില്ല.'
                    : 'Report not available for this month.',
                isMl,
              )
            else ...[
              if (_selectedMemberSubReportIndex == 0)
                _buildMemberOverviewReportSection(report, isMl),
              if (_selectedMemberSubReportIndex == 1)
                _buildMemberLoanRepaymentsReportSection(report, isMl),
              if (_selectedMemberSubReportIndex == 2)
                _buildMemberSpecialLoanReportSection(report, isMl),
              if (_selectedMemberSubReportIndex == 3)
                _buildMemberDepositsReportSection(report, isMl),
              if (_selectedMemberSubReportIndex == 4)
                _buildMemberContributionsReportSection(report, isMl),
              if (_selectedMemberSubReportIndex == 5)
                _buildMemberFinesReportSection(report, isMl),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMemberReportFilterChip(int index, String label, IconData icon) {
    final isSelected = _selectedMemberSubReportIndex == index;
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
        if (val) setState(() => _selectedMemberSubReportIndex = index);
      },
    );
  }

  // 1. Overview Sub-Report
  Widget _buildMemberOverviewReportSection(
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${report.totalPaidInPeriod.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.primaryDark,
                      ),
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
                      color: Colors.deepOrange,
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
                          Colors.deepOrange,
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

  // 2. Loan Repayments Sub-Report
  Widget _buildMemberLoanRepaymentsReportSection(
    MemberPersonalReportModel report,
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
  Widget _buildMemberSpecialLoanReportSection(
    MemberPersonalReportModel report,
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
  Widget _buildMemberDepositsReportSection(
    MemberPersonalReportModel report,
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
                      isMl ? 'നിക്ഷേപങ്ങൾ (ആകെ)' : 'Deposits Added in Month',
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
  Widget _buildMemberContributionsReportSection(
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
  Widget _buildMemberFinesReportSection(
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
}
