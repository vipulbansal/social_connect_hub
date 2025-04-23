import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../services/auth_service.dart';
import '../widgets/auth_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show error message if there is one
        final hasError = authService.errorMessage != null;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo or icon
                const Icon(
                  Icons.chat_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),

                // Heading
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Chat App',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message (if any)
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authService.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Login form
                AuthForm(
                  isLogin: true,
                  isLoading: authService.isLoading,
                  onSubmit: (email, password, name) async {
                    // Clear any previous errors
                    authService.clearErrors();

                    // Call the service to sign in
                    // GoRouter will automatically redirect based on auth state
                    await authService.signIn(email, password);
                  },
                ),

                // Forgot password and signup links
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Use GoRouter for navigation
                    context.push('/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Use GoRouter for navigation to existing register page
                        context.go('/register');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}