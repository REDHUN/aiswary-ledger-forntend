import '../viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/member_viewmodel.dart';
import '../viewmodel/meeting_viewmodel.dart';
import 'settings/settings_screen.dart';
import '../viewmodel/notification_viewmodel.dart';
import 'notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'dashboard/dashboard_screen.dart';
import 'members/member_list_screen.dart';
import 'meetings/meeting_list_screen.dart';
import 'auth/login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await context.read<AuthViewModel>().logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('app_title')),
            actions: [
              Consumer<NotificationViewModel>(
                builder: (context, notifVm, _) {
                  final count = notifVm.unreadCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        tooltip: 'Notifications',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              _isLoggingOut
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: 'Logout',
                      onPressed: _handleLogout,
                    ),
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
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                _currentIndexNotifier.value = index;
                if (index == 0) {
                  context.read<DashboardViewModel>().fetchDashboardSummary();
                } else if (index == 1) {
                  context.read<MemberViewModel>().fetchMembers();
                } else if (index == 2) {
                  context.read<MeetingViewModel>().fetchMeetings();
                }
              },
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primary.withValues(alpha: 0.14),
              elevation: 0,
              destinations: [
                NavigationDestination(
                  icon: const Icon(
                    Icons.grid_view_outlined,
                    color: AppColors.textSecondary,
                  ),
                  selectedIcon: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: l10n.dashboard,
                ),
                NavigationDestination(
                  icon: const Icon(
                    Icons.group_outlined,
                    color: AppColors.textSecondary,
                  ),
                  selectedIcon: const Icon(
                    Icons.group_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: l10n.members,
                ),
                NavigationDestination(
                  icon: const Icon(
                    Icons.event_note_outlined,
                    color: AppColors.textSecondary,
                  ),
                  selectedIcon: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.primaryDark,
                  ),
                  label: l10n.meetings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
