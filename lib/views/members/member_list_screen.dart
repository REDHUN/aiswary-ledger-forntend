import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../viewmodel/member_viewmodel.dart';
import 'member_detail_screen.dart';



import 'add_member_dialog.dart';
import '../../core/common/app_shimmer.dart';


import '../../core/localization/app_localizations.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  Widget _buildShimmerSkeleton() {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberViewModel>().fetchMembers();
    });

    return Scaffold(
      body: Consumer<MemberViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) {
            return _buildShimmerSkeleton();
          }

          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load members',
              onRetry: () => vm.fetchMembers(),
            );
          }

          final members = vm.members;
          if (members.isEmpty) {
            return Center(
              child: Text(l10n.translate('no_members'), style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchMembers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        member.memberNumber,
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      member.fullName,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    subtitle: Text(
                      member.phone ?? l10n.translate('no_phone'),
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemberDetailScreen(memberId: member.id)),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'member_list_fab',
        onPressed: () {
          showDialog(context: context, builder: (_) => AddMemberDialog());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(l10n.translate('new_member'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

}
