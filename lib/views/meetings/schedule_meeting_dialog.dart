import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/common/app_snackbar.dart';
import '../../core/common/app_date_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/meeting_viewmodel.dart';

class ScheduleMeetingDialog extends StatefulWidget {
  const ScheduleMeetingDialog({super.key});

  @override
  State<ScheduleMeetingDialog> createState() => _ScheduleMeetingDialogState();
}

class _ScheduleMeetingDialogState extends State<ScheduleMeetingDialog> {
  final TextEditingController notesCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await AppDatePicker.pickDate(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = selectedDate.year.toString().padLeft(4, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');
    final dateStr = '$year-$month-$day';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Schedule New Meeting', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Meeting Date',
                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  dateStr,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes / Description (Optional)',
                hintText: 'e.g. Monthly general body meeting',
                prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        ),
        Selector<MeetingViewModel, bool>(
          selector: (_, vm) => vm.actionState.isLoading,
          builder: (context, isLoading, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final vm = context.read<MeetingViewModel>();
                      final success = await vm.scheduleMeeting(dateStr, notes: notesCtrl.text.trim());
                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Meeting scheduled successfully!');
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(
                            context,
                            vm.actionState.message ?? 'Failed to schedule meeting',
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Schedule Now', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            );
          },
        )
      ],
    );
  }
}
