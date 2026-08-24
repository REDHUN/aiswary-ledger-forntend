import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/settings_viewmodel.dart';

class SpecialLoanTypesScreen extends StatelessWidget {
  const SpecialLoanTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes(),
      child: const _SpecialLoanTypesBody(),
    );
  }
}

class _SpecialLoanTypesBody extends StatelessWidget {
  const _SpecialLoanTypesBody();

  void _showAddSpecialLoanTypeDialog(BuildContext context, SettingsViewModel vm, bool isMl) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isMl ? 'സ്പെഷ്യൽ വായ്പ തരം ചേർക്കുക' : 'Add Special Loan Type',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: isMl ? 'പേര് (e.g., ഓണം വായ്പ)' : 'Name (e.g. Festival Loan)',
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isNotEmpty) {
                await vm.createSpecialLoanType(name, desc.isNotEmpty ? desc : null);
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
          isMl ? 'സ്പെഷ്യൽ വായ്പകൾ (Special Loans)' : 'Special Loan Types',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<SettingsViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: isMl ? 'സ്പെഷ്യൽ വായ്പ തരം ചേർക്കുക' : 'Add Special Loan Type',
              onPressed: () => _showAddSpecialLoanTypeDialog(context, vm, isMl),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<SettingsViewModel>(
        builder: (context, vm, _) => FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _showAddSpecialLoanTypeDialog(context, vm, isMl),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            isMl ? 'വായ്പ തരം ചേർക്കുക' : 'Add Loan Type',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) {
            return const MemberListShimmerLoading();
          }

          final specialLoanTypes = vm.specialLoanTypes;

          if (specialLoanTypes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      isMl ? 'സ്പെഷ്യൽ വായ്പകളൊന്നും ചേർത്തിട്ടില്ല.' : 'No special loan types added yet.',
                      style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: specialLoanTypes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = specialLoanTypes[index];
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
                    backgroundColor: item.isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade200,
                    child: Icon(
                      Icons.assignment_turned_in_rounded,
                      color: item.isActive ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                  ),
                  subtitle: item.description != null && item.description!.isNotEmpty
                      ? Text(item.description!, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary))
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isActive ? (isMl ? 'സജീവം' : 'Active') : (isMl ? 'നിഷ്ക്രിയം' : 'Inactive'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: item.isActive ? AppColors.primary : Colors.grey,
                      ),
                    ),
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
