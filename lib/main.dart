import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';
import 'package:social_connect_hub/features/friends/services/friend_service.dart';
import 'package:social_connect_hub/features/search/services/search_service.dart';
import 'package:social_connect_hub/router.dart';

import 'core/di/service_locator.dart';
import 'core/services/firebase_service.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/services/auth_service.dart';
import 'features/notification/services/notification_service.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if the user has seen the onboarding
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setupServiceLocator();
  // Initialize Hive for local storage
  var path = Directory.current.path;
  Hive.init(path);
  final notificationService = locator<NotificationService>();
  await notificationService.requestNotificationPermissions();
  runApp(SocialConnectHubApp(seenOnboarding: seenOnboarding));
}

class SocialConnectHubApp extends StatelessWidget {
  final bool seenOnboarding;
  const SocialConnectHubApp({super.key, required this.seenOnboarding});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // We'll use onboarding status in router.dart
    // For simplicity, we'll create a static variable in AppRouter to access in redirect
    AppRouter.hasSeenOnboarding = seenOnboarding;
    return MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider(create: (_) => locator<AuthService>()),
        ChangeNotifierProvider(create: (_) => locator<SearchService>()),
        ChangeNotifierProvider(create: (_) => locator<FriendService>()),
        ChangeNotifierProvider(create: (_) => locator<NotificationService>()),
        ChangeNotifierProvider(create: (_) => locator<ThemeProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          AppTheme.setDarkMode(themeProvider.isDarkMode);
          return MaterialApp.router(
            title: 'Social Connect Hub',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
