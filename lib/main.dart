import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/theme/app_theme.dart';
import 'package:ashgledger/core/services/storage_service.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/viewmodel/language_viewmodel.dart';
import 'package:ashgledger/viewmodel/auth_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/viewmodel/meeting_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_processing_viewmodel.dart';
import 'package:ashgledger/viewmodel/dashboard_viewmodel.dart';
import 'package:ashgledger/viewmodel/reports_viewmodel.dart';
import 'package:ashgledger/viewmodel/group_profit_viewmodel.dart';
import 'package:ashgledger/viewmodel/notification_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_portal_viewmodel.dart';
import 'package:ashgledger/views/auth/login_screen.dart';
import 'package:ashgledger/views/main_navigation_screen.dart';
import 'package:ashgledger/views/member_portal/member_portal_screen.dart';
import 'package:ashgledger/views/member_portal/member_all_transactions_screen.dart';
import 'package:ashgledger/views/meetings/meeting_list_screen.dart';
import 'package:ashgledger/views/meetings/meeting_detail_screen.dart';
import 'package:ashgledger/views/notifications/notifications_screen.dart';
import 'package:ashgledger/views/notifications/send_notification_screen.dart';
import 'package:ashgledger/views/reports/meeting_register_book_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ashgledger/firebase_options.dart';
import 'package:ashgledger/core/services/fcm_service.dart';
import 'package:ashgledger/views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (FcmService.isSupported) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  }

  await setupLocator();

  if (FcmService.isSupported) {
    await sl<FcmService>().initialize();
  }

  runApp(const AiswaryaLedgerApp());
}

class AiswaryaLedgerApp extends StatelessWidget {
  const AiswaryaLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<LanguageViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MeetingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MemberProcessingViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<DashboardViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<ReportsViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<GroupProfitViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<NotificationViewModel>()..fetchUnreadCount()),
        ChangeNotifierProvider(create: (_) => sl<MemberPortalViewModel>()),
      ],
      child: Selector<LanguageViewModel, Locale>(
        selector: (_, vm) => vm.locale,
        builder: (context, locale, _) {
          return MaterialApp(
            title: 'Aiswarya Sangham Ledger',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: locale,
            supportedLocales: const [
              Locale('ml'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              '/notifications': (context) => const NotificationsScreen(),
              '/send-notification': (context) => const SendNotificationScreen(),
              '/meetings': (context) => const MeetingListScreen(),
              '/transactions': (context) => const MemberAllTransactionsScreen(),
              '/loans': (context) => const MemberPortalScreen(),
              '/fines': (context) => const MemberPortalScreen(),
              '/register-book': (context) {
                final storage = sl<StorageService>();
                return MeetingRegisterBookScreen(
                  isReadOnly: !storage.isAdmin(),
                  showAppBar: true,
                );
              },
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/meeting-details') {
                final args = settings.arguments as Map<String, dynamic>?;
                final meetingId = args?['meetingId'] as int? ?? 0;
                return MaterialPageRoute(
                  builder: (_) => MeetingDetailScreen(meetingId: meetingId),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = sl<StorageService>();
    if (storage.hasSession()) {
      if (storage.isAdmin()) {
        return const MainNavigationScreen();
      } else {
        return const MemberPortalScreen();
      }
    }
    return LoginScreen();
  }
}
