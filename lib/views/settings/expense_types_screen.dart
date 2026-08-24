import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/expense_viewmodel.dart';

class ExpenseTypesScreen extends StatelessWidget {
  const ExpenseTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ExpenseViewModel>()..fetchExpenseTypes(),
      child: const _ExpenseTypesBody(),
    );
  }
}

class _ExpenseTypesBody extends StatelessWidget {
  const _ExpenseTypesBody();

  void _showAddExpenseTypeDialog(BuildContext context, ExpenseViewModel vm, bool isMl) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isMl ? 'ചെലവ് തരം ചേർക്കുക' : 'Add Expense Type',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: isMl ? 'ചെലവിന്റെ പേര് (e.g. Tea/Refreshment)' : 'Expense Type Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: isMl ? 'വിവരണം (Description)' : 'Description (Optional)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isNotEmpty) {
                await vm.createExpenseType(name, description: desc.isNotEmpty ? desc : null);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(isMl ? 'സേവ് ചെയ്യുക' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          isMl ? 'ചെലവ് തരങ്ങൾ (Expense Types)' : 'Expense Types',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ExpenseViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: isMl ? 'ചെലവ് തരം ചേർക്കുക' : 'Add Expense Type',
              onPressed: () => _showAddExpenseTypeDialog(context, vm, isMl),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ExpenseViewModel>(
        builder: (context, vm, _) => FloatingActionButton.extended(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          onPressed: () => _showAddExpenseTypeDialog(context, vm, isMl),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            isMl ? 'ചെലവ് തരം ചേർക്കുക' : 'Add Expense Type',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) {
            return const MemberListShimmerLoading();
          }

          final expenseTypes = vm.expenseTypes;

          if (expenseTypes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      isMl ? 'ചെലവ് തരങ്ങളൊന്നും ചേർത്തിട്ടില്ല.' : 'No expense types added yet.',
                      style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenseTypes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = expenseTypes[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                    child: const Icon(Icons.category_rounded, color: Colors.deepOrange),
                  ),
                  title: Text(
                    item.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                  subtitle: item.description != null && item.description!.isNotEmpty
                      ? Text(item.description!, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: isMl ? 'നീക്കം ചെയ്യുക' : 'Delete',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(isMl ? 'തീർച്ചയാണോ?' : 'Confirm Delete'),
                          content: Text(isMl ? '${item.name} നീക്കം ചെയ്യണോ?' : 'Delete ${item.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isMl ? 'ഇല്ല' : 'Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(isMl ? 'നീക്കം ചെയ്യുക' : 'Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await vm.deleteExpenseType(item.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
