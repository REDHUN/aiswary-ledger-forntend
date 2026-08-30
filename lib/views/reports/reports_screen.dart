import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/common/app_date_picker.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/repository/reports_repository.dart';
import 'package:ashgledger/viewmodel/reports_viewmodel.dart';
import 'package:ashgledger/core/model/meeting_report_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(sl<ReportsRepository>())..fetchAllReports(),
      child: const _ReportsScreenBody(),
    );
  }
}

class _ReportsScreenBody extends StatefulWidget {
  const _ReportsScreenBody();

  @override
  State<_ReportsScreenBody> createState() => _ReportsScreenBodyState();
}

class _ReportsScreenBodyState extends State<_ReportsScreenBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _memberSearchCtrl = TextEditingController();
  String _selectedCategoryFilter = 'ALL';
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: [
            Tab(text: isMl ? 'ആകെ വിവരങ്ങൾ' : 'Overview'),
            Tab(text: isMl ? 'പിരീഡ് റിപ്പോർട്ട്' : 'Period'),
            Tab(text: isMl ? 'വായ്പ & നിക്ഷേപം' : 'Loans & Deposits'),
            Tab(text: isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid'),
            Tab(text: isMl ? 'അംഗങ്ങളുടെ ബാലൻസ്' : 'Member Balances'),
            Tab(text: isMl ? 'മീറ്റിംഗ് റിപ്പോർട്ട്' : 'Meeting Report'),
          ],
        ),
      ),
      body: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const ReportsDashboardShimmerLoading();
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load reports',
              onRetry: () => vm.fetchAllReports(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, vm, isMl),
              _buildPeriodTab(context, vm, isMl),
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

  Widget _buildOverviewTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final summary = vm.summaryReport;
    if (summary == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl ? 'ആകെ സാമ്പത്തിക സ്ഥിതി' : 'Total Financial Position',
            subtitle: isMl ? '${summary.activeMembers} സജീവ അംഗങ്ങൾ' : '${summary.activeMembers} Active Members',
            icon: Icons.pie_chart_rounded,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildReportCard(
                isMl ? 'മിച്ച തുക (Surplus Reserve)' : 'Surplus Reserve Fund',
                summary.surplusAmount,
                Colors.teal,
                Icons.account_balance_wallet_rounded,
              ),
              _buildReportCard(
                isMl ? 'സ്പെഷ്യൽ വായ്പകൾ' : 'Special Loans Balance',
                summary.totalSpecialLoanBalance,
                Colors.purple,
                Icons.stars_rounded,
              ),
              _buildReportCard(
                isMl ? 'സാധാരണ വായ്പകൾ' : 'Normal Loans Balance',
                summary.totalOutstandingLoans,
                AppColors.accountLoan,
                Icons.add_card_rounded,
              ),
              _buildReportCard(
                isMl ? 'നിക്ഷേപം (Deposits)' : 'Deposits Balance',
                summary.totalDeposits,
                AppColors.accountDeposit,
                Icons.savings_rounded,
              ),
              _buildReportCard(
                isMl ? 'പ്രതിമാസ വരിസംഖ്യ' : 'Monthly Contributions',
                summary.totalMonthlyContributions,
                AppColors.accountContribution,
                Icons.calendar_today_rounded,
              ),
              _buildReportCard(
                isMl ? 'ഗ്രൂപ്പ് ചെലവുകൾ' : 'Group Expenses',
                summary.totalGroupExpenses,
                Colors.deepOrange,
                Icons.receipt_long_rounded,
              ),
              _buildReportCard(
                isMl ? 'പിഴ തുക' : 'Outstanding Fines',
                summary.totalOutstandingFines,
                AppColors.accountFine,
                Icons.gavel_rounded,
              ),
              _buildReportCard(
                isMl ? 'സാമ്പത്തിക സഹായം' : 'Financial Aid',
                summary.totalOutstandingFinancialAid,
                AppColors.accountFinancialAid,
                Icons.volunteer_activism_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final period = vm.periodReport;

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                  Text(
                    isMl ? 'തിയതി പരിധി തിരഞ്ഞെടുക്കുക' : 'Filter Date Range',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await AppDatePicker.pickDate(
                              context: context,
                              initialDate: vm.startDate != null ? (DateTime.tryParse(vm.startDate!) ?? DateTime.now()) : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (d != null) {
                              vm.setDateRange(d.toString().substring(0, 10), vm.endDate);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text(
                            vm.startDate ?? (isMl ? 'ആരംഭ തീയതി' : 'Start Date'),
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await AppDatePicker.pickDate(
                              context: context,
                              initialDate: vm.endDate != null ? (DateTime.tryParse(vm.endDate!) ?? DateTime.now()) : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (d != null) {
                              vm.setDateRange(vm.startDate, d.toString().substring(0, 10));
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text(
                            vm.endDate ?? (isMl ? 'അവസാന തീയതി' : 'End Date'),
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (period != null) ...[
            _buildReportCard(
              isMl ? 'ആകെ സ്വീകരിച്ചത് (Collections)' : 'Period Collections',
              period.periodCollections,
              AppColors.success,
              Icons.arrow_downward_rounded,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              isMl ? 'ആകെ നൽകിയ വായ്പകൾ (Disbursals)' : 'Period Disbursals',
              period.periodDisbursals,
              AppColors.error,
              Icons.arrow_upward_rounded,
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              isMl ? 'ഗ്രൂപ്പ് ചെലവുകൾ' : 'Period Group Expenses',
              period.totalGroupExpenses,
              Colors.deepOrange,
              Icons.receipt_long_rounded,
            ),
          ],
        ],
      ),
    );
  }

    
  Widget _buildCategoryLoansDepositsTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final cat = vm.categoryReport;
    if (cat == null) return const MemberListShimmerLoading();

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl ? 'വായ്പ & നിക്ഷേപ റിപ്പോർട്ടുകൾ' : 'Loans & Deposits Category Report',
            subtitle: isMl ? 'എല്ലാ സാമ്പത്തിക വായ്പകളുടെയും നിക്ഷേപങ്ങളുടെയും വിവരങ്ങൾ' : 'Detailed summary of active loans and member deposits',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 16),

          // Loans Overview Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountLoan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accountLoan.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'സാധാരണ വായ്പ' : 'Regular Loans',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${cat.totalOutstandingLoanBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.accountLoan),
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
                    border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'സ്പെഷ്യൽ വായ്പകൾ' : 'Special Loans',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${cat.totalSpecialLoanBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Deposits & Contributions Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accountDeposit.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accountDeposit.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'ആകെ നിക്ഷേപം' : 'Total Deposits',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${cat.totalDepositsCollected.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.accountDeposit),
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
                    border: Border.all(color: AppColors.accountContribution.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'വരിസംഖ്യ & പിഴ' : 'Contrib & Fines',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${(cat.totalContributionsCollected + cat.totalFinesCollected).toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.accountContribution),
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
            isMl ? 'വായ്പയുള്ള അംഗങ്ങൾ (${cat.loanMembers.length})' : 'Active Loan Members (${cat.loanMembers.length})',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          if (cat.loanMembers.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    isMl ? 'നിലവിൽ വായ്പകളൊന്നും കുടിശ്ശികയില്ല' : 'No active loans outstanding',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accountLoan.withValues(alpha: 0.12),
                      child: Text(
                        '#${item.memberNumber}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.accountLoan, fontSize: 11),
                      ),
                    ),
                    title: Text(item.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(item.categoryName, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: Text(
                      '₹${item.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.accountLoan),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Deposit Members Section
          Text(
            isMl ? 'നിക്ഷേപമുള്ള അംഗങ്ങൾ (${cat.depositMembers.length})' : 'Deposit Members (${cat.depositMembers.length})',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          if (cat.depositMembers.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    isMl ? 'നിക്ഷേപങ്ങളൊന്നും വിവരങ്ങളില്ല' : 'No deposits recorded',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accountDeposit.withValues(alpha: 0.12),
                      child: Text(
                        '#${item.memberNumber}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.accountDeposit, fontSize: 11),
                      ),
                    ),
                    title: Text(item.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(item.categoryName, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: Text(
                      '₹${item.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.accountDeposit),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialAidReportTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final cat = vm.categoryReport;
    if (cat == null) return const MemberListShimmerLoading();

    final aidList = cat.financialAidDisbursements;

    return RefreshIndicator(
      onRefresh: () => vm.fetchAllReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl ? 'സാമ്പത്തിക സഹായ റിപ്പോർട്ട്' : 'Financial Aid Disbursed Report',
            subtitle: isMl ? 'അംഗങ്ങൾക്ക് നൽകിയ സാമ്പത്തിക സഹായങ്ങളുടെ സമ്പൂർണ്ണ വിവരങ്ങൾ' : 'Complete record of financial aid grants given to members',
            icon: Icons.volunteer_activism_rounded,
          ),
          const SizedBox(height: 16),

          // Total Aid Disbursed KPI Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accountFinancialAid, AppColors.accountFinancialAid.withValues(alpha: 0.8)],
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
                const Icon(Icons.volunteer_activism_rounded, size: 36, color: Colors.white),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'ആകെ നൽകിയ സാമ്പത്തിക സഹായം' : 'Total Financial Aid Given',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${cat.totalFinancialAidDisbursed.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
            isMl ? 'സഹായ വിതരണ ഹിസ്റ്ററി (${aidList.length})' : 'Financial Aid Disbursements (${aidList.length})',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),

          if (aidList.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    isMl ? 'ഇതുവരെ സാമ്പത്തിക സഹായങ്ങൾ വിതരണം ചെയ്തിട്ടില്ല' : 'No financial aid disbursements recorded yet',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
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
                          backgroundColor: AppColors.accountFinancialAid.withValues(alpha: 0.12),
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
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  if (item.transactionDate.isNotEmpty)
                                    Text(
                                      item.transactionDate,
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  if (item.meetingNumber != '-') ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '| Meeting #${item.meetingNumber}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.notes != null && item.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.notes!,
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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

Widget _buildMemberBalancesTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final categories = [
      {'key': 'ALL', 'labelMl': 'എല്ലാം (All)', 'labelEn': 'All'},
      {'key': 'LOAN', 'labelMl': 'സാധാരണ വായ്പ', 'labelEn': 'Regular Loans'},
      {'key': 'SPECIAL_LOAN', 'labelMl': 'സ്പെഷ്യൽ വായ്പ', 'labelEn': 'Special Loans'},
      {'key': 'DEPOSIT', 'labelMl': 'നിക്ഷേപം', 'labelEn': 'Deposits'},
      {'key': 'CONTRIBUTION', 'labelMl': 'വരിസംഖ്യ', 'labelEn': 'Contributions'},
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
              hintText: isMl ? 'അംഗത്തിന്റെ പേര് അല്ലെങ്കിൽ നമ്പർ...' : 'Search member name or number...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl
                            ? '${categories.firstWhere((c) => c['key'] == _selectedCategoryFilter)['labelMl']} റിപ്പോർട്ട്'
                            : '${categories.firstWhere((c) => c['key'] == _selectedCategoryFilter)['labelEn']} Report',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                      ),
                      Text(
                        '${filteredMembers.length} ${isMl ? "അംഗങ്ങൾ" : "members"} | Total: ₹${categoryTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${categoryTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
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
                    child: Text('#${m.memberNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                  ),
                  title: Text(m.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('Loan: ₹${m.loanBalance.toStringAsFixed(2)} | Deposit: ₹${m.depositBalance.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow('സാധാരണ വായ്പ (Loan Balance)', m.loanBalance, AppColors.accountLoan),
                          ...m.specialLoanBalances.map((spl) {
                            String splTitle = spl.specialLoanTypeName;
                            if (splTitle == 'Special Loan') {
                              splTitle = isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan';
                            }
                            return Column(
                              children: [
                                const SizedBox(height: 6),
                                _buildDetailRow(splTitle, spl.currentBalance, Colors.deepOrange),
                              ],
                            );
                          }),
                          if (m.specialLoanBalances.isEmpty && m.specialLoanBalance > 0) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow(isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan', m.specialLoanBalance, Colors.deepOrange),
                          ],
                          const SizedBox(height: 6),
                          _buildDetailRow('നിക്ഷേപം (Deposit Balance)', m.depositBalance, AppColors.accountDeposit),
                          const SizedBox(height: 6),
                          _buildDetailRow('വരിസംഖ്യ (Contribution)', m.contributionBalance, AppColors.accountContribution),
                          const SizedBox(height: 6),
                          _buildDetailRow('പിഴ (Fines Balance)', m.fineBalance, AppColors.accountFine),
                          const SizedBox(height: 6),
                          _buildDetailRow('സാമ്പത്തിക സഹായം (Financial Aid)', m.financialAidBalance, AppColors.accountFinancialAid),
                          const SizedBox(height: 6),
                          _buildDetailRow('പലിശ (Interest Balance)', m.interestBalance, AppColors.accountInterest),
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

  Widget _buildMeetingReportsTab(BuildContext context, ReportsViewModel vm, bool isMl) {
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
              child: Text('#${m.meetingNumber}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text('Meeting #${m.meetingNumber} (${m.meetingDate})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Total Collected: ₹${m.totalCollected.toStringAsFixed(2)} | Surplus: ₹${m.surplusAmount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                if (m.totalGroupExpenses > 0)
                  Text('Expenses: ₹${m.totalGroupExpenses.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.deepOrange)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showMeetingDetailModal(context, m, isMl),
          ),
        );
      },
    );
  }

  void _showMeetingDetailModal(BuildContext context, MeetingReportModel m, bool isMl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting #${m.meetingNumber} (${m.meetingDate}) Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('സാധാരണ വയ്പ അടവ്', m.totalLoanRepayments, AppColors.success),
                  if (m.totalSpecialLoanRepayments > 0) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow('സ്പെഷ്യൽ വായ്പ അടവ്', m.totalSpecialLoanRepayments, AppColors.accountFinancialAid),
                  ],
                  const SizedBox(height: 6),
                  _buildDetailRow('നിക്ഷേപം (Deposits)', m.totalDepositsCollected, AppColors.info),
                  const SizedBox(height: 6),
                  _buildDetailRow('വരിസംഖ്യ (Monthly Contribution)', m.totalMonthlyContributions, AppColors.accountContribution),
                  const SizedBox(height: 6),
                  _buildDetailRow('പിഴ (Fines)', m.totalFinesCollected, AppColors.accountFine),
                  const SizedBox(height: 6),
                  _buildDetailRow('സാമ്പത്തിക സഹായം', m.totalFinancialAid, AppColors.error),
                  if (m.totalGroupExpenses > 0) ...[
                    const SizedBox(height: 6),
                    _buildDetailRow('ഗ്രൂപ്പ് ചെലവുകൾ', m.totalGroupExpenses, Colors.deepOrange),
                  ],
                  const SizedBox(height: 6),
                  _buildDetailRow('മിച്ച തുക (Surplus Reserve)', m.surplusAmount, Colors.teal),
                  const SizedBox(height: 14),
                  Text('Member Collections:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  for (var c in m.memberCollections)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('#${c.memberNumber} ${c.fullName}', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      trailing: Text('₹${c.totalMemberCollected.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner({required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
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

  Widget _buildReportCard(String title, double amount, Color color, IconData icon) {
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
            Text(title, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('₹${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
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
          Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
          Text('₹${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
