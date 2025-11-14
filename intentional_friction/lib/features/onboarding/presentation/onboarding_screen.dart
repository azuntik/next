import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../providers/friction_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to\nIntentional Friction',
      description: 'The pause button for your unconscious habits.',
      icon: Icons.pause_circle_outline,
      color: Color(AppConstants.primaryColorValue),
    ),
    OnboardingPage(
      title: 'The Problem',
      description: 'You open Instagram "just to check one thing."\n\n'
          '45 minutes later, you\'re still scrolling.\n\n'
          'Sound familiar?',
      icon: Icons.phone_android,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Why It Happens',
      description: 'Your brain has two systems:\n\n'
          '• System 1: Fast, automatic (habits)\n'
          '• System 2: Slow, conscious (choices)\n\n'
          'Phone habits run on System 1 autopilot.',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Our Solution',
      description: 'We create a moment of awareness BEFORE you scroll.\n\n'
          'This activates System 2, giving you a conscious choice.',
      icon: Icons.lightbulb_outline,
      color: Colors.amber,
    ),
    OnboardingPage(
      title: 'How It Works',
      description: '1. Try to open Instagram/Twitter/etc.\n'
          '2. See a calming reflection prompt\n'
          '3. Reflect for 3 seconds\n'
          '4. Choose: Proceed or Close\n\n'
          'That\'s it. Simple, yet powerful.',
      icon: Icons.format_list_numbered,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'What Makes Us Different',
      description: 'We don\'t block apps.\n'
          'We don\'t shame you.\n'
          'We don\'t limit time.\n\n'
          'We just help you choose consciously.',
      icon: Icons.favorite_outline,
      color: Colors.pink,
    ),
    OnboardingPage(
      title: 'Privacy First',
      description: 'All your data stays on YOUR device.\n\n'
          '• No tracking\n'
          '• No ads\n'
          '• No data sales\n\n'
          'Your awareness journey is yours alone.',
      icon: Icons.lock_outline,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Ready to Begin?',
      description: 'Grant usage permissions on the next screen.\n\n'
          'Then start monitoring to begin your journey to mindful technology use.\n\n'
          'Let\'s make friction fashionable.',
      icon: Icons.rocket_launch,
      color: Color(AppConstants.primaryColorValue),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setSetting(AppConstants.onboardingCompletedKey, true);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Next/Finish button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage].color
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
