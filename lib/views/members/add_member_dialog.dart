import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_snackbar.dart';
import '../../core/common/app_date_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/member_viewmodel.dart';

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController numCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  DateTime selectedJoiningDate = DateTime.now();
  bool _obscurePassword = true;

  @override
  void dispose() {
    numCtrl.dispose();
    nameCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await AppDatePicker.pickDate(
      context: context,
      initialDate: selectedJoiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedJoiningDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateStr = selectedJoiningDate.toIso8601String().split('T')[0];

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.translate('register_new_member'),
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              _buildStyledTextField(
                controller: numCtrl,
                label: l10n.translate('member_number'),
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 14),
              _buildStyledTextField(
                controller: nameCtrl,
                label: l10n.translate('full_name'),
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 14),
              _buildStyledTextField(
                controller: userCtrl,
                label: l10n.translate('username'),
                icon: Icons.account_circle_rounded,
              ),
              const SizedBox(height: 14),
              _buildStyledTextField(
                controller: passCtrl,
                label: l10n.translate('password'),
                icon: Icons.lock_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 14),
              _buildStyledTextField(
                controller: phoneCtrl,
                label: l10n.translate('phone_number'),
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.translate('joining_date'),
                    labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                    ),
                  ),
                  child: Text(
                    dateStr,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.translate('cancel'), style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        Selector<MemberViewModel, bool>(
          selector: (_, vm) => vm.actionState.isLoading,
          builder: (context, isLoading, _) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final uname = userCtrl.text.trim().isNotEmpty ? userCtrl.text.trim() : phoneCtrl.text.trim();
                      if (numCtrl.text.isEmpty || nameCtrl.text.isEmpty || uname.isEmpty || passCtrl.text.isEmpty) {
                        AppSnackbar.showError(context, 'Please fill required fields');
                        return;
                      }

                      final success = await context.read<MemberViewModel>().createMember(
                            memberNumber: numCtrl.text.trim(),
                            fullName: nameCtrl.text.trim(),
                            username: uname,
                            password: passCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            joiningDate: dateStr,
                          );

                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(context, 'Member created successfully!');
                          Navigator.pop(context);
                        } else {
                          AppSnackbar.showError(
                            context,
                            context.read<MemberViewModel>().actionState.message ?? 'Failed to create member',
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(l10n.translate('save'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}
