import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/api_client.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/member_portal_viewmodel.dart';
import '../../core/model/member_model.dart';
// ignore: unused_import
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

class _MemberPortalBodyState extends State<_MemberPortalBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportMonth = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            onPressed: () => context.read<MemberPortalViewModel>().fetchMyData(),
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
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: isMl ? 'എന്റെ ലെഡ്ജർ' : 'My Ledger'),
            Tab(text: isMl ? 'എന്റെ റിപ്പോർട്ടുകൾ' : 'My Reports'),
          ],
        ),
      ),
      body: Consumer<MemberPortalViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const MemberListShimmerLoading();
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildLedgerTab(BuildContext context, MemberPortalViewModel vm, MemberModel member, bool isMl) {
    return RefreshIndicator(
      onRefresh: () => vm.fetchMyData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMemberHeader(member, isMl),
          const SizedBox(height: 20),
          Text(
            isMl ? 'എന്റെ അക്കൗണ്ട് ബാലൻസുകൾ' : 'My Account Balances',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          _buildAccountsGrid(member, isMl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isMl ? 'എന്റെ ഇടപാടുകൾ' : 'My Transactions',
                  style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
                          value: vm,
                          child: const MemberAllTransactionsScreen(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isMl ? 'എല്ലാം കാണുക' : 'View All',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionsList(vm, isMl),
        ],
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context, MemberPortalViewModel vm, MemberModel member, bool isMl) {
    final report = vm.myReport;
    final monthsList = report?.availableMonths ?? [];

    if (monthsList.isNotEmpty && !_selectedReportMonth.isNotEmpty) {
      _selectedReportMonth = report?.yearMonth ?? monthsList.first;
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchMyData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMl ? 'മാസം തെരഞ്ഞെടുക്കുക:' : 'Select Month:',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (monthsList.isNotEmpty)
                  DropdownButton<String>(
                    value: monthsList.contains(_selectedReportMonth) ? _selectedReportMonth : monthsList.first,
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
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                      ),
                      Text(
                        '₹${report.totalPaidInPeriod.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isMl ? 'യോഗങ്ങളിലെ അടവ് രസീതുകൾ' : 'Meeting Payment Entries',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            if (report.meetingPayments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  isMl ? 'ഈ മാസത്തിൽ അടവുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.' : 'No payment entries recorded for this month.',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary),
                ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Meeting #${item.meetingNumber} (${item.meetingDate})',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                                ),
                              ),
                              Text(
                                '₹${item.totalPaid.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          if (item.loanRepayment > 0) _buildReceiptRow(isMl ? 'വായ്പ അടവ്' : 'Loan Repay', item.loanRepayment, AppColors.accountLoan),
                          if (item.depositAddition > 0) _buildReceiptRow(isMl ? 'നിക്ഷേപം' : 'Deposit', item.depositAddition, AppColors.accountDeposit),
                          if (item.contributionAddition > 0) _buildReceiptRow(isMl ? 'മാസ വരി' : 'Contribution', item.contributionAddition, AppColors.accountContribution),
                          if (item.finePayment > 0) _buildReceiptRow(isMl ? 'ഫൈൻ' : 'Fine', item.finePayment, AppColors.accountFine),
                          if (item.financialAidPayment > 0) _buildReceiptRow(isMl ? 'ധനസഹായം' : 'Financial Aid', item.financialAidPayment, AppColors.accountFinancialAid),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
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
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
          Text('₹${amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  member.memberNumber,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            member.fullName,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          if (member.phone != null)
            Row(
              children: [
                const Icon(Icons.phone_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(member.phone!, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
              ],
            ),
          if (member.address != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    member.address!,
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
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

  Widget _buildAccountsGrid(MemberModel member, bool isMl) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildBalanceCard(
          isMl ? 'വായ്പ ബാക്കി' : 'Loan Balance',
          member.loanBalance,
          AppColors.accountLoan,
          Icons.add_card_rounded,
        ),
        _buildBalanceCard(
          isMl ? 'നിക്ഷേപം (Savings)' : 'Deposit Balance',
          member.depositBalance,
          AppColors.accountDeposit,
          Icons.savings_rounded,
        ),
        _buildBalanceCard(
          isMl ? 'മാസ വരി' : 'Contributions',
          member.monthlyContributionBalance,
          AppColors.accountContribution,
          Icons.calendar_today_rounded,
        ),
        _buildBalanceCard(
          isMl ? 'ഫൈൻ ബാക്കി' : 'Fine Due',
          member.fineBalance,
          AppColors.accountFine,
          Icons.gavel_rounded,
        ),
        _buildBalanceCard(
          isMl ? 'ധനസഹായം' : 'Financial Aid',
          member.financialAidBalance,
          AppColors.accountFinancialAid,
          Icons.volunteer_activism_rounded,
        ),
        _buildBalanceCard(
          isMl ? 'പലിശ ബാക്കി' : 'Interest Total',
          member.interestBalance,
          AppColors.accountInterest,
          Icons.calculate_rounded,
        ),
      ],
    );
  }

  Widget _buildBalanceCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
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
              Icon(icon, color: color, size: 22),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
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
          isMl ? 'ഇടപാടുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.' : 'No transactions recorded yet.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.myTransactions.length > 5 ? 5 : vm.myTransactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = vm.myTransactions[index];
        final isReversed = tx.isReversed;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: isReversed ? Colors.red.shade200 : AppColors.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tx.accountType,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '₹${tx.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isReversed ? Colors.grey : AppColors.primaryDark,
                    decoration: isReversed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Date: ${tx.createdAt.contains('T') ? tx.createdAt.split('T')[0] : tx.createdAt} | Type: ${tx.transactionType}',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (tx.description != null && tx.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Notes: ${tx.description}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textDark)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
