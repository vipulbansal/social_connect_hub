// Global instance of GetIt
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';

import '../../feature/auth/services/auth_service.dart';
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
  // App services
  locator.registerLazySingleton<AuthService>(
    () => AuthService(firebaseService: locator<FirebaseService>()),
  );

  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
}
