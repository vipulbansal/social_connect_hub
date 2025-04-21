import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_connect_hub/feature/onboarding/models/onboarding_item.dart';
import 'package:social_connect_hub/router.dart';

import '../widgets/dotted_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    AppRouter.hasSeenOnboarding=true;
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    _currentPage < onboardingItems.length - 1
                        ? 'Skip'
                        : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  return _OnboardingPageItem(item: onboardingItems[index]);
                },
                itemCount: onboardingItems.length,
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            ),
            // Dotted page indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: AnimatedDottedPageIndicator(
                pageCount: onboardingItems.length,
                controller: _pageController,
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
                dotSize: 10.0,
                spacing: 8.0,
              ),
            ),
            // Next/Get Started button
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    if (_pageController.page!.round() <
                        onboardingItems.length - 1) {
                      // Go to next page
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      await _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    _currentPage == onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageItem extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingPageItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Title
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            item.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
