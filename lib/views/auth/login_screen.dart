import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_snackbar.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../main_navigation_screen.dart';
import '../member_portal/member_portal_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController(text: 'admin');
  final TextEditingController passwordController = TextEditingController(text: 'admin123');

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A3622), Color(0xFF0F5132), Color(0xFF198754)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aiswarya Sangham',
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'Financial Ledger Application',
                        style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Selector<AuthViewModel, bool>(
                        selector: (_, vm) => vm.loadState.isLoading,
                        builder: (context, isLoading, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final username = usernameController.text.trim();
                                      final password = passwordController.text.trim();
                                      if (username.isEmpty || password.isEmpty) {
                                        AppSnackbar.showError(context, 'Please enter username and password');
                                        return;
                                      }

                                      final authVm = context.read<AuthViewModel>();
                                      final success = await authVm.login(username, password);
                                      if (context.mounted) {
                                        if (success) {
                                          AppSnackbar.showSuccess(context, 'Welcome ${authVm.username}!');
                                          if (authVm.isAdmin) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                                            );
                                          } else {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                                            );
                                          }
                                        } else {
                                          AppSnackbar.showError(
                                            context,
                                            authVm.loadState.message ?? 'Login failed. Please check credentials.',
                                          );
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text('Sign In', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
