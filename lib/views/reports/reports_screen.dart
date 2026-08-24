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
import 'package:ashgledger/core/model/member_balance_report_model.dart';
import 'package:ashgledger/core/model/meeting_report_model.dart';
// ignore: unused_import
import 'package:ashgledger/core/model/monthly_ledger_report_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(sl<ReportsRepository>()),
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
  String _selectedYearMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  _selectedYearMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportsViewModel>().fetchAllReports();
        context.read<ReportsViewModel>().fetchMonthlyLedgerReport(_selectedYearMonth);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memberSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context, ReportsViewModel vm) async {
    final DateTimeRange? picked = await AppDatePicker.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: vm.startDate != null && vm.endDate != null
          ? DateTimeRange(
              start: DateTime.parse(vm.startDate!),
              end: DateTime.parse(vm.endDate!),
            )
          : null,
    );

    if (picked != null) {
      final startStr = "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}";
      final endStr = "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}";
      vm.setDateRange(startStr, endStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'ധനകാര്യ റിപ്പോർട്ടുകൾ' : 'Financial Reports',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ReportsViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => vm.fetchAllReports(),
            ),
          ),
        ],
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
            Tab(text: isMl ? 'അവലോകനം' : 'Overview'),
            Tab(text: isMl ? 'കാലയളവ്' : 'Period'),
            Tab(text: isMl ? 'അംഗ ബാക്കി' : 'Member Balances'),
            Tab(text: isMl ? 'യോഗ റിപ്പോർട്ട്' : 'Meeting Report'),
            Tab(text: isMl ? 'പ്രതിമാസ ലെഡ്ജർ' : 'Monthly Ledger'),
          ],
        ),
      ),
      body: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const MemberListShimmerLoading();
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
              _buildMemberBalancesTab(context, vm, isMl),
              _buildMeetingReportsTab(context, vm, isMl),
              _buildMonthlyLedgerTab(context, vm, isMl),
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
            title: isMl ? 'ആകെ സാമ്പത്തിക നിലവാരം' : 'Total Financial Position',
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
            childAspectRatio: 1.35,
            children: [
              _buildReportCard(
                isMl ? 'നിക്ഷേപം (Savings)' : 'Deposits Balance',
                summary.totalDeposits,
                AppColors.accountDeposit,
                Icons.savings_rounded,
              ),
              _buildReportCard(
                isMl ? 'വായ്പ നിലവാരം' : 'Outstanding Loans',
                summary.totalOutstandingLoans,
                AppColors.accountLoan,
                Icons.add_card_rounded,
              ),
              _buildReportCard(
                isMl ? 'പ്രതിമാസ വരിസംഖ്യ' : 'Monthly Contributions',
                summary.totalMonthlyContributions,
                AppColors.accountContribution,
                Icons.calendar_today_rounded,
              ),
              _buildReportCard(
                isMl ? 'പിഴ തുക' : 'Outstanding Fines',
                summary.totalOutstandingFines,
                AppColors.accountFine,
                Icons.gavel_rounded,
              ),
              _buildReportCard(
                isMl ? 'ധനസഹായം' : 'Financial Aid',
                summary.totalOutstandingFinancialAid,
                AppColors.accountFinancialAid,
                Icons.volunteer_activism_rounded,
              ),
              _buildReportCard(
                isMl ? 'പലിശ വരവ്' : 'Interest Applied',
                summary.totalOutstandingInterest,
                AppColors.accountInterest,
                Icons.calculate_rounded,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isMl ? 'കാലയളവിലെ റിപ്പോർട്ട്' : 'Period Financial Statement',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _selectDateRange(context, vm),
                icon: const Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  vm.startDate != null && vm.endDate != null
                      ? "${vm.startDate} ~ ${vm.endDate}"
                      : (isMl ? 'തീയതി തിരഞ്ഞെടുക്കുക' : 'Select Date Range'),
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (period != null) ...[
            _buildSummaryRowCard(
              isMl ? 'ആകെ ശേഖരണങ്ങൾ (Collections)' : 'Total Collections (Receipts)',
              period.periodCollections,
              AppColors.success,
              Icons.arrow_downward_rounded,
            ),
            const SizedBox(height: 12),
            _buildSummaryRowCard(
              isMl ? 'ആകെ നൽകിയ വായ്പകൾ (Disbursals)' : 'Total Disbursals (Loans)',
              period.periodDisbursals,
              Colors.orange,
              Icons.arrow_upward_rounded,
            ),
            const SizedBox(height: 12),
            _buildSummaryRowCard(
              isMl ? 'ഇടപാടുകളുടെ എണ്ണം' : 'Total Transactions Count',
              period.totalTransactionsCount.toDouble(),
              AppColors.primary,
              Icons.receipt_long_rounded,
              isCurrency: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberBalancesTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final list = vm.filteredMemberBalances;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: TextField(
            controller: _memberSearchCtrl,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: isMl ? 'അംഗത്തിൻ്റെ പേര്, നമ്പർ തിരയുക...' : 'Search member balances...',
              hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _memberSearchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _memberSearchCtrl.clear();
                        vm.setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.bgLight,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => vm.setSearchQuery(val),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderLight),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildMemberBalanceCard(item, isMl);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingReportsTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final meetings = vm.meetingReports;
    final selected = vm.selectedMeetingReport;

    if (meetings.isEmpty) {
      return Center(
        child: Text(isMl ? 'യോഗങ്ങളൊന്നും കണ്ടെത്തിയില്ല' : 'No meetings found'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MeetingReportModel>(
              isExpanded: true,
              value: selected,
              items: meetings.map((m) {
                return DropdownMenuItem<MeetingReportModel>(
                  value: m,
                  child: Text(
                    isMl
                        ? 'യോഗം #${m.meetingNumber} (${m.meetingDate}) - ₹${m.totalCollected.toStringAsFixed(0)}'
                        : 'Meeting #${m.meetingNumber} (${m.meetingDate}) - ₹${m.totalCollected.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) vm.selectMeetingReport(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (selected != null) ...[
          _buildHeaderBanner(
            title: isMl ? 'യോഗം #${selected.meetingNumber} പിരിവ്' : 'Meeting #${selected.meetingNumber} Collection',
            subtitle: isMl ? 'ആകെ കളക്ഷൻ: ₹${selected.totalCollected.toStringAsFixed(2)}' : 'Total Collection: ₹${selected.totalCollected.toStringAsFixed(2)}',
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _buildReportCard(
                isMl ? 'വായ്പ തിരിച്ചടവ്' : 'Loan Repayments',
                selected.totalLoanRepayments,
                AppColors.accountLoan,
                Icons.assignment_return_rounded,
              ),
              _buildReportCard(
                isMl ? 'നിക്ഷേപ പിരിവ്' : 'Savings Deposits',
                selected.totalDepositsCollected,
                AppColors.accountDeposit,
                Icons.savings_rounded,
              ),
              _buildReportCard(
                isMl ? 'പിഴ തുക' : 'Fines Collected',
                selected.totalFinesCollected,
                AppColors.accountFine,
                Icons.gavel_rounded,
              ),
              _buildReportCard(
                isMl ? 'വരിസംഖ്യ പിരിവ്' : 'Contributions',
                selected.totalMonthlyContributions,
                AppColors.accountContribution,
                Icons.calendar_today_rounded,
              ),
              _buildReportCard(
                isMl ? 'നൽകിയ വായ്പകൾ' : 'Loans Issued',
                selected.totalLoansIssued,
                Colors.orange,
                Icons.add_card_rounded,
              ),
              _buildReportCard(
                isMl ? 'ധനസഹായം' : 'Financial Aid',
                selected.totalFinancialAid,
                AppColors.accountFinancialAid,
                Icons.volunteer_activism_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isMl ? 'അംഗങ്ങളുടെ കളക്ഷൻ വിവരങ്ങൾ' : 'Member Collection Breakdown',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          if (selected.memberCollections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text(isMl ? 'കളക്ഷൻ വിവരങ്ങളില്ല' : 'No member collection entries')),
            )
          else
            ...selected.memberCollections.map((m) => _buildMemberMeetingCollectionTile(m, isMl)),
        ],
      ],
    );
  }

  Widget _buildMemberMeetingCollectionTile(MemberMeetingCollectionModel item, bool isMl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(item.memberNumber, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        title: Text(item.fullName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        subtitle: Text(
          isMl
              ? 'വായ്പ: ₹${item.loanRepayment.toStringAsFixed(0)} | നിക്ഷേപം: ₹${item.depositAddition.toStringAsFixed(0)} | പിഴ: ₹${item.finePayment.toStringAsFixed(0)} | വരിസംഖ്യ: ₹${item.contributionAddition.toStringAsFixed(0)}'
              : 'Loan: ₹${item.loanRepayment.toStringAsFixed(0)} | Deposit: ₹${item.depositAddition.toStringAsFixed(0)} | Fine: ₹${item.finePayment.toStringAsFixed(0)} | Contrib: ₹${item.contributionAddition.toStringAsFixed(0)}',
          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Text(
          '₹${item.totalMemberCollected.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner({required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, double val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            '₹${val.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowCard(String title, double val, Color color, IconData icon, {bool isCurrency = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
          Text(
            isCurrency ? '₹${val.toStringAsFixed(2)}' : val.toInt().toString(),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBalanceCard(MemberBalanceReportModel item, bool isMl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(item.memberNumber, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.fullName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.borderLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubBalanceItem(isMl ? 'നിക്ഷേപം' : 'Deposit', item.depositBalance, AppColors.accountDeposit),
                _buildSubBalanceItem(isMl ? 'വായ്പ' : 'Loan', item.loanBalance, AppColors.accountLoan),
                _buildSubBalanceItem(isMl ? 'വരിസംഖ്യ' : 'Contrib', item.contributionBalance, AppColors.accountContribution),
                _buildSubBalanceItem(isMl ? 'പിഴ' : 'Fine', item.fineBalance, AppColors.accountFine),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBalanceItem(String label, double amt, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text('₹${amt.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMonthlyLedgerTab(BuildContext context, ReportsViewModel vm, bool isMl) {
    final report = vm.monthlyLedgerReport;

    final monthsList = report?.availableMonths ?? [];
    if (report != null && report.availableMonths.isNotEmpty) {
      if (!monthsList.contains(_selectedYearMonth)) {
        _selectedYearMonth = report.yearMonth.isNotEmpty ? report.yearMonth : monthsList.first;
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.fetchMonthlyLedgerReport(_selectedYearMonth);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderBanner(
            title: isMl ? 'പ്രതിമാസ ലെഡ്ജർ ഷീറ്റ്' : 'Monthly Sangham Ledger Sheet',
            subtitle: isMl ? 'എല്ലാ അംഗങ്ങളുടെയും യോഗാടിസ്ഥാനത്തിലുള്ള അടവ് ലെഡ്ജർ' : 'Member-wise collection matrix by meeting date',
            icon: Icons.grid_on_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                isMl ? 'മാസം തെരഞ്ഞെടുക്കുക:' : 'Select Month:',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: monthsList.contains(_selectedYearMonth) ? _selectedYearMonth : monthsList.first,
                    items: monthsList.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          m,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedYearMonth = val;
                        });
                        vm.fetchMonthlyLedgerReport(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (report == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMl ? 'ഈ മാസത്തെ ആകെ പിരിവ്:' : 'Month Grand Total:',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                  ),
                  Text(
                    '₹${report.grandTotalCollected.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.primaryDark),
                    headingTextStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    dataTextStyle: GoogleFonts.outfit(fontSize: 13),
                    columnSpacing: 16,
                    columns: [
                      const DataColumn(label: Text('#')),
                      DataColumn(label: Text(isMl ? 'അംഗത്തിന്റെ പേര്' : 'Member Name')),
                      ...report.meetingDates.map((d) => DataColumn(
                            label: Text(
                              d.length >= 10 ? '${d.substring(8, 10)}/${d.substring(5, 7)}' : d,
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )),
                      DataColumn(label: Text(isMl ? 'ആകെ അടവ്' : 'Total Monthly')),
                      DataColumn(label: Text(isMl ? 'മാസ വരി' : 'Contribution')),
                      DataColumn(label: Text(isMl ? 'നിക്ഷേപം' : 'Deposit')),
                      DataColumn(label: Text(isMl ? 'വായ്പ അടവ്' : 'Loan Repay')),
                      DataColumn(label: Text(isMl ? 'ഫൈൻ' : 'Fine')),
                      DataColumn(label: Text(isMl ? 'വായ്പ ബാക്കി' : 'Loan Bal')),
                      DataColumn(label: Text(isMl ? 'നിക്ഷേപ ബാക്കി' : 'Deposit Bal')),
                    ],
                    rows: [
                      ...report.memberRows.map((m) {
                        return DataRow(
                          cells: [
                            DataCell(Text(m.memberNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                            DataCell(Text(m.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
                            ...report.meetingDates.map((d) {
                              final amt = m.meetingCollections[d] ?? 0.0;
                              return DataCell(
                                Text(
                                  amt > 0 ? '₹${amt.toStringAsFixed(0)}' : '-',
                                  style: GoogleFonts.outfit(
                                    fontWeight: amt > 0 ? FontWeight.bold : FontWeight.normal,
                                    color: amt > 0 ? AppColors.textDark : AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }),
                            DataCell(Text('₹${m.totalMonthlyCollected.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary))),
                            DataCell(Text('₹${m.monthlyContributionSum.toStringAsFixed(0)}')),
                            DataCell(Text('₹${m.depositSum.toStringAsFixed(0)}')),
                            DataCell(Text('₹${m.loanRepaymentSum.toStringAsFixed(0)}')),
                            DataCell(Text('₹${m.fineSum.toStringAsFixed(0)}')),
                            DataCell(Text('₹${m.currentLoanBalance.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.accountLoan, fontWeight: FontWeight.bold))),
                            DataCell(Text('₹${m.currentDepositBalance.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.accountDeposit, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }),
                      // Summary Row
                      DataRow(
                        color: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                        cells: [
                          const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(isMl ? 'ആകെ പിരിവ്' : 'Total Collection', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ...report.meetingDates.map((d) {
                            final tot = report.meetingTotals[d] ?? 0.0;
                            return DataCell(
                              Text(
                                '₹${tot.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            );
                          }),
                          DataCell(Text('₹${report.grandTotalCollected.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryDark))),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                          const DataCell(Text('-')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}