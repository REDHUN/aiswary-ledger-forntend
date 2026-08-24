import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/model/expense_type_model.dart';
import '../../viewmodel/expense_viewmodel.dart';
import '../../viewmodel/dashboard_viewmodel.dart';

class AddGroupExpenseDialog extends StatefulWidget {
  const AddGroupExpenseDialog({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().fetchExpenseTypes();
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'പുതിയ ചെലവ് തരം ചേർക്കുക',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: _newTypeNameController,
          decoration: const InputDecoration(
            labelText: 'ചെലവ് തരം (e.g. Refreshment, Stationery)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = _newTypeNameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await context.read<ExpenseViewModel>().createExpenseType(name);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense type added!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExpenseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expense type')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() {
      _isSubmitting = true;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final success = await context.read<ExpenseViewModel>().createGroupExpense(
      expenseTypeId: _selectedExpenseType!.id,
      amount: amount,
      expenseDate: formattedDate,
      description: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      if (success) {
        Navigator.pop(context);
        context.read<DashboardViewModel>().fetchDashboardSummary();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group Expense recorded and deducted from Surplus Fund!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record group expense')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
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
                        'ഗ്രൂപ്പ് ചെലവ് ചേർക്കുക (Expense)',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'ഈ ചെലവ് മിച്ച തുകയിൽ (Surplus Fund) നിന്ന് കുറയ്ക്കപ്പെടും.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w500),
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
                            initialValue: _selectedExpenseType,
                            decoration: InputDecoration(
                              labelText: 'ചെലവ് തരം (Expense Type)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: types.map((t) {
                              return DropdownMenuItem<ExpenseTypeModel>(
                                value: t,
                                child: Text(t.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
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
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add New Expense Type',
                      onPressed: () => _showAddExpenseTypeDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'തുക (Amount ₹)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter amount';
                    final v = double.tryParse(val.trim());
                    if (v == null || v <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expense Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'തീയതി (Date)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes / Description
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'വിവരണം / കുറിപ്പ് (Notes)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSubmitting ? null : _submitExpense,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('ചെലവ് രേഖപ്പെടുത്തുക (Record Expense)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
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
