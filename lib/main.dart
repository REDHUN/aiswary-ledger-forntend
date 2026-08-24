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
import 'package:ashgledger/views/auth/login_screen.dart';
import 'package:ashgledger/views/main_navigation_screen.dart';
import 'package:ashgledger/views/member_portal/member_portal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
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
            home: const AuthWrapper(),
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
