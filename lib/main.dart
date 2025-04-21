import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';
import 'package:social_connect_hub/router.dart';

import 'core/themes/app_theme.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if the user has seen the onboarding
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

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
    return Consumer<ThemeProvider>(
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
    );
  }
}
