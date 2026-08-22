import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../viewmodel/dashboard_viewmodel.dart';
import '../../core/model/dashboard_summary_model.dart';
import '../meetings/meeting_detail_screen.dart';
import '../../core/common/app_shimmer.dart';


import '../../core/localization/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildShimmerSkeleton() {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ShimmerBox(width: double.infinity, height: 140, borderRadius: 20),
          const SizedBox(height: 20),
          const ShimmerBox(width: 180, height: 20, borderRadius: 4),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: List.generate(
              6,
              (_) => const ShimmerBox(width: double.infinity, height: 100, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final regexp = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final formattedInt = parts[0].replaceAllMapped(regexp, (Match m) => '${m[1]},');
    return '₹$formattedInt.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchSummary();
    });

    return Scaffold(
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.summary == null) {
            if (vm.loadState.hasError) {
              return CommonErrorWidget(
                message: vm.loadState.message ?? 'Failed to load dashboard',
                onRetry: () => vm.fetchSummary(),
              );
            }
            return _buildShimmerSkeleton();
          }

          final summary = vm.summary!;
          return RefreshIndicator(
            onRefresh: () => vm.fetchSummary(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNextMeetingCard(context, summary, l10n),
                const SizedBox(height: 20),
                Text(
                  l10n.translate('financial_totals'),
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    _buildMetricCard(l10n.translate('outstanding_loans'), _formatCurrency(summary.totalOutstandingLoans), AppColors.accountLoan, Icons.account_balance_wallet_rounded),
                    _buildMetricCard(l10n.translate('total_deposits'), _formatCurrency(summary.totalDeposits), AppColors.accountDeposit, Icons.savings_rounded),
                    _buildMetricCard(l10n.translate('monthly_contributions'), _formatCurrency(summary.totalMonthlyContributions), AppColors.accountContribution, Icons.star_rounded),
                    _buildMetricCard(l10n.translate('meeting_collections'), _formatCurrency(summary.currentMeetingCollections), AppColors.primary, Icons.payments_rounded),
                    _buildMetricCard(l10n.translate('outstanding_fines'), _formatCurrency(summary.totalOutstandingFines), AppColors.accountFine, Icons.gavel_rounded),
                    _buildMetricCard(l10n.translate('financial_aid'), _formatCurrency(summary.totalOutstandingFinancialAid), AppColors.accountFinancialAid, Icons.volunteer_activism_rounded),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextMeetingCard(BuildContext context, DashboardSummaryModel summary, AppLocalizations l10n) {
    final meeting = summary.nextMeeting;
    if (meeting == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.headerGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(l10n.translate('no_active_meeting'), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      );
    }

    Color statusColor = AppColors.accentGold;
    if (meeting.status == 'OPEN') statusColor = AppColors.success;
    final statusText = l10n.translate('status_${meeting.status.toLowerCase()}');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.translate('meetings')} #${meeting.meetingNumber}',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(statusText, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Date: ${meeting.meetingDate}  •  ${l10n.translate('interest_period')}: ${meeting.interestPeriod}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meeting.processedMembers}/${meeting.totalMembers} ${l10n.translate('members')}',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: meeting.totalMembers > 0 ? (meeting.processedMembers / meeting.totalMembers) : 0,
                        backgroundColor: Colors.white24,
                        color: AppColors.accentGold,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(l10n.translate('workspace'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MeetingDetailScreen(meetingId: meeting.id)),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
