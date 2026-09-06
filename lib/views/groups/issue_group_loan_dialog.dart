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
  final int? preselectedMeetingId;

  const IssueGroupLoanDialog({super.key, this.preselectedMeetingId});

  @override
  State<IssueGroupLoanDialog> createState() => _IssueGroupLoanDialogState();
}

class _IssueGroupLoanDialogState extends State<IssueGroupLoanDialog> {
  MemberGroupModel? _selectedGroup;
  SpecialLoanTypeModel? _selectedSpecialType;
  bool _isSpecialLoan = true; // Special Loan selected by default
  bool _hasInitializedMembers = false;
  final TextEditingController _totalAmountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final Set<int> _selectedMemberIds = {};
  final DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _totalAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onGroupChanged(MemberGroupModel? group) {
    final memberVm = context.read<MemberViewModel>();
    setState(() {
      _selectedGroup = group;
      _selectedMemberIds.clear();
      if (group == null) {
        _selectedMemberIds.addAll(memberVm.members.map((m) => m.id));
      } else {
        final groupMemberIds = group.members.map((m) => m.id).toSet();
        _selectedMemberIds.addAll(groupMemberIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';
    final groupVm = context.watch<GroupViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final memberVm = context.watch<MemberViewModel>();

    // Auto-select initial members as soon as memberVm finishes fetching over HTTP
    if (!_hasInitializedMembers && memberVm.members.isNotEmpty) {
      _hasInitializedMembers = true;
      if (_selectedGroup == null) {
        _selectedMemberIds.addAll(memberVm.members.map((m) => m.id));
      }
    }

    final activeSpecialTypes = settingsVm.specialLoanTypes.where((t) => t.isActive).toList();
    if (_isSpecialLoan && _selectedSpecialType == null && activeSpecialTypes.isNotEmpty) {
      _selectedSpecialType = activeSpecialTypes.first;
    }

    final double totalAmt = double.tryParse(_totalAmountCtrl.text) ?? 0.0;
    final int count = _selectedMemberIds.length;
    final double perMemberAmt = count > 0 ? (totalAmt / count) : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMl ? 'ഗ്രൂപ്പ് വായ്പ നൽകുക' : 'Issue Group Loan',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          isMl ? 'തുക നൽകി അംഗങ്ങൾക്ക് വിഭജിക്കുക' : 'Distribute loan among members',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Dialog Scrollable Content Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Group Selector Dropdown
                    DropdownButtonFormField<MemberGroupModel?>(
                      initialValue: _selectedGroup,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: isMl ? 'ഗ്രൂപ്പ്' : 'Group',
                        hintText: isMl ? 'ഗ്രൂപ്പ് തിരഞ്ഞെടുക്കുക' : 'Select Group',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.group_work_rounded, color: AppColors.primary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem<MemberGroupModel?>(
                          value: null,
                          child: Text(
                            isMl ? 'എല്ലാ അംഗങ്ങളും' : 'All Active Members',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...groupVm.groups.map((g) {
                          return DropdownMenuItem<MemberGroupModel?>(
                            value: g,
                            child: Text(
                              g.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: _onGroupChanged,
                    ),
                    const SizedBox(height: 14),

                    // 2. Loan Type Segmented Control (Special Loan First & Default Selected)
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment<bool>(
                            value: true,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isMl ? 'സ്പെഷ്യൽ വായ്പ' : 'Special Loan',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            icon: const Icon(Icons.stars_rounded, size: 16),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isMl ? 'സാധാരണ വായ്പ' : 'Standard Loan',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            icon: const Icon(Icons.monetization_on_rounded, size: 16),
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

                    // 3. Special Loan Type Selector (If Special Loan)
                    if (_isSpecialLoan) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<SpecialLoanTypeModel>(
                        initialValue: _selectedSpecialType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: isMl ? 'വായ്പ തരം' : 'Loan Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.stars_rounded, color: Colors.purple),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: activeSpecialTypes.map((t) {
                          return DropdownMenuItem<SpecialLoanTypeModel>(
                            value: t,
                            child: Text(
                              t.name,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedSpecialType = val),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // 4. Total Amount Field
                    TextField(
                      controller: _totalAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: isMl ? 'ആകെ വായ്പ തുക (₹)' : 'Total Loan Amount (₹)',
                        hintText: '0.00',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 5. Calculation Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: count > 0 && totalAmt > 0
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: count > 0 && totalAmt > 0
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calculate_rounded,
                            color: count > 0 && totalAmt > 0 ? AppColors.primary : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: count > 0 && totalAmt > 0
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isMl
                                                  ? 'ആകെ: ₹${totalAmt % 1 == 0 ? totalAmt.toInt() : totalAmt.toStringAsFixed(2)}'
                                                  : 'Total: ₹${totalAmt % 1 == 0 ? totalAmt.toInt() : totalAmt.toStringAsFixed(2)}',
                                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              isMl ? '$count അംഗങ്ങൾ' : '$count Members',
                                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₹${perMemberAmt.toInt()} ${isMl ? "ഒരാൾക്ക്" : "each"}',
                                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    isMl ? 'തുക നൽകി അംഗങ്ങളെ തിരഞ്ഞെടുക്കുക' : 'Enter amount and select members',
                                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 6. Member Selection List Header & Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isMl ? 'അംഗങ്ങൾ ($count പേർ):' : 'Members ($count):',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            setState(() {
                              if (_selectedMemberIds.length == memberVm.members.length) {
                                _selectedMemberIds.clear();
                              } else {
                                _selectedMemberIds.addAll(memberVm.members.map((m) => m.id));
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text(
                              _selectedMemberIds.length == memberVm.members.length
                                  ? (isMl ? 'എല്ലാം ഒഴിവാക്കുക' : 'Deselect All')
                                  : (isMl ? 'എല്ലാം തിരഞ്ഞെടുക്കുക' : 'Select All'),
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Member Selection List
                    Material(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: memberVm.members.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 12, endIndent: 12),
                          itemBuilder: (context, index) {
                            final member = memberVm.members[index];
                            final isChecked = _selectedMemberIds.contains(member.id);
                            return CheckboxListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              secondary: CircleAvatar(
                                radius: 14,
                                backgroundColor: isChecked ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade300,
                                child: Text(
                                  member.memberNumber,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isChecked ? AppColors.primary : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              title: Text(
                                member.fullName,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                  color: isChecked ? AppColors.textDark : AppColors.textSecondary,
                                ),
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
                    ),
                    const SizedBox(height: 14),

                    // 7. Notes Field
                    TextField(
                      controller: _notesCtrl,
                      decoration: InputDecoration(
                        labelText: isMl ? 'കുറിപ്പുകൾ / വിവരണം' : 'Notes / Description',
                        hintText: isMl ? 'ഓപ്ഷണൽ കുറിപ്പുകൾ ചേർക്കാം' : 'Optional notes',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.note_alt_rounded, color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Dialog Footer Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isMl ? 'റദ്ദാക്കുക' : 'Cancel',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
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
                                meetingId: widget.preselectedMeetingId,
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
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isMl ? 'അനുവദിക്കുക (Issue)' : 'Issue Loan',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
