// Global instance of GetIt
import 'package:get_it/get_it.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';

import '../../feature/auth/services/auth_service.dart';

final GetIt locator = GetIt.instance;
final GetIt serviceLocator = locator; // Alias for convenience

/// Initialize all services and dependencies
Future<void> setupServiceLocator() async {

  // App services
  locator.registerLazySingleton<AuthService>(() => AuthService(
  ));

  locator.registerLazySingleton<ThemeProvider>(() => ThemeProvider(
  ));
}