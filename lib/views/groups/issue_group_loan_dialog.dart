import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_snackbar.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/group_viewmodel.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../viewmodel/member_viewmodel.dart';
import '../../core/model/member_group_model.dart';
import '../../core/model/special_loan_type_model.dart';

class IssueGroupLoanDialog extends StatefulWidget {
  final MemberGroupModel? initialGroup;

  const IssueGroupLoanDialog({super.key, this.initialGroup});

  @override
  State<IssueGroupLoanDialog> createState() => _IssueGroupLoanDialogState();
}

class _IssueGroupLoanDialogState extends State<IssueGroupLoanDialog> {
  MemberGroupModel? _selectedGroup;
  SpecialLoanTypeModel? _selectedSpecialType;
  bool _isSpecialLoan = false;

  final _totalAmountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  Set<int> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.initialGroup;
    if (_selectedGroup != null) {
      _selectedMemberIds = _selectedGroup!.members.map((m) => m.id).toSet();
    }
  }

  @override
  void dispose() {
    _totalAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onGroupChanged(MemberGroupModel? group) {
    setState(() {
      _selectedGroup = group;
      if (group != null && group.members.isNotEmpty) {
        _selectedMemberIds = group.members.map((m) => m.id).toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    final groupVm = context.watch<GroupViewModel>();
    final memberVm = context.watch<MemberViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();

    final double totalAmt = double.tryParse(_totalAmountCtrl.text) ?? 0.0;
    final int count = _selectedMemberIds.length;
    final double perMemberAmt = count > 0 ? totalAmt / count : 0.0;

    final activeSpecialTypes = settingsVm.specialLoanTypes.where((t) => t.isActive).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMl ? 'ഗ്രൂപ്പ് വായ്പ' : 'Group Loan',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MemberGroupModel>(
                initialValue: _selectedGroup,
                decoration: InputDecoration(
                  labelText: isMl ? 'ഗ്രൂപ്പ് തിരഞ്ഞെടുക്കുക' : 'Select Group',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.group_work_rounded),
                ),
                items: groupVm.groups.map((g) {
                  return DropdownMenuItem<MemberGroupModel>(
                    value: g,
                    child: Text(g.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: _onGroupChanged,
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(isMl ? 'സാധാരണ വായ്പ' : 'Standard Loan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                      icon: const Icon(Icons.monetization_on_rounded, size: 16),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                      icon: const Icon(Icons.assignment_rounded, size: 16),
                    ),
                  ],
                  selected: {_isSpecialLoan},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isSpecialLoan = newSelection.first;
                    });
                  },
                ),
              ),

              if (_isSpecialLoan) ...[
                const SizedBox(height: 6),
                DropdownButtonFormField<SpecialLoanTypeModel>(
                  initialValue: _selectedSpecialType,
                  decoration: InputDecoration(
                    labelText: isMl ? 'സ്പെഷ്യൽ വായ്പ തരം' : 'Special Loan Type',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.assignment_rounded),
                  ),
                  items: activeSpecialTypes.map((t) {
                    return DropdownMenuItem<SpecialLoanTypeModel>(
                      value: t,
                      child: Text(t.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSpecialType = val),
                ),
                const SizedBox(height: 12),
              ],

              TextField(
                controller: _totalAmountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: isMl ? 'ആകെ വായ്പ തുക (Total Loan Amount ₹)' : 'Total Loan Amount (₹)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        count > 0 && totalAmt > 0
                            ? (isMl
                                ? '₹${totalAmt.toStringAsFixed(2)} ÷ $count അംഗങ്ങൾ = ഒരാൾക്ക് ₹${perMemberAmt.toStringAsFixed(2)}വീതം'
                                : '₹${totalAmt.toStringAsFixed(2)} ÷ $count members = ₹${perMemberAmt.toStringAsFixed(2)} per member')
                            : (isMl ? 'തുകയും അംഗങ്ങളെയും തിരഞ്ഞെടുക്കുക.' : 'Select members & enter total amount.'),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                isMl ? 'അംഗങ്ങൾ ($count പേർ):' : 'Select Members ($count selected):',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: memberVm.members.length,
                  itemBuilder: (context, index) {
                    final member = memberVm.members[index];
                    final isChecked = _selectedMemberIds.contains(member.id);
                    return CheckboxListTile(
                      dense: true,
                      title: Text(
                        '${member.memberNumber} - ${member.fullName}',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: isChecked ? FontWeight.bold : FontWeight.normal),
                      ),
                      value: isChecked,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedMemberIds.add(member.id);
                          } else {
                            _selectedMemberIds.remove(member.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: isMl ? 'വിവരണം / നോട്ടുകൾ' : 'Notes / Description',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: count == 0 || totalAmt <= 0
              ? null
              : () async {
                  final formattedDate = _selectedDate.toString().split(' ')[0];
                  final ok = await groupVm.issueGroupLoan(
                    groupId: _selectedGroup?.id,
                    memberIds: _selectedMemberIds.toList(),
                    specialLoanTypeId: _isSpecialLoan ? _selectedSpecialType?.id : null,
                    totalAmount: totalAmt,
                    notes: _notesCtrl.text.trim(),
                    transactionDate: formattedDate,
                  );

                  if (context.mounted) {
                    if (ok) {
                      AppSnackbar.showSuccess(context, 'Group Loan Issued Cleanly!');
                      Navigator.pop(context);
                    } else {
                      AppSnackbar.showError(context, groupVm.actionState.message ?? 'Failed to issue group loan');
                    }
                  }
                },
          child: Text(isMl ? 'അനുവദിക്കുക (Issue)' : 'Issue Loan'),
        ),
      ],
    );
  }
}
