import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/common/app_snackbar.dart';
import '../../viewmodel/member_viewmodel.dart';

class AddMemberDialog extends StatelessWidget {
  final TextEditingController numCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  AddMemberDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Register New Member', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'Member Number (e.g. M003)')),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        Selector<MemberViewModel, bool>(
          selector: (_, vm) => vm.actionState.isLoading,
          builder: (context, isLoading, _) {
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (numCtrl.text.isEmpty || nameCtrl.text.isEmpty || userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                        AppSnackbar.showError(context, 'Please fill required fields');
                        return;
                      }

                      final success = await context.read<MemberViewModel>().createMember(
                        memberNumber: numCtrl.text.trim(),
                        fullName: nameCtrl.text.trim(),
                        username: userCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );

                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Member created successfully!');
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(context, context.read<MemberViewModel>().actionState.message ?? 'Failed to create member');
                        }
                      }
                    },
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
            );
          },
        ),
      ],
    );
  }
}
