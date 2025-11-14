// App-wide constants

class AppConstants {
  // Friction timing
  static const int minimumFrictionDurationSeconds = 3;
  static const int maximumFrictionDurationSeconds = 8;

  // Colors
  static const int primaryColorValue = 0xFF6C63FF;
  static const int backgroundColorValue = 0xFF1A1A2E;

  // Storage keys
  static const String frictionEnabledKey = 'friction_enabled';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Monitored apps (Android package names)
  static const Set<String> defaultMonitoredApps = {
    'com.instagram.android',
    'com.facebook.katana',
    'com.twitter.android',
    'com.reddit.frontpage',
    'com.zhiliaoapp.musically', // TikTok
    'com.snapchat.android',
    'com.google.android.youtube',
    'flipboard.app',
    'com.linkedin.android',
  };

  // App names mapping
  static const Map<String, String> appNamesMap = {
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.twitter.android': 'Twitter',
    'com.reddit.frontpage': 'Reddit',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.snapchat.android': 'Snapchat',
    'com.google.android.youtube': 'YouTube',
    'flipboard.app': 'Flipboard',
    'com.linkedin.android': 'LinkedIn',
  };
}
