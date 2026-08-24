import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/core/model/member_model.dart';

class EditMemberDialog extends StatefulWidget {
  final MemberModel member;

  const EditMemberDialog({super.key, required this.member});

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.member.fullName);
    phoneCtrl = TextEditingController(text: widget.member.phone ?? '');
    addressCtrl = TextEditingController(text: widget.member.address ?? '');
    isActive = widget.member.isActive;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Edit Member Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member #: ${widget.member.memberNumber}',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.home_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Account Status', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                Switch(
                  value: isActive,
                  activeThumbColor: AppColors.success,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        ),
        Selector<MemberViewModel, bool>(
          selector: (_, vm) => vm.actionState.isLoading,
          builder: (context, isLoading, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        AppSnackbar.showError(context, 'Full name cannot be empty');
                        return;
                      }

                      final success = await context.read<MemberViewModel>().updateMember(
                        widget.member.id,
                        fullName: name,
                        phone: phoneCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        isActive: isActive,
                      );

                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Profile updated successfully!');
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(
                            context,
                            context.read<MemberViewModel>().actionState.message ?? 'Update failed',
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Changes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }
}
