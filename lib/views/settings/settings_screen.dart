import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../viewmodel/language_viewmodel.dart';
import '../groups/groups_screen.dart';
import 'expense_types_screen.dart';
import 'special_loan_types_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SettingsViewModel>(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  void _showSurplusUpdateDialog(BuildContext context, SettingsViewModel vm, bool isMl) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isMl ? 'മിച്ച തുക ചേർക്കുക' : 'Update Surplus Amount',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: isMl ? 'മിച്ച തുക (₹)' : 'Surplus Amount (₹)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.currency_rupee_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final val = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              await vm.updateSurplusAmount(val);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isMl ? 'മിച്ച തുക അപ്ഡേറ്റ് ചെയ്തു!' : 'Surplus amount updated!')),
                );
              }
            },
            child: Text(isMl ? 'സേവ് ചെയ്യുക' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context, bool isMl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('ഐശ്വര്യ സംഘം', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMl ? 'ഐശ്വര്യ ധനകാര്യ സംഘം ലെഡ്ജർ ആപ്പ്' : 'Aiswarya Sangham Ledger Application',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              isMl ? 'അംഗങ്ങളുടെ ലെഡ്ജർ, യോഗങ്ങൾ, വായ്പകൾ, നിക്ഷേപങ്ങൾ എന്നിവ എളുപ്പത്തിൽ കൈകാര്യം ചെയ്യാനുള്ള സിസ്റ്റം.' : 'Digital financial ledger management app for meetings, loans, deposits, and member balances.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text('Version 1.0.0', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isMl ? 'അടയ്ക്കുക' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';
    final settingsVm = context.read<SettingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          isMl ? 'സെറ്റിംഗ്സ് (Settings)' : 'Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: App Preferences
          _buildSectionTitle(isMl ? 'ആപ്പ് ക്രമീകരണങ്ങൾ (Preferences)' : 'Preferences'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Consumer<LanguageViewModel>(
              builder: (context, langVm, _) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.language_rounded, color: AppColors.primary),
                ),
                title: Text(
                  isMl ? 'ആപ്പ് ഭാഷ (Language)' : 'App Language',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                ),
                subtitle: Text(
                  langVm.isMalayalam ? 'മലയാളം (Malayalam)' : 'English',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        langVm.isMalayalam ? 'മലയാളം' : 'English',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
                onTap: () => langVm.toggleLanguage(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Financial Configurations
          _buildSectionTitle(isMl ? 'ധനകാര്യ ഇനങ്ങൾ (Financial Configurations)' : 'Financial Configurations'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                    child: const Icon(Icons.category_rounded, color: Colors.deepOrange),
                  ),
                  title: Text(
                    isMl ? 'ചെലവ് തരങ്ങൾ (Expense Types)' : 'Expense Types',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  subtitle: Text(
                    isMl ? 'സംഘം ചെലവ് വിഭാ​ഗങ്ങൾ ക്രമീകരിക്കുക' : 'Configure group expense categories',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExpenseTypesScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    isMl ? 'സ്പെഷ്യൽ വായ്പകൾ (Special Loan Types)' : 'Special Loan Types',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  subtitle: Text(
                    isMl ? 'പ്രത്യേക വായ്പ ഇനങ്ങൾ ക്രമീകരിക്കുക' : 'Configure special loan products',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpecialLoanTypesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Group & Fund Management
          _buildSectionTitle(isMl ? 'ഗ്രൂപ്പും മിച്ച തുകയും (Group & Funds)' : 'Group & Funds'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    child: const Icon(Icons.groups_rounded, color: Colors.teal),
                  ),
                  title: Text(
                    isMl ? 'ഗ്രൂപ്പ് മാനേജ്മെന്റ് (Group Management)' : 'Group Management',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  subtitle: Text(
                    isMl ? 'ഗ്രൂപ്പുകൾ ഉണ്ടാക്കുക, വായ്പകൾ നൽകുക' : 'Manage groups & group loans',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GroupsScreen()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 64, color: AppColors.borderLight),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.amber.shade900),
                  ),
                  title: Text(
                    isMl ? 'മിച്ച തുക (Surplus Reserve)' : 'Surplus Reserve Fund',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  subtitle: Text(
                    isMl ? 'ഗ്രൂപ്പിന്റെ മിച്ച തുക ചേർക്കുക' : 'Update group surplus reserve amount',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () => _showSurplusUpdateDialog(context, settingsVm, isMl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Application Info
          _buildSectionTitle(isMl ? 'ആപ്പ് വിവരങ്ങൾ (Information)' : 'Information'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: const Icon(Icons.info_outline_rounded, color: Colors.blue),
              ),
              title: Text(
                isMl ? 'ആപ്പിനെക്കുറിച്ച് (About App)' : 'About App',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
              ),
              subtitle: Text(
                'Version 1.0.0 • ഐശ്വര്യ സംഘം',
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () => _showAboutAppDialog(context, isMl),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
