import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';
import '../member_portal/member_portal_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final storage = sl<StorageService>();
    Widget nextScreen;

    if (storage.hasSession()) {
      if (storage.isAdmin()) {
        nextScreen = const MainNavigationScreen();
      } else {
        nextScreen = const MemberPortalScreen();
      }
    } else {
      nextScreen = LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF072A1A),
              Color(0xFF0D472B),
              Color(0xFF0F5132),
              Color(0xFF198754),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Animated Text-only Branding Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 36,
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 22),

                        // Main Malayalam Title "ഐശ്വര്യ"
                        Text(
                          'ഐശ്വര്യ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manjari(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Elegant Ornamental Line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accentGold.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: AppColors.accentGold.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accentGold.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Subtitle "സ്വയം സഹായക സംഘം"
                        Text(
                          'സ്വയം സഹായക സംഘം',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manjari(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFD54F),
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // English Subtitle
                        Text(
                          'Financial Ledger & Management System',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // Loading Indicator & Footer Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.bgLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Secure • Transparent • Community Led',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
