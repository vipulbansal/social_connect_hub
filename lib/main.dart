import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/core/themes/theme_provider.dart';
import 'package:social_connect_hub/router.dart';

import 'core/themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SocialConnectHubApp());
}

class SocialConnectHubApp extends StatelessWidget {
  const SocialConnectHubApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
