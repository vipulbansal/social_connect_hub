// Global instance of GetIt
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';
import 'package:social_connect_hub/data/datasources/friend/firebase_friend_data_source.dart';
import 'package:social_connect_hub/data/datasources/friend/friend_data_source.dart';
import 'package:social_connect_hub/data/datasources/user/firebase_user_data_source.dart';
import 'package:social_connect_hub/data/repositories/friend/friend_repository_impl.dart';
import 'package:social_connect_hub/domain/repositories/friend/friend_repository.dart';
import 'package:social_connect_hub/domain/usecases/friend/send_friend_request_usecase.dart';
import 'package:social_connect_hub/domain/usecases/friend/watch_received_friend_requests_usecase.dart';
import 'package:social_connect_hub/domain/usecases/friend/watch_sent_friend_requests_usecase.dart';
import 'package:social_connect_hub/domain/usecases/user/search_users_usecase.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
import 'package:social_connect_hub/features/search/services/search_service.dart';

import '../../data/datasources/auth/auth_data_source.dart';
import '../../data/datasources/auth/firebase_auth_data_source.dart';
import '../../data/datasources/user/user_data_source.dart';
import '../../data/repositories/auth/auth_repository_impl.dart';
import '../../data/repositories/user/user_repository_impl.dart';
import '../../domain/repositories/auth/auth_repository.dart';
import '../../domain/repositories/user/user_repository.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../features/auth/services/auth_service.dart';
import 'firebase_service.dart';

final GetIt locator = GetIt.instance;
final GetIt serviceLocator = locator; // Alias for convenience

/// Initialize all services and dependencies
Future<void> setupServiceLocator() async {
  // Firebase instances
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  locator.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
  locator.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );

  // Firebase service
  locator.registerLazySingleton<FirebaseService>(
    () => FirebaseService(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
      storage: locator<FirebaseStorage>(),
      messaging: locator<FirebaseMessaging>(),
    ),
  );
  // Initialize Firebase
  await locator<FirebaseService>().initialize();

  // Data Sources
  locator.registerLazySingleton<AuthDataSource>(
    () => FirebaseAuthDataSource(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerLazySingleton<UserDataSource>(
    () => FirebaseUserDataSource(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerLazySingleton<FriendDataSource>(
    () => FirebaseFriendDataSource(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  // App services
  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: locator<AuthDataSource>()),
  );

  locator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userDataSource: locator<UserDataSource>()),
  );

  locator.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(friendDataSource: locator<FriendDataSource>()),
  );

  // Auth use cases
  locator.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(locator<AuthRepository>()),
  );

  locator.registerFactory<SignUpUseCase>(
    () => SignUpUseCase(locator<AuthRepository>()),
  );

  locator.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(locator<AuthRepository>()),
  );

  locator.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(locator<AuthRepository>()),
  );

  // User use cases
  locator.registerFactory<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(locator<UserRepository>()),
  );

  // User use cases
  locator.registerFactory<SearchUsersUsecase>(
    () => SearchUsersUsecase(userRepository: locator<UserRepository>()),
  );

  //friend use cases
  locator.registerFactory<SendFriendRequestUseCase>(
    () => SendFriendRequestUseCase(locator<FriendRepository>()),
  );

  locator.registerFactory<WatchSentFriendRequestsUseCase>(
    () => WatchSentFriendRequestsUseCase(locator<FriendRepository>()),
  );

  locator.registerFactory<WatchReceivedFriendRequestsUsecase>(
    () => WatchReceivedFriendRequestsUsecase(locator<FriendRepository>()),
  );

  // Auth Service (initialize first as other components depend on it)
  locator.registerLazySingleton<AuthService>(
    () => AuthService(
      authRepository: locator<AuthRepository>(),
      userRepository: locator<UserRepository>(),
      signInUseCase: locator<SignInUseCase>(),
      signUpUseCase: locator<SignUpUseCase>(),
      signOutUseCase: locator<SignOutUseCase>(),
      resetPasswordUseCase: locator<ResetPasswordUseCase>(),
    ),
  );

  locator.registerLazySingleton<SearchService>(
    () => SearchService(
      userRepository: locator<UserRepository>(),
      searchUsersUsecase: locator<SearchUsersUsecase>(),
    ),
  );

  locator.registerLazySingleton<FriendService>(
    () => FriendService(
      locator<FriendRepository>(),
      locator<UserRepository>(),
      locator<AuthRepository>(),
      locator<SendFriendRequestUseCase>(),
      locator<WatchSentFriendRequestsUseCase>(),
      locator<WatchReceivedFriendRequestsUsecase>(),
    ),
  );

  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
}
