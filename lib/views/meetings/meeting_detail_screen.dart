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


import '../../core/localization/app_localizations.dart';

class MeetingDetailScreen extends StatelessWidget {
  final int meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  Widget _buildShimmerSkeleton() {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ShimmerBox(width: double.infinity, height: 140, borderRadius: 20),
          const SizedBox(height: 20),
          const ShimmerBox(width: 180, height: 20, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(5, (_) => const ShimmerListTile()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingViewModel>().loadMeetingDetails(meetingId);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('meeting_workspace'))),
      body: Consumer<MeetingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.activeMeeting == null) {
            if (vm.loadState.hasError) {
              return CommonErrorWidget(
                message: vm.loadState.message ?? 'Failed to load meeting details',
                onRetry: () => vm.loadMeetingDetails(meetingId),
              );
            }
            return _buildShimmerSkeleton();
          }

          final meeting = vm.activeMeeting!;

          return RefreshIndicator(
            onRefresh: () => context.read<MeetingViewModel>().loadMeetingDetails(meetingId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMeetingHeader(context, meeting, l10n),
                const SizedBox(height: 20),
                Text(l10n.translate('assigned_members'), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          style: GoogleFonts.outfit(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return Column(
                      children: members.map((m) => _buildMemberTile(context, meeting, m, l10n)).toList(),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingHeader(BuildContext context, MeetingModel meeting, AppLocalizations l10n) {
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
              Text('${l10n.translate('meetings')} #${meeting.meetingNumber}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text(statusText, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Date: ${meeting.meetingDate}', style: GoogleFonts.outfit(color: Colors.white70)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: Colors.black),
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
                          AppSnackbar.showSuccess(context, 'Meeting Completed!');
                        } else {
                          AppSnackbar.showError(
                            context,
                            vm.actionState.message ?? 'Failed to complete meeting',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(l10n.translate('complete_meeting')),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, MeetingModel meeting, MeetingMemberModel mm, AppLocalizations l10n) {
    final bool isCompleted = mm.processingStatus == 'COMPLETED';
    final statusText = isCompleted ? l10n.translate('status_completed') : l10n.translate('pending_members');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
          child: Icon(isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded, color: isCompleted ? AppColors.success : AppColors.warning),
        ),
        title: Text(mm.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text('${l10n.translate('members')} #${mm.memberNumber}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.success : AppColors.warning),
          ),
        ),
        onTap: meeting.status == 'OPEN'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberProcessingScreen(meetingId: meeting.id, memberId: mm.memberId),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

