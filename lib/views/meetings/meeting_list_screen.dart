import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/viewmodel/meeting_viewmodel.dart';
import 'package:ashgledger/core/model/meeting_model.dart';
import 'meeting_detail_screen.dart';
import 'schedule_meeting_dialog.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';

class MeetingListScreen extends StatelessWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingViewModel>().fetchMeetings();
    });

    return Scaffold(
      body: Consumer<MeetingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const MeetingsListShimmerLoading();
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load meetings',
              onRetry: () => vm.fetchMeetings(),
            );
          }

          final meetings = vm.meetings;
          final activeUncompleted = vm.currentUncompletedMeeting;

          if (meetings.isEmpty) {
            return Center(child: Text(l10n.translate('no_meetings'), style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary)));
          }

          final sortedMeetings = List<MeetingModel>.from(meetings)
            ..sort((a, b) {
              final dateCmp = b.meetingDate.compareTo(a.meetingDate);
              if (dateCmp != 0) return dateCmp;
              return b.meetingNumber.compareTo(a.meetingNumber);
            });

          return RefreshIndicator(
            onRefresh: () => context.read<MeetingViewModel>().fetchMeetings(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeUncompleted != null) _buildActiveMeetingNotice(activeUncompleted, l10n),
                ...sortedMeetings.map((m) => _buildMeetingCard(context, m, l10n)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Selector<MeetingViewModel, bool>(
        selector: (_, vm) => vm.hasUncompletedMeeting,
        builder: (context, hasUncompleted, _) {
          return FloatingActionButton.extended(
            heroTag: 'meetings_list_fab',
            onPressed: () {
              final vm = context.read<MeetingViewModel>();
              final uncompleted = vm.currentUncompletedMeeting;
              if (uncompleted != null) {
                AppSnackbar.showInfo(
                  context,
                  l10n.translate('active_meeting_notice'),
                );
              } else {
                showDialog(context: context, builder: (_) => const ScheduleMeetingDialog());
              }
            },
            backgroundColor: hasUncompleted ? Colors.grey.shade600 : AppColors.primary,
            icon: Icon(hasUncompleted ? Icons.lock_rounded : Icons.add_task_rounded, color: Colors.white),
            label: Text(
              hasUncompleted ? l10n.translate('meeting_active') : l10n.translate('schedule_meeting'),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveMeetingNotice(MeetingModel active, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.translate('active_meeting_notice'),
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingModel meeting, AppLocalizations l10n) {
    final bool isActive = meeting.status == 'OPEN' || meeting.status == 'SCHEDULED';
    Color statusColor = AppColors.accentGold;
    if (meeting.status == 'OPEN') statusColor = AppColors.success;
    if (meeting.status == 'COMPLETED') statusColor = AppColors.textSecondary;
    final statusText = l10n.translate('status_${meeting.status.toLowerCase()}');

    final double progress = meeting.totalMembers > 0 ? (meeting.processedMembers / meeting.totalMembers) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.06 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeetingDetailScreen(meetingId: meeting.id)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive ? Icons.event_available_rounded : Icons.event_note_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.translate('meetings')} #${meeting.meetingNumber}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${l10n.translate('date')}: ${meeting.meetingDate}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (meeting.isFirstMeetingOfMonth) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.translate('first_meeting_of_month'),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${meeting.processedMembers}/${meeting.totalMembers} ${l10n.translate('members')}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          l10n.translate('workspace'),
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.bgLight,
                    color: AppColors.primary,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
