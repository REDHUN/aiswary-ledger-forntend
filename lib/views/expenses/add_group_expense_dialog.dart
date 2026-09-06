import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_formatters.dart';
import '../../core/model/expense_type_model.dart';
import '../../core/model/group_expense_model.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/expense_viewmodel.dart';
import '../../viewmodel/dashboard_viewmodel.dart';

class AddGroupExpenseDialog extends StatefulWidget {
  final int? preselectedMeetingId;
  final GroupExpenseModel? expenseToEdit;

  const AddGroupExpenseDialog({
    super.key,
    this.preselectedMeetingId,
    this.expenseToEdit,
  });

  @override
  State<AddGroupExpenseDialog> createState() => _AddGroupExpenseDialogState();
}

class _AddGroupExpenseDialogState extends State<AddGroupExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  ExpenseTypeModel? _selectedExpenseType;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _newTypeNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _notesController.text = widget.expenseToEdit!.description ?? '';
      final parsed = DateTime.tryParse(widget.expenseToEdit!.expenseDate);
      if (parsed != null) {
        _selectedDate = parsed;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ExpenseViewModel>();
      await vm.fetchExpenseTypes();
      if (_isEditing && mounted && vm.expenseTypes.isNotEmpty) {
        final matches = vm.expenseTypes.where((t) => t.id == widget.expenseToEdit!.expenseTypeId);
        if (matches.isNotEmpty) {
          setState(() {
            _selectedExpenseType = matches.first;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _newTypeNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddExpenseTypeDialog(BuildContext context) {
    _newTypeNameController.clear();
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isMl ? 'പുതിയ ചെലവ് തരം' : 'New Expense Type',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _newTypeNameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isMl
                ? 'തരം പേര് (ഉദാ: റഫ്രഷ്മെന്റ്)'
                : 'Type Name (e.g. Refreshment)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = _newTypeNameController.text.trim();
              if (name.isNotEmpty) {
                final vm = context.read<ExpenseViewModel>();
                final ok = await vm.createExpenseType(name);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (ok && mounted && vm.expenseTypes.isNotEmpty) {
                  setState(() {
                    _selectedExpenseType = vm.expenseTypes.last;
                  });
                }
              }
            },
            child: Text(isMl ? 'ചേർക്കുക' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExpenseType == null) {
      final l10n = AppLocalizations.of(context);
      final isMl = l10n.locale.languageCode == 'ml';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMl ? 'ചെലവ് തരം തിരഞ്ഞെടുക്കുക' : 'Select an expense type',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final vm = context.read<ExpenseViewModel>();
    final amount = double.parse(_amountController.text.trim());
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final bool success;
    if (_isEditing) {
      success = await vm.updateGroupExpense(
        id: widget.expenseToEdit!.id,
        expenseTypeId: _selectedExpenseType!.id,
        amount: amount,
        expenseDate: dateStr,
        description: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        meetingId: widget.expenseToEdit!.meetingId ?? widget.preselectedMeetingId,
      );
    } else {
      success = await vm.createGroupExpense(
        expenseTypeId: _selectedExpenseType!.id,
        amount: amount,
        expenseDate: dateStr,
        description: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
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
                  ? (isMl ? 'ചെലവ് വിജയകരമായി പുതുക്കി' : 'Expense updated successfully')
                  : (isMl ? 'ചെലവ് വിജയകരമായി രേഖപ്പെടുത്തി' : 'Expense recorded successfully'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final l10n = AppLocalizations.of(context);
        final isMl = l10n.locale.languageCode == 'ml';
        final err =
            vm.loadState.message ??
            (isMl
                ? (_isEditing ? 'ചെലവ് പുതുക്കാൻ കഴിഞ്ഞില്ല' : 'ചെലവ് രേഖപ്പെടുത്താൻ കഴിഞ്ഞില്ല')
                : (_isEditing ? 'Failed to update expense' : 'Failed to record expense'));
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing
                            ? (isMl ? 'ചെലവ് മാറ്റുക' : 'Edit Group Expense')
                            : (isMl ? 'ഗ്രൂപ്പ് ചെലവ് ചേർക്കുക' : 'Record Group Expense'),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Expense Type Dropdown + Add Button
                Row(
                  children: [
                    Expanded(
                      child: Consumer<ExpenseViewModel>(
                        builder: (context, vm, _) {
                          final types = vm.expenseTypes;
                          return DropdownButtonFormField<ExpenseTypeModel>(
                            value: _selectedExpenseType,
                            decoration: InputDecoration(
                              labelText: isMl ? 'ചെലവ് തരം' : 'Expense Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: types.map((t) {
                              return DropdownMenuItem<ExpenseTypeModel>(
                                value: t,
                                child: Text(
                                  t.name,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedExpenseType = val;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showAddExpenseTypeDialog(context),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                        tooltip: isMl ? 'പുതിയ തരം' : 'New Type',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: isMl ? 'തുക (₹)' : 'Amount (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return isMl ? 'തുക നൽകുക' : 'Enter amount';
                    }
                    final v = double.tryParse(val.trim());
                    if (v == null || v <= 0) {
                      return isMl ? 'സാധുവായ തുക നൽകുക' : 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expense Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: isMl ? 'തീയതി' : 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      AppFormatters.formatDate(_selectedDate),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes / Description
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: isMl
                        ? 'കുറിപ്പുകൾ / വിവരണം'
                        : 'Notes / Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitExpense,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing
                                ? (isMl ? 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക' : 'Update Expense')
                                : (isMl ? 'ചെലവ് രേഖപ്പെടുത്തുക' : 'Record Expense'),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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