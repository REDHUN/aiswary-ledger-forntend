import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/common/app_snackbar.dart';
import '../../viewmodel/meeting_viewmodel.dart';

class ScheduleMeetingDialog extends StatelessWidget {
  final TextEditingController dateCtrl = TextEditingController(text: '2026-09-13');
  final TextEditingController notesCtrl = TextEditingController();

  ScheduleMeetingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Schedule New Meeting', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Meeting Date (YYYY-MM-DD)')),
          const SizedBox(height: 12),
          TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes / Description')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        Selector<MeetingViewModel, bool>(
          selector: (_, vm) => vm.actionState.isLoading,
          builder: (context, isLoading, _) {
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (dateCtrl.text.isEmpty) return;
                      final vm = context.read<MeetingViewModel>();
                      final success = await vm.scheduleMeeting(dateCtrl.text.trim(), notes: notesCtrl.text.trim());
                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Meeting scheduled!');
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(
                            context,
                            vm.actionState.message ?? 'Failed to schedule meeting',
                          );
                        }
                      }
                    },

              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Schedule'),
            );
          },
        )
      ],
    );
  }
}
