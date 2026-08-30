import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/group_profit_viewmodel.dart';
import '../../viewmodel/reports_viewmodel.dart';
import '../../viewmodel/dashboard_viewmodel.dart';

class AddGroupProfitDialog extends StatefulWidget {
  final int? preselectedMeetingId;
  const AddGroupProfitDialog({super.key, this.preselectedMeetingId});

  @override
  State<AddGroupProfitDialog> createState() => _AddGroupProfitDialogState();
}

class _AddGroupProfitDialogState extends State<AddGroupProfitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final notes = _notesController.text.trim();

    final vm = context.read<GroupProfitViewModel>();
    final success = await vm.recordGroupProfit(
      title: title,
      amount: amount,
      profitDate: dateStr,
      description: notes.isNotEmpty ? notes : null,
      meetingId: widget.preselectedMeetingId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.read<ReportsViewModel>().fetchAllReports();
        context.read<DashboardViewModel>().fetchDashboardSummary();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ലാഭം വിജയകരമായി രേഖപ്പെടുത്തി!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final err = vm.actionState.message ?? 'Failed to record profit';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.trending_up_rounded, color: Color(0xFF047857), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Record Group Profit',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profit Title Field
                Text(
                  isMl ? 'ലാഭ വിവരം (ഉറവിടം)' : 'Profit Source / Title',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: isMl ? 'ഉദാ: ചിട്ടി ലാഭം, ബാങ്ക് പലിശ, ലോട്ടറി' : 'e.g. Chitty Profit, Bank Interest',
                    prefixIcon: const Icon(Icons.label_outline_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? (isMl ? 'ലാഭ വിവരണം നൽകുക' : 'Enter profit title') : null,
                ),
                const SizedBox(height: 16),

                // Amount Field
                Text(
                  isMl ? 'ലാഭ തുക (₹)' : 'Profit Amount (₹)',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
                    hintText: '0.00',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return isMl ? 'തുക നൽകുക' : 'Enter amount';
                    final val = double.tryParse(v.trim());
                    if (val == null || val <= 0) return isMl ? 'സാധുവായ തുക നൽകുക' : 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                Text(
                  isMl ? 'കുറിപ്പുകൾ (ഐച്ഛികം)' : 'Notes (Optional)',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: isMl ? 'അധിക വിവരങ്ങൾ നൽകുക...' : 'Add description...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Save Group Profit',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
