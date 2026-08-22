import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../viewmodel/language_viewmodel.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'dashboard/dashboard_screen.dart';
import 'members/member_list_screen.dart';
import 'meetings/meeting_list_screen.dart';
import 'auth/login_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langVm = context.watch<LanguageViewModel>();

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('app_title')),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.language_rounded),
                tooltip: l10n.translate('language'),
                onSelected: (langCode) {
                  context.read<LanguageViewModel>().setLanguage(langCode);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'ml',
                    child: Row(
                      children: [
                        if (langVm.isMalayalam) const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                        if (langVm.isMalayalam) const SizedBox(width: 6),
                        Text('മലയാളം', style: TextStyle(fontWeight: langVm.isMalayalam ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'en',
                    child: Row(
                      children: [
                        if (!langVm.isMalayalam) const Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
                        if (!langVm.isMalayalam) const SizedBox(width: 6),
                        Text('English', style: TextStyle(fontWeight: !langVm.isMalayalam ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
                onPressed: () async {
                  await context.read<AuthViewModel>().logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                },
              )
            ],
          ),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              DashboardScreen(),
              MemberListScreen(),
              MeetingListScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _currentIndexNotifier.value = index,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
                label: l10n.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline_rounded),
                selectedIcon: const Icon(Icons.people_rounded, color: AppColors.primary),
                label: l10n.members,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note_rounded, color: AppColors.primary),
                label: l10n.meetings,
              ),
            ],
          ),
        );
      },
    );
  }
}
