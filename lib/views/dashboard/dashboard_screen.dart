import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/model/dashboard_summary_model.dart';
import '../../core/model/financial_transaction_model.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/common/common_error_widget.dart';
import '../../viewmodel/dashboard_viewmodel.dart';
import '../../viewmodel/group_viewmodel.dart';
import '../../viewmodel/member_viewmodel.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../meetings/meeting_detail_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../reports/reports_screen.dart';
import '../reports/meeting_register_book_screen.dart';
import '../expenses/group_expenses_screen.dart';
import '../groups/issue_group_loan_dialog.dart';
import '../groups/groups_screen.dart';
import '../../core/di/service_locator.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showGroupLoanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ഗ്രൂപ്പ് വായ്പ ഓപ്ഷനുകൾ (Group Loan)',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.add_rounded, color: AppColors.primary),
              ),
              title: Text('പുതിയ ഗ്രൂപ്പ് വായ്പ നൽകുക', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              subtitle: const Text('തുക നൽകി അംഗങ്ങളെ സമമായി വിഭജിക്കുക'),
              onTap: () {
                Navigator.pop(ctx);
                _openIssueGroupLoanDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade50,
                child: const Icon(Icons.group_work_rounded, color: Colors.purple),
              ),
              title: Text('ഗ്രൂപ്പുകൾ കാണുക (View Groups)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              subtitle: const Text('നിലവിലുള്ള ഗ്രൂപ്പുകളും ബാക്കി തുകയും കാണുക'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openIssueGroupLoanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<GroupViewModel>()..fetchGroups()),
          ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()..fetchMembers()),
          ChangeNotifierProvider(create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes()),
        ],
        child: const IssueGroupLoanDialog(),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<DashboardViewModel>().fetchDashboardSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchDashboardSummary();
    });

    return Scaffold(
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.summary == null) {
            if (vm.loadState.hasError) {
              return CommonErrorWidget(
                message: vm.loadState.message ?? 'Failed to load dashboard',
                onRetry: () => vm.fetchDashboardSummary(),
              );
            }
            return const DashboardShimmerLoading();
          }

          final summary = vm.summary!;
          final l10n = AppLocalizations.of(context);
          final isMl = l10n.locale.languageCode == 'ml';

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardViewModel>().fetchDashboardSummary(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNextMeetingCard(context, summary),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showGroupLoanOptions(context),
                        icon: const Icon(Icons.group_work_rounded, size: 15),
                        label: Text(
                          isMl ? 'ഗ്രൂപ്പ് വായ്പ' : 'Group Loan',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MeetingRegisterBookScreen()),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 15),
                        label: Text(
                          isMl ? 'രജിസ്റ്റർ ബുക്ക്' : 'Register Book',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GroupExpensesScreen()),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_rounded, size: 15),
                        label: Text(
                          isMl ? 'ചെലവുകൾ' : 'Expenses',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          );
                        },
                        icon: const Icon(Icons.analytics_rounded, size: 15),
                        label: Text(
                          isMl ? 'റിപ്പോർട്ടുകൾ' : 'Reports',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.translate('financial_categories_overview'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                _buildKpiGrid(context, summary, l10n),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.translate('recent_transactions'),
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(l10n.translate('view_all'), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Selector<DashboardViewModel, List<FinancialTransactionModel>>(
                  selector: (_, vm) => vm.recentTransactions,
                  builder: (context, recentList, _) {
                    if (recentList.isEmpty) {
                      return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.translate('no_recent_transactions'))));
                    }
                    return Column(
                      children: recentList.map((tx) => _buildTransactionCard(context, tx)).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextMeetingCard(BuildContext context, DashboardSummaryModel summary) {
    if (summary.nextMeeting == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No upcoming meeting scheduled.')),
        ),
      );
    }

    final meeting = summary.nextMeeting!;
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isMl ? "മീറ്റിംഗ്" : "Meetings"} #${meeting.meetingNumber}',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${meeting.meetingDate}  •  Period: ${meeting.interestPeriod}',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    meeting.status,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${meeting.processedMembers}/${meeting.totalMembers} Members',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeetingDetailScreen(meetingId: meeting.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text('Workspace', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardSummaryModel summary, AppLocalizations l10n) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildKpiCard(context, l10n.translate('surplus_fund'), '₹${summary.surplusAmount.toStringAsFixed(2)}', Icons.account_balance_wallet_rounded, Colors.teal),
        _buildKpiCard(context, l10n.translate('total_loans'), '₹${summary.totalOutstandingLoans.toStringAsFixed(2)}', Icons.account_balance_rounded, AppColors.error),
        _buildKpiCard(context, l10n.translate('total_deposits'), '₹${summary.totalDeposits.toStringAsFixed(2)}', Icons.savings_rounded, AppColors.success),
        _buildKpiCard(context, l10n.translate('total_fines'), '₹${summary.totalOutstandingFines.toStringAsFixed(2)}', Icons.gavel_rounded, Colors.orange),
        _buildKpiCard(context, l10n.translate('financial_aid'), '₹${summary.totalOutstandingFinancialAid.toStringAsFixed(2)}', Icons.volunteer_activism_rounded, Colors.purple),
        _buildKpiCard(context, l10n.translate('monthly_contributions'), '₹${summary.totalMonthlyContributions.toStringAsFixed(2)}', Icons.card_membership_rounded, Colors.blue),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String amount, IconData icon, Color color, {VoidCallback? onEdit, VoidCallback? onExpense}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEdit != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.teal),
                      onPressed: onEdit,
                      tooltip: 'Add to Surplus',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (onExpense != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: Colors.redAccent),
                        onPressed: onExpense,
                        tooltip: 'Record Group Expense',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, FinancialTransactionModel tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              tx.transactionType == 'REPAYMENT' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (tx.description != null && tx.description!.isNotEmpty) ? tx.description! : '${tx.accountType} ${tx.transactionType}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.memberName}  •  ${tx.createdAt}',
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '₹${tx.amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: tx.transactionType == 'REPAYMENT' ? AppColors.success : AppColors.primaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
