import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


import 'core/di/service_locator.dart';
import 'domain/repositories/auth/auth_repository.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/services/auth_service.dart';
import 'features/home/pages/home_page.dart';
import 'features/onboarding/pages/onboarding_page.dart';
import 'features/search/pages/search_page.dart';
import 'features/welcome/pages/welcome_page.dart';


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
  static final GoRouter router = GoRouter(
      refreshListenable: GoRouterRefreshStream(locator<AuthRepository>().watchAuthState()),
      initialLocation: '/',
      redirect: (BuildContext context, GoRouterState state) async {
        final authRepository = locator<AuthRepository>();
        final authResult = await authRepository.isAuthenticated();
        final isAuthenticated = authResult.fold(
            onSuccess: (success) => success,
            onFailure: (failure) => false
        );

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
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchPage(),
        ),
  ]);
}