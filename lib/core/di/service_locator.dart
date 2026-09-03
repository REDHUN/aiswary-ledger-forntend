import '../repository/group_profit_repository.dart';
import '../../viewmodel/group_profit_viewmodel.dart';
import 'package:ashgledger/core/repository/expense_repository.dart';
import 'package:ashgledger/viewmodel/expense_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashgledger/core/network/dio_client.dart';
import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/services/storage_service.dart';
import 'package:ashgledger/core/services/fcm_service.dart';
import 'package:ashgledger/core/repository/auth_repository.dart';
import 'package:ashgledger/core/repository/member_repository.dart';
import 'package:ashgledger/core/repository/meeting_repository.dart';
import 'package:ashgledger/core/repository/member_processing_repository.dart';
import 'package:ashgledger/core/repository/dashboard_repository.dart';
import 'package:ashgledger/core/repository/reports_repository.dart';
import 'package:ashgledger/core/repository/settings_repository.dart';
import 'package:ashgledger/core/repository/group_repository.dart';
import 'package:ashgledger/viewmodel/auth_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/viewmodel/meeting_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_processing_viewmodel.dart';
import 'package:ashgledger/viewmodel/dashboard_viewmodel.dart';
import 'package:ashgledger/viewmodel/reports_viewmodel.dart';
import 'package:ashgledger/viewmodel/settings_viewmodel.dart';
import 'package:ashgledger/viewmodel/group_viewmodel.dart';
import 'package:ashgledger/viewmodel/language_viewmodel.dart';

import 'package:ashgledger/core/repository/notification_repository.dart';
import 'package:ashgledger/viewmodel/notification_viewmodel.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<StorageService>(StorageService(prefs));

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<StorageService>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<DioClient>().dio));

  // Services
  sl.registerLazySingleton<FcmService>(() => FcmService(sl<StorageService>(), sl<ApiClient>()));

  // Repositories
  sl.registerLazySingleton(() => ExpenseRepository(sl()));
  sl.registerLazySingleton(() => GroupProfitRepository(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<ApiClient>(), sl<StorageService>(), sl<FcmService>()));
  sl.registerLazySingleton<MemberRepository>(() => MemberRepository(sl<ApiClient>()));
  sl.registerLazySingleton<MeetingRepository>(() => MeetingRepository(sl<ApiClient>()));
  sl.registerLazySingleton<MemberProcessingRepository>(() => MemberProcessingRepository(sl<ApiClient>()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepository(sl<ApiClient>()));
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepository(sl<ApiClient>()));
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepository(sl<ApiClient>()));

  // ViewModels
  sl.registerFactory(() => ExpenseViewModel(sl()));
  sl.registerFactory(() => GroupProfitViewModel(sl()));
  sl.registerLazySingleton<LanguageViewModel>(() => LanguageViewModel(sl<StorageService>()));
  sl.registerFactory<AuthViewModel>(() => AuthViewModel(sl<AuthRepository>()));
  sl.registerFactory<MemberViewModel>(() => MemberViewModel(sl<MemberRepository>()));
  sl.registerFactory<MeetingViewModel>(() => MeetingViewModel(sl<MeetingRepository>()));
  sl.registerFactory<MemberProcessingViewModel>(() => MemberProcessingViewModel(sl<MemberProcessingRepository>()));
  sl.registerFactory<DashboardViewModel>(() => DashboardViewModel(sl<DashboardRepository>()));
  sl.registerFactory<ReportsViewModel>(() => ReportsViewModel(sl<ReportsRepository>()));
  sl.registerFactory<SettingsViewModel>(() => SettingsViewModel(sl<SettingsRepository>()));
  sl.registerFactory<GroupViewModel>(() => GroupViewModel(sl<GroupRepository>()));
  sl.registerFactory<NotificationViewModel>(() => NotificationViewModel(sl<NotificationRepository>()));
}
