import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashgledger/core/network/dio_client.dart';
import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/services/storage_service.dart';
import 'package:ashgledger/core/repository/auth_repository.dart';
import 'package:ashgledger/core/repository/member_repository.dart';
import 'package:ashgledger/core/repository/meeting_repository.dart';
import 'package:ashgledger/core/repository/member_processing_repository.dart';
import 'package:ashgledger/core/repository/dashboard_repository.dart';
import 'package:ashgledger/viewmodel/auth_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/viewmodel/meeting_viewmodel.dart';
import 'package:ashgledger/viewmodel/member_processing_viewmodel.dart';
import 'package:ashgledger/viewmodel/dashboard_viewmodel.dart';

import 'package:ashgledger/viewmodel/language_viewmodel.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<StorageService>(StorageService(prefs));

  sl.registerLazySingleton<DioClient>(() => DioClient(sl<StorageService>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<DioClient>().dio));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<ApiClient>(), sl<StorageService>()));
  sl.registerLazySingleton<MemberRepository>(() => MemberRepository(sl<ApiClient>()));
  sl.registerLazySingleton<MeetingRepository>(() => MeetingRepository(sl<ApiClient>()));
  sl.registerLazySingleton<MemberProcessingRepository>(() => MemberProcessingRepository(sl<ApiClient>()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepository(sl<ApiClient>()));

  // ViewModels
  sl.registerLazySingleton<LanguageViewModel>(() => LanguageViewModel(sl<StorageService>()));
  sl.registerFactory<AuthViewModel>(() => AuthViewModel(sl<AuthRepository>()));
  sl.registerFactory<MemberViewModel>(() => MemberViewModel(sl<MemberRepository>()));
  sl.registerFactory<MeetingViewModel>(() => MeetingViewModel(sl<MeetingRepository>()));
  sl.registerFactory<MemberProcessingViewModel>(() => MemberProcessingViewModel(sl<MemberProcessingRepository>()));
  sl.registerFactory<DashboardViewModel>(() => DashboardViewModel(sl<DashboardRepository>()));
}

