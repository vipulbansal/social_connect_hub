import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'feature/auth/services/auth_service.dart';
import 'feature/onboarding/pages/onboarding_page.dart';
import 'feature/welcome/pages/welcome_page.dart';

class AppRouter{
  static bool hasSeenOnboarding = false;
  static final router=GoRouter(
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

  ]);
}