class OnboardingItem {
  final String title;
  final String description;

  
  OnboardingItem({
    required this.title,
    required this.description,
  });
}

final List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: 'Welcome to Vipul-ConnectHub',
    description: 'Connect with friends, family, and colleagues with our secure messaging app.',
  ),
  OnboardingItem(
    title: 'Real-Time Messaging',
    description: 'Send and receive messages instantly with real-time updates and notifications.',
  ),
  OnboardingItem(
    title: 'Share More Than Text',
    description: 'Share photos, videos, and files with your contacts with end-to-end encryption.',
  ),
];