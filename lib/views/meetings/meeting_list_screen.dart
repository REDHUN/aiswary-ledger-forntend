import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/state/load_state.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/viewmodel/meeting_viewmodel.dart';
import 'package:ashgledger/core/model/meeting_model.dart';
import 'meeting_detail_screen.dart';
import 'schedule_meeting_dialog.dart';
import '../../core/localization/app_localizations.dart';

class MeetingListScreen extends StatelessWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingViewModel>().fetchMeetings();
    });

    return Scaffold(
      body: Selector<MeetingViewModel, LoadState>(
        selector: (_, vm) => vm.loadState,
        builder: (context, state, _) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.hasError) {
            return CommonErrorWidget(
              message: state.message ?? 'Failed to load meetings',
              onRetry: () => context.read<MeetingViewModel>().fetchMeetings(),
            );
          }

          return Selector<MeetingViewModel, List<MeetingModel>>(
            selector: (_, vm) => vm.meetings,
            builder: (context, meetings, _) {
              final activeUncompleted = context.read<MeetingViewModel>().currentUncompletedMeeting;

              if (meetings.isEmpty) {
                return Center(child: Text(l10n.translate('no_meetings')));
              }

              // Display newest meeting first (descending by meetingDate / meetingNumber)
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
                    if (activeUncompleted != null) _buildActiveMeetingNotice(activeUncompleted),
                    ...sortedMeetings.map((m) => _buildMeetingCard(context, m, l10n)),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: Selector<MeetingViewModel, bool>(
        selector: (_, vm) => vm.hasUncompletedMeeting,
        builder: (context, hasUncompleted, _) {
          return FloatingActionButton.extended(
            onPressed: () {
              final vm = context.read<MeetingViewModel>();
              final uncompleted = vm.currentUncompletedMeeting;
              if (uncompleted != null) {
                AppSnackbar.showInfo(
                  context,
                  'Meeting #${uncompleted.meetingNumber} is currently ${uncompleted.status}. Please complete it before scheduling another.',
                );
              } else {
                showDialog(context: context, builder: (_) => ScheduleMeetingDialog());
              }
            },
            backgroundColor: hasUncompleted ? Colors.grey : AppColors.primary,
            icon: Icon(hasUncompleted ? Icons.lock_outline_rounded : Icons.add_task_rounded, color: Colors.white),
            label: Text(
              hasUncompleted ? 'Meeting Active' : 'Schedule Meeting',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveMeetingNotice(MeetingModel active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Active Meeting #${active.meetingNumber} (${active.meetingDate}) is ${active.status}. Complete it to unlock new meeting scheduling.',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, MeetingModel meeting, AppLocalizations l10n) {
    final bool isActive = meeting.status == 'OPEN' || meeting.status == 'SCHEDULED';
    Color statusColor = AppColors.info;
    if (meeting.status == 'OPEN') statusColor = AppColors.success;
    if (meeting.status == 'COMPLETED') statusColor = AppColors.textSecondary;
    final statusText = l10n.translate('status_${meeting.status.toLowerCase()}');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: AppColors.primary.withValues(alpha: 0.6), width: 1.8)
            : BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.translate('meetings')} #${meeting.meetingNumber} - ${meeting.meetingDate}',
                      style: GoogleFonts.outfit(
                        fontSize: isActive ? 17 : 15,
                        fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                        color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                        letterSpacing: isActive ? 0.3 : 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              if (meeting.isFirstMeetingOfMonth)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'First Meeting of Month',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${meeting.processedMembers}/${meeting.totalMembers} ${l10n.translate('members')}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
                      color: isActive ? AppColors.textDark : AppColors.textMuted,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
