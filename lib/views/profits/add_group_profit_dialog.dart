import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/model/group_profit_model.dart';
import '../../viewmodel/group_profit_viewmodel.dart';
import '../../viewmodel/dashboard_viewmodel.dart';

class AddGroupProfitDialog extends StatefulWidget {
  final int? preselectedMeetingId;
  final GroupProfitModel? profitToEdit;

  const AddGroupProfitDialog({
    super.key,
    this.preselectedMeetingId,
    this.profitToEdit,
  });

  @override
  State<AddGroupProfitDialog> createState() => _AddGroupProfitDialogState();
}

class _AddGroupProfitDialogState extends State<AddGroupProfitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEditing => widget.profitToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.profitToEdit!.title;
      _amountController.text = widget.profitToEdit!.amount.toString();
      _notesController.text = widget.profitToEdit!.description ?? '';
      final parsed = DateTime.tryParse(widget.profitToEdit!.profitDate);
      if (parsed != null) {
        _selectedDate = parsed;
      }
    }
  }

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
    final desc = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    final vm = context.read<GroupProfitViewModel>();
    final bool success;

    if (_isEditing) {
      success = await vm.updateGroupProfit(
        id: widget.profitToEdit!.id,
        title: title,
        amount: amount,
        profitDate: dateStr,
        description: desc,
        meetingId: widget.profitToEdit!.meetingId ?? widget.preselectedMeetingId,
      );
    } else {
      success = await vm.recordGroupProfit(
        title: title,
        amount: amount,
        profitDate: dateStr,
        description: desc,
        meetingId: widget.preselectedMeetingId,
      );
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        final l10n = AppLocalizations.of(context);
        final isMl = l10n.locale.languageCode == 'ml';
        try {
          context.read<DashboardViewModel>().fetchDashboardSummary();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? (isMl ? 'ലാഭം വിജയകരമായി പുതുക്കി!' : 'Profit updated successfully!')
                  : (isMl ? 'ലാഭം വിജയകരമായി രേഖപ്പെടുത്തി!' : 'Profit recorded successfully!'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final err = vm.actionState.message ?? (_isEditing ? 'Failed to update profit' : 'Failed to record profit');
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
                        _isEditing
                            ? (isMl ? 'ലാഭം മാറ്റുക' : 'Edit Group Profit')
                            : (isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Record Group Profit'),
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
                      _isEditing
                          ? (isMl ? 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക' : 'Update Group Profit')
                          : (isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Save Group Profit'),
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