import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _animationController.forward();
    
    // Auto navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation placeholder (Would use a Lottie animation in production)
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.5), // Start off-screen (above)
                end: Offset.zero, // End at original position
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.elasticOut, // Bouncy entrance
              )),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 100,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            
            // App name with fade-in animation
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeInOut), // Start halfway through animation
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'FlutterChat',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Connect with friends, anytime, anywhere',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // CircularProgressIndicator that appears after animation finishes
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                ),
              ),
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

// App icon bounces down into the screen.
//
// App name and tagline fade in smoothly.
//
// Loading spinner appears at the bottom.
//
// User is navigated to the Login screen after 2 seconds.

// Tool | What it does
// AnimationController | Controls timing
// Tween | Defines start & end values
// CurvedAnimation | Makes it smooth or bouncy
// SlideTransition | Animates movement
// FadeTransition | Animates visibility
// Future.delayed | Delays navigation