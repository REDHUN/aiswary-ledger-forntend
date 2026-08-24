import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/expense_viewmodel.dart';
import 'add_group_expense_dialog.dart';

class GroupExpensesScreen extends StatelessWidget {
  const GroupExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ExpenseViewModel>()..fetchGroupExpenses(),
      child: const _GroupExpensesBody(),
    );
  }
}

class _GroupExpensesBody extends StatelessWidget {
  const _GroupExpensesBody();

  void _openAddExpenseDialog(BuildContext context) {
    final expenseVm = context.read<ExpenseViewModel>();
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: expenseVm,
        child: const AddGroupExpenseDialog(),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<ExpenseViewModel>().fetchGroupExpenses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          isMl ? 'ഗ്രൂപ്പ് ചെലവുകൾ (Group Expenses)' : 'Group Expenses',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ExpenseViewModel>().fetchGroupExpenses(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        onPressed: () => _openAddExpenseDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isMl ? 'ചെലവ് ചേർക്കുക' : 'Record Expense',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading && vm.groupExpenses.isEmpty) {
            return const MemberListShimmerLoading();
          }

          final expenses = vm.groupExpenses;
          final totalExpenseAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);

          return RefreshIndicator(
            onRefresh: () => vm.fetchGroupExpenses(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Expenses Summary Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFED6C02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMl ? 'ആകെ ഗ്രൂപ്പ് ചെലവുകൾ' : 'Total Group Expenses',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${totalExpenseAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMl ? 'ചെലവ് രേഖകൾ (${expenses.length})' : 'Recorded Expenses (${expenses.length})',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddExpenseDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.deepOrange),
                      label: Text(
                        isMl ? 'പുതിയത്' : 'New',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (expenses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_outlined, size: 54, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          isMl ? 'ഗ്രൂപ്പ് ചെലവുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.' : 'No group expenses recorded yet.',
                          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _openAddExpenseDialog(context),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(isMl ? 'ചെലവ് ചേർക്കുക' : 'Record Expense'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                                child: const Icon(Icons.receipt_rounded, color: Colors.deepOrange),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.expenseTypeName,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'തീയതി: ${item.expenseDate}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (item.description != null && item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '₹${item.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepOrange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
