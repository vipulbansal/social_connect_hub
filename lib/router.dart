import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_connect_hub/feature/home/pages/home_page.dart';

import 'core/di/service_locator.dart';
import 'feature/auth/pages/login_page.dart';
import 'feature/auth/pages/register_page.dart';
import 'feature/auth/services/auth_service.dart';
import 'feature/onboarding/pages/onboarding_page.dart';
import 'feature/welcome/pages/welcome_page.dart';

// Helper class to convert Stream to Listenable for GoRouter refreshing
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


class AppRouter{
  static bool hasSeenOnboarding = false;
  static final router=GoRouter(
      refreshListenable: GoRouterRefreshStream(locator<AuthService>().authStateStream),
      initialLocation: '/',
      redirect: (context,state){
        final authService = Provider.of<AuthService>(context, listen: false);
        final isAuthenticated = authService.status == AuthStatus.authenticated;
        // Define auth routes
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isWelcomeRoute = state.matchedLocation == '/';
        final isAuthRoute = isWelcomeRoute ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            isOnboardingRoute;
        // If first time user and not already on onboarding route, show onboarding
        if (!hasSeenOnboarding && !isOnboardingRoute) {
          return '/onboarding';
        }

        // If not authenticated and trying to access protected route
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // If authenticated and trying to access auth route, go to home
        if (isAuthenticated && isAuthRoute && !isOnboardingRoute) {
          return '/home';
        }

        // No redirect needed
        return null;

      },
      routes: [
        // Onboarding
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // Welcome screen
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomePage(),
        ),

        // Authentication
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),

  ]);
}