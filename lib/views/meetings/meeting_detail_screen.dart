import '../../viewmodel/dashboard_viewmodel.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/repository/reports_repository.dart';
import 'package:ashgledger/core/model/meeting_report_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/common/app_snackbar.dart';
import '../../viewmodel/meeting_viewmodel.dart';
import '../../core/model/meeting_model.dart';
import '../../core/model/meeting_member_model.dart';
import 'member_processing_screen.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/common/app_formatters.dart';
import '../../core/localization/app_localizations.dart';

class MeetingDetailScreen extends StatelessWidget {
  final int meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingViewModel>().loadMeetingDetails(meetingId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('meeting_workspace')),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: l10n.locale.languageCode == 'ml'
                ? 'യോഗം റിപ്പോർട്ട്'
                : 'Meeting Report',
            onPressed: () => _showMeetingReportModal(context, meetingId, l10n),
          ),
        ],
      ),
      body: Consumer<MeetingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.activeMeeting == null) {
            if (vm.loadState.hasError) {
              return CommonErrorWidget(
                message:
                    vm.loadState.message ?? 'Failed to load meeting details',
                onRetry: () => vm.loadMeetingDetails(meetingId),
              );
            }
            return const MeetingDetailShimmerLoading();
          }

          final meeting = vm.activeMeeting!;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<MeetingViewModel>().loadMeetingDetails(meetingId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMeetingHeader(context, meeting, l10n),
                const SizedBox(height: 20),
                Text(
                  l10n.translate('assigned_members'),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Selector<MeetingViewModel, List<MeetingMemberModel>>(
                  selector: (_, vm) => vm.meetingMembers,
                  builder: (context, members, _) {
                    if (members.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Text(
                          meeting.status == 'SCHEDULED'
                              ? l10n.translate('click_open_meeting')
                              : l10n.translate('no_members'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: members
                          .map(
                            (m) => _buildMemberTile(context, meeting, m, l10n),
                          )
                          .toList(),
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

  Widget _buildMeetingHeader(
    BuildContext context,
    MeetingModel meeting,
    AppLocalizations l10n,
  ) {
    final statusText = l10n.translate('status_${meeting.status.toLowerCase()}');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.translate('meetings')} #${meeting.meetingNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${AppFormatters.formatDate(meeting.meetingDate)}',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (meeting.status == 'SCHEDULED')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final vm = context.read<MeetingViewModel>();
                      final success = await vm.openMeeting(meeting.id);
                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Meeting Opened!');
                        } else {
                          AppSnackbar.showError(
                            context,
                            vm.actionState.message ?? 'Failed to open meeting',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l10n.translate('open_meeting')),
                  ),
                ),
              if (meeting.status == 'OPEN')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final vm = context.read<MeetingViewModel>();
                      final success = await vm.completeMeeting(meeting.id);
                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(
                            context,
                            'Meeting Completed!',
                          );
                        } else {
                          AppSnackbar.showError(
                            context,
                            vm.actionState.message ??
                                'Failed to complete meeting',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(l10n.translate('complete_meeting')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    MeetingModel meeting,
    MeetingMemberModel mm,
    AppLocalizations l10n,
  ) {
    final bool isCompleted = mm.processingStatus == 'COMPLETED';
    final statusText = isCompleted
        ? l10n.translate('status_completed')
        : l10n.translate('pending_members');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.warning.withValues(alpha: 0.15),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isCompleted ? AppColors.success : AppColors.warning,
          ),
        ),
        title: Text(
          mm.fullName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${l10n.translate('members')} #${mm.memberNumber}',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
        onTap: meeting.status == 'OPEN'
            ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberProcessingScreen(
                      meetingId: meeting.id,
                      memberId: mm.memberId,
                      meetingDate: meeting.meetingDate,
                    ),
                  ),
                );
                if (context.mounted && (result == true || result == null)) {
                  context.read<MeetingViewModel>().loadMeetingDetails(
                    meeting.id,
                  );
                  context.read<DashboardViewModel>().fetchDashboardSummary();
                }
              }
            : null,
      ),
    );
  }

  void _showMeetingReportModal(
    BuildContext context,
    int meetingId,
    AppLocalizations l10n,
  ) {
    final isMl = l10n.locale.languageCode == 'ml';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return FutureBuilder<MeetingReportModel>(
            future: sl<ReportsRepository>().getMeetingReport(meetingId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Text(
                    snapshot.error?.toString() ?? 'Failed to load report',
                    style: GoogleFonts.outfit(color: Colors.red),
                  ),
                );
              }

              final report = snapshot.data!;

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMl
                            ? 'യോഗം #${report.meetingNumber} സാമ്പത്തിക റിപ്പോർട്ട്'
                            : 'Meeting #${report.meetingNumber} Report',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMl
                                  ? 'ആകെ കളക്ഷൻ (Total Collected)'
                                  : 'Total Meeting Collection',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${report.totalCollected.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      _buildReportMiniTile(
                        isMl ? 'വായ്പ തിരിച്ചടവ്' : 'Loan Repayments',
                        report.totalLoanRepayments,
                        AppColors.accountLoan,
                        Icons.assignment_return_rounded,
                      ),
                      _buildReportMiniTile(
                        isMl ? 'നിക്ഷേപ പിരിവ്' : 'Savings Deposits',
                        report.totalDepositsCollected,
                        AppColors.accountDeposit,
                        Icons.savings_rounded,
                      ),
                      _buildReportMiniTile(
                        isMl ? 'പിഴ തുക' : 'Fines Collected',
                        report.totalFinesCollected,
                        AppColors.accountFine,
                        Icons.gavel_rounded,
                      ),
                      _buildReportMiniTile(
                        isMl ? 'വരിസംഖ്യ' : 'Contributions',
                        report.totalMonthlyContributions,
                        AppColors.accountContribution,
                        Icons.calendar_today_rounded,
                      ),
                      _buildReportMiniTile(
                        isMl ? 'നൽകിയ വായ്പകൾ' : 'Loans Issued',
                        report.totalLoansIssued,
                        Colors.orange,
                        Icons.add_card_rounded,
                      ),
                      _buildReportMiniTile(
                        isMl ? 'ധനസഹായം' : 'Financial Aid',
                        report.totalFinancialAid,
                        AppColors.accountFinancialAid,
                        Icons.volunteer_activism_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isMl
                        ? 'അംഗങ്ങളുടെ കളക്ഷൻ വിവരങ്ങൾ'
                        : 'Member Collection Breakdown',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (report.memberCollections.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          isMl
                              ? 'കളക്ഷൻ രേഖപ്പെടുത്തിയിട്ടില്ല'
                              : 'No collections recorded yet',
                        ),
                      ),
                    )
                  else
                    ...report.memberCollections.map(
                      (m) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                        elevation: 0,
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              m.memberNumber,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            m.fullName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            isMl
                                ? 'വായ്പ: ₹${m.loanRepayment.toStringAsFixed(0)} | നിക്ഷേപം: ₹${m.depositAddition.toStringAsFixed(0)} | പിഴ: ₹${m.finePayment.toStringAsFixed(0)} | വരിസംഖ്യ: ₹${m.contributionAddition.toStringAsFixed(0)}'
                                : 'Loan: ₹${m.loanRepayment.toStringAsFixed(0)} | Deposit: ₹${m.depositAddition.toStringAsFixed(0)} | Fine: ₹${m.finePayment.toStringAsFixed(0)} | Contrib: ₹${m.contributionAddition.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: Text(
                            '₹${m.totalMemberCollected.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReportMiniTile(
    String title,
    double amt,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
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
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            '₹${amt.toStringAsFixed(2)}',
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
}
