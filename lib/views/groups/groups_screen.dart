import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/group_viewmodel.dart';
import '../../viewmodel/member_viewmodel.dart';
import '../../viewmodel/settings_viewmodel.dart';
import 'issue_group_loan_dialog.dart';
import 'group_loan_details_dialog.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<GroupViewModel>()..fetchGroups()..fetchLoanHistory()),
        ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()..fetchMembers()),
        ChangeNotifierProvider(create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes()),
      ],
      child: const _GroupLoansBody(),
    );
  }
}

class _GroupLoansBody extends StatelessWidget {
  const _GroupLoansBody();

  void _openIssueGroupLoanDialog(BuildContext context) {
    final groupVm = context.read<GroupViewModel>();
    final memberVm = context.read<MemberViewModel>();
    final settingsVm = context.read<SettingsViewModel>();

    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: groupVm),
          ChangeNotifierProvider.value(value: memberVm),
          ChangeNotifierProvider.value(value: settingsVm),
        ],
        child: const IssueGroupLoanDialog(),
      ),
    ).then((_) {
      if (context.mounted) {
        groupVm.fetchLoanHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'ഗ്രൂപ്പ് വായ്പകൾ (Group Loans)' : 'Group Loans',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),

      ),
      body: Consumer<GroupViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading && vm.loanHistory.isEmpty) {
            return const GroupLoansShimmerLoading();
          }

          if (vm.loadState.hasError && vm.loanHistory.isEmpty) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load group loans history',
              onRetry: () => vm.fetchLoanHistory(),
            );
          }

          if (vm.loanHistory.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_work_rounded, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isMl ? 'ഗ്രൂപ്പ് വായ്പ വിവരങ്ങൾ ലഭ്യമല്ല' : 'No Group Loans Found',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMl
                          ? 'പുതിയ ഗ്രൂപ്പ് വായ്പ നൽകാൻ മുകളിലെ ബട്ടൺ അമർത്തുക.'
                          : 'Tap the button above to issue a new group loan.',
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openIssueGroupLoanDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        isMl ? 'പുതിയ ഗ്രൂപ്പ് വായ്പ നൽകുക' : 'Issue New Group Loan',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => vm.fetchLoanHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.loanHistory.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = vm.loanHistory[index];
                final isSpecial = item.accountType == 'SPECIAL_LOAN';
                final typeName = isSpecial
                    ? (item.specialLoanTypeName ?? 'Special Loan')
                    : (isMl ? 'സാധാരണ വായ്പ' : 'Standard Loan');

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => GroupLoanDetailsDialog(loan: item),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: isSpecial
                          ? Colors.purple.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.12),
                      child: Icon(
                        isSpecial ? Icons.stars_rounded : Icons.monetization_on_rounded,
                        color: isSpecial ? Colors.purple : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      '${item.groupName ?? "Group Loan"} - $typeName',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '₹${item.totalAmount.toStringAsFixed(2)} (${item.memberCount} ${isMl ? "അംഗങ്ങൾ" : "members"}) → ₹${item.perMemberAmount.toStringAsFixed(2)} ${isMl ? "ഓരോരുത്തർക്കും" : "each"}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Text(
                            item.notes!,
                            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          'തീയതി: ${item.transactionDate}',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openIssueGroupLoanDialog(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          isMl ? 'പുതിയ വായ്പ' : 'Issue Loan',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
