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
import '../../core/model/member_group_model.dart';
import 'issue_group_loan_dialog.dart';
import 'group_loan_details_dialog.dart';

class GroupsScreen extends StatelessWidget {
  final int initialTabIndex;

  const GroupsScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<GroupViewModel>()..fetchGroups()..fetchLoanHistory()),
        ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()..fetchMembers()),
        ChangeNotifierProvider(create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes()),
      ],
      child: _GroupsBody(initialTabIndex: initialTabIndex),
    );
  }
}

class _GroupsBody extends StatefulWidget {
  final int initialTabIndex;

  const _GroupsBody({this.initialTabIndex = 0});

  @override
  State<_GroupsBody> createState() => _GroupsBodyState();
}

class _GroupsBodyState extends State<_GroupsBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'ഗ്രൂപ്പ് മാനേജ്മെന്റ്' : 'Group Management',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () => _openIssueGroupLoanDialog(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(isMl ? 'ഗ്രൂപ്പ് വായ്പ' : 'Group Loan'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: isMl ? 'ഗ്രൂപ്പുകൾ (Groups)' : 'Groups'),
            Tab(text: isMl ? 'വായ്പ ചരിത്രം (History)' : 'Group Loans History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _GroupsListTab(),
          const _GroupLoansHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddEditGroupDialog(context, isMl),
        child: const Icon(Icons.group_add_rounded, color: Colors.white),
      ),
    );
  }

  void _openIssueGroupLoanDialog(BuildContext context, [MemberGroupModel? group]) {
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
        child: IssueGroupLoanDialog(initialGroup: group),
      ),
    );
  }

  void _showAddEditGroupDialog(BuildContext context, bool isMl, [MemberGroupModel? existingGroup]) {
    final nameCtrl = TextEditingController(text: existingGroup?.name ?? '');
    final descCtrl = TextEditingController(text: existingGroup?.description ?? '');
    Set<int> selectedMemberIds = existingGroup != null
        ? existingGroup.members.map((m) => m.id).toSet()
        : {};

    final memberVm = context.read<MemberViewModel>();
    final groupVm = context.read<GroupViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            existingGroup == null
                ? (isMl ? 'പുതിയ ഗ്രൂപ്പ് ഉണ്ടാക്കുക' : 'Create New Group')
                : (isMl ? 'ഗ്രൂപ്പ് വിവരങ്ങൾ മാറ്റുക' : 'Edit Group'),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isMl ? 'ഗ്രൂപ്പ് പേര് (Group Name)' : 'Group Name',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: isMl ? 'വിവരണം (Description)' : 'Description',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isMl ? 'ഗ്രൂപ്പിലെ അംഗങ്ങൾ (${selectedMemberIds.length}):' : 'Group Members (${selectedMemberIds.length}):',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: memberVm.members.length,
                      itemBuilder: (_, index) {
                        final m = memberVm.members[index];
                        final isChecked = selectedMemberIds.contains(m.id);
                        return CheckboxListTile(
                          dense: true,
                          title: Text('${m.memberNumber} - ${m.fullName}', style: GoogleFonts.outfit(fontSize: 13)),
                          value: isChecked,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedMemberIds.add(m.id);
                              } else {
                                selectedMemberIds.remove(m.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                bool ok;
                if (existingGroup == null) {
                  ok = await groupVm.createGroup(nameCtrl.text.trim(), descCtrl.text.trim(), selectedMemberIds.toList());
                } else {
                  ok = await groupVm.updateGroup(existingGroup.id, nameCtrl.text.trim(), descCtrl.text.trim(), true, selectedMemberIds.toList());
                }
                if (ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isMl ? 'സേവ് ചെയ്യുക' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsListTab extends StatelessWidget {
  const _GroupsListTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroupViewModel>();
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    if (vm.loadState.isLoading) return const MemberListShimmerLoading();
    if (vm.loadState.hasError) {
      return CommonErrorWidget(
        message: vm.loadState.message ?? 'Failed to load groups',
        onRetry: () => vm.fetchGroups(),
      );
    }

    if (vm.groups.isEmpty) {
      return Center(
        child: Text(
          isMl ? 'ഗ്രൂപ്പുകളൊന്നും ഉണ്ടാക്കിയിട്ടില്ല.' : 'No groups created yet.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.groups.length,
      itemBuilder: (context, index) {
        final g = vm.groups[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.group_work_rounded, color: AppColors.primary),
            ),
            title: Text(g.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(
              '${g.memberCount} ${isMl ? 'അംഗങ്ങൾ' : 'members'}${g.description != null && g.description!.isNotEmpty ? " • ${g.description}" : ""}',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
            children: [
              const Divider(height: 1),
              if (g.members.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(isMl ? 'അംഗങ്ങളില്ല' : 'No members in group', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: g.members.length,
                  itemBuilder: (_, mIdx) {
                    final m = g.members[mIdx];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                      title: Text('${m.memberNumber} - ${m.fullName}', style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      subtitle: m.phone != null ? Text(m.phone!, style: GoogleFonts.outfit(fontSize: 11)) : null,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupLoansHistoryTab extends StatelessWidget {
  const _GroupLoansHistoryTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroupViewModel>();
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    if (vm.loanHistory.isEmpty) {
      return Center(
        child: Text(
          isMl ? 'ഗ്രൂപ്പ് വായ്പ ചരിത്രമില്ല.' : 'No group loans history found.',
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.loanHistory.length,
      itemBuilder: (context, index) {
        final item = vm.loanHistory[index];
        final isSpecial = item.accountType == 'SPECIAL_LOAN';
        final typeName = isSpecial ? (item.specialLoanTypeName ?? 'Special Loan') : (isMl ? 'സാധാരണ വായ്പ' : 'Standard Loan');

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: ListTile(
            onTap: () => showDialog(context: context, builder: (_) => GroupLoanDetailsDialog(loan: item)),
            contentPadding: const EdgeInsets.all(14),
            leading: CircleAvatar(
              backgroundColor: isSpecial ? Colors.deepOrange.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.12),
              child: Icon(isSpecial ? Icons.assignment_turned_in_rounded : Icons.monetization_on_rounded, color: isSpecial ? Colors.deepOrange : AppColors.primary),
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
                  '₹${item.totalAmount.toStringAsFixed(2)} total ÷ ${item.memberCount} members = ₹${item.perMemberAmount.toStringAsFixed(2)} each',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(item.notes!, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                Text(item.transactionDate, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}
