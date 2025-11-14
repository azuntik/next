# Intentional Friction: Implementation Guide
**Complete technical guide for building the app in Flutter**

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Architecture Overview](#architecture-overview)
4. [Phase 1: MVP Implementation](#phase-1-mvp-implementation)
5. [Phase 2: Intelligence Layer](#phase-2-intelligence-layer)
6. [Phase 3: Polish & UX](#phase-3-polish--ux)
7. [Testing Strategy](#testing-strategy)
8. [Deployment](#deployment)

---

## Prerequisites

### Required Tools

```bash
# Flutter SDK (3.16.0 or higher)
flutter --version

# Dart SDK (included with Flutter)
dart --version

# Android Studio or VS Code with Flutter extensions
# Android SDK (API level 21+)
# iOS development tools (Xcode 15+) for iOS support
```

### Required Knowledge

- Dart fundamentals (async/await, streams, futures)
- Flutter widgets and state management
- Basic understanding of Provider or Riverpod
- Platform channels (for native API access)
- Local storage patterns

---

## Project Setup

### 1. Create Flutter Project

```bash
# Navigate to your workspace
cd /home/user/next

# Create new Flutter project
flutter create intentional_friction

# Navigate into project
cd intentional_friction

# Test setup
flutter run
```

### 2. Update `pubspec.yaml`

```yaml
name: intentional_friction
description: A digital wellbeing app that creates self-awareness through thoughtful pauses
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # App Usage Tracking (Android)
  app_usage: ^3.0.0

  # Permissions
  permission_handler: ^11.1.0

  # UI & Animations
  flutter_animate: ^4.3.0
  smooth_page_indicator: ^1.1.0

  # Date & Time
  intl: ^0.19.0

  # Charts & Visualization
  fl_chart: ^0.65.0

  # UUID Generation
  uuid: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7

flutter:
  uses-material-design: true

  # Fonts (add custom fonts here later)
  # fonts:
  #   - family: CustomFont
  #     fonts:
  #       - asset: fonts/CustomFont-Regular.ttf

  # Assets
  # assets:
  #   - assets/images/
  #   - assets/animations/
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Android Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
                     tools:ignore="ProtectedPermissions"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application
        android:label="Intentional Friction"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Rest of your application config -->
    </application>
</manifest>
```

### 5. Create Project Structure

```bash
# Create directory structure
mkdir -p lib/core/models
mkdir -p lib/core/services
mkdir -p lib/core/utils
mkdir -p lib/features/friction_moment/presentation
mkdir -p lib/features/friction_moment/data
mkdir -p lib/features/insights/presentation
mkdir -p lib/features/insights/data
mkdir -p lib/features/settings/presentation
mkdir -p lib/providers
mkdir -p lib/widgets
```

Final structure:
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── models/
│   │   ├── friction_moment.dart
│   │   ├── usage_pattern.dart
│   │   └── insight_data.dart
│   ├── services/
│   │   ├── usage_monitor_service.dart
│   │   ├── friction_decision_engine.dart
│   │   ├── pattern_recognition_service.dart
│   │   └── storage_service.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── features/
│   ├── friction_moment/
│   │   ├── presentation/
│   │   │   ├── friction_screen.dart
│   │   │   └── widgets/
│   │   └── data/
│   │       └── friction_repository.dart
│   ├── insights/
│   │   ├── presentation/
│   │   │   ├── insights_screen.dart
│   │   │   └── widgets/
│   │   └── data/
│   │       └── insights_repository.dart
│   └── settings/
│       └── presentation/
│           └── settings_screen.dart
├── providers/
│   ├── friction_providers.dart
│   ├── usage_providers.dart
│   └── settings_providers.dart
└── widgets/
    ├── breathing_animation.dart
    └── stat_card.dart
```

---

## Architecture Overview

### Architectural Pattern: Clean Architecture + Riverpod

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (Screens, Widgets, View Logic)         │
│      → Uses Riverpod Providers          │
└────────────┬────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────┐
│          Business Logic Layer           │
│  (Services, Decision Engines)           │
│      → Exposed via Providers            │
└────────────┬────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  (Repositories, Storage)                │
│      → Hive for persistence             │
└─────────────────────────────────────────┘
```

### Key Services

1. **UsageMonitorService**: Detects app launches and tracks usage
2. **FrictionDecisionEngine**: Decides when/how to intervene
3. **PatternRecognitionService**: Analyzes patterns and generates insights
4. **StorageService**: Manages Hive database operations

---

## Phase 1: MVP Implementation

### Step 1: Data Models

**`lib/core/models/friction_moment.dart`**:

```dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'friction_moment.g.dart';

@HiveType(typeId: 0)
enum FrictionMode {
  @HiveField(0)
  mirror,
  @HiveField(1)
  question,
  @HiveField(2)
  tradeOff,
  @HiveField(3)
  breath,
  @HiveField(4)
  alternative,
}

@HiveType(typeId: 1)
enum UserChoice {
  @HiveField(0)
  proceeded,
  @HiveField(1)
  closed,
  @HiveField(2)
  choseAlternative,
  @HiveField(3)
  dismissed,
}

@HiveType(typeId: 2)
class FrictionMoment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String targetApp;

  @HiveField(3)
  final FrictionMode mode;

  @HiveField(4)
  final String prompt;

  @HiveField(5)
  final UserChoice? choice;

  @HiveField(6)
  final String? emotionalState;

  @HiveField(7)
  final int displayDurationMs;

  @HiveField(8)
  final Map<String, dynamic>? context;

  FrictionMoment({
    String? id,
    required this.timestamp,
    required this.targetApp,
    required this.mode,
    required this.prompt,
    this.choice,
    this.emotionalState,
    this.displayDurationMs = 0,
    this.context,
  }) : id = id ?? const Uuid().v4();

  FrictionMoment copyWith({
    String? id,
    DateTime? timestamp,
    String? targetApp,
    FrictionMode? mode,
    String? prompt,
    UserChoice? choice,
    String? emotionalState,
    int? displayDurationMs,
    Map<String, dynamic>? context,
  }) {
    return FrictionMoment(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      targetApp: targetApp ?? this.targetApp,
      mode: mode ?? this.mode,
      prompt: prompt ?? this.prompt,
      choice: choice ?? this.choice,
      emotionalState: emotionalState ?? this.emotionalState,
      displayDurationMs: displayDurationMs ?? this.displayDurationMs,
      context: context ?? this.context,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'targetApp': targetApp,
      'mode': mode.name,
      'prompt': prompt,
      'choice': choice?.name,
      'emotionalState': emotionalState,
      'displayDurationMs': displayDurationMs,
      'context': context,
    };
  }
}
```

**Generate Hive adapters**:

```bash
flutter pub run build_runner build
```

### Step 2: Storage Service

**`lib/core/services/storage_service.dart`**:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/friction_moment.dart';

class StorageService {
  static const String _frictionMomentsBox = 'friction_moments';
  static const String _settingsBox = 'settings';

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FrictionModeAdapter());
    Hive.registerAdapter(UserChoiceAdapter());
    Hive.registerAdapter(FrictionMomentAdapter());

    // Open boxes
    await Hive.openBox<FrictionMoment>(_frictionMomentsBox);
    await Hive.openBox(_settingsBox);
  }

  Box<FrictionMoment> get frictionMomentsBox =>
      Hive.box<FrictionMoment>(_frictionMomentsBox);

  Box get settingsBox => Hive.box(_settingsBox);

  // CRUD Operations
  Future<void> saveFrictionMoment(FrictionMoment moment) async {
    await frictionMomentsBox.put(moment.id, moment);
  }

  Future<void> updateFrictionMoment(FrictionMoment moment) async {
    await frictionMomentsBox.put(moment.id, moment);
  }

  List<FrictionMoment> getAllFrictionMoments() {
    return frictionMomentsBox.values.toList();
  }

  List<FrictionMoment> getFrictionMomentsForToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return frictionMomentsBox.values
        .where((moment) => moment.timestamp.isAfter(startOfDay))
        .toList();
  }

  List<FrictionMoment> getFrictionMomentsInRange(
    DateTime start,
    DateTime end,
  ) {
    return frictionMomentsBox.values
        .where((moment) =>
            moment.timestamp.isAfter(start) &&
            moment.timestamp.isBefore(end))
        .toList();
  }

  Future<void> deleteFrictionMoment(String id) async {
    await frictionMomentsBox.delete(id);
  }

  Future<void> deleteAllData() async {
    await frictionMomentsBox.clear();
  }

  // Settings
  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setSetting<T>(String key, T value) async {
    await settingsBox.put(key, value);
  }
}
```

### Step 3: Usage Monitor Service

**`lib/core/services/usage_monitor_service.dart`**:

```dart
import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';

class UsageMonitorService {
  final AppUsage _appUsage = AppUsage();
  String? _lastForegroundApp;
  Timer? _monitorTimer;

  final StreamController<String> _appLaunchController =
      StreamController<String>.broadcast();

  Stream<String> get appLaunchStream => _appLaunchController.stream;

  // Monitored apps (social media, news, etc.)
  final Set<String> _monitoredApps = {
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

  Future<bool> requestPermissions() async {
    // Check if permission is granted
    final status = await Permission.appUsage.status;

    if (status.isGranted) {
      return true;
    }

    // Request permission
    final result = await Permission.appUsage.request();
    return result.isGranted;
  }

  Future<void> startMonitoring() async {
    final hasPermission = await requestPermissions();

    if (!hasPermission) {
      throw Exception('App usage permission not granted');
    }

    // Poll every 2 seconds to detect foreground app changes
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkForegroundApp(),
    );
  }

  Future<void> _checkForegroundApp() async {
    try {
      final now = DateTime.now();
      final endDate = now;
      final startDate = now.subtract(const Duration(seconds: 5));

      final usageInfo = await _appUsage.getAppUsage(startDate, endDate);

      if (usageInfo.isEmpty) return;

      // Find most recently used app
      final recentApp = usageInfo.reduce((a, b) =>
        a.endDate!.isAfter(b.endDate!) ? a : b
      );

      final currentApp = recentApp.packageName;

      // Check if app changed and is a monitored app
      if (currentApp != _lastForegroundApp &&
          _monitoredApps.contains(currentApp)) {
        _lastForegroundApp = currentApp;
        _appLaunchController.add(currentApp);
      }
    } catch (e) {
      print('Error checking foreground app: $e');
    }
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void addMonitoredApp(String packageName) {
    _monitoredApps.add(packageName);
  }

  void removeMonitoredApp(String packageName) {
    _monitoredApps.remove(packageName);
  }

  Set<String> get monitoredApps => Set.unmodifiable(_monitoredApps);

  Future<Map<String, Duration>> getTodayUsage() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final usageInfo = await _appUsage.getAppUsage(startOfDay, now);

      final Map<String, Duration> usageMap = {};
      for (var info in usageInfo) {
        if (_monitoredApps.contains(info.packageName)) {
          usageMap[info.packageName] = Duration(
            milliseconds: info.usage.inMilliseconds,
          );
        }
      }

      return usageMap;
    } catch (e) {
      print('Error getting usage: $e');
      return {};
    }
  }

  void dispose() {
    stopMonitoring();
    _appLaunchController.close();
  }
}
```

### Step 4: Friction Decision Engine (MVP Version)

**`lib/core/services/friction_decision_engine.dart`**:

```dart
import 'dart:math';
import '../models/friction_moment.dart';
import 'storage_service.dart';

class FrictionDecisionEngine {
  final StorageService _storage;
  final Random _random = Random();

  FrictionDecisionEngine(this._storage);

  /// Decides whether to show friction for this app launch
  bool shouldShowFriction(String appPackage) {
    // MVP: Always show friction (100% intervention rate)
    // Phase 2: This becomes intelligent based on patterns

    // Check if user disabled friction
    final frictionEnabled = _storage.getSetting<bool>(
      'friction_enabled',
      defaultValue: true,
    );

    return frictionEnabled ?? true;
  }

  /// Generates appropriate friction moment for this context
  FrictionMoment generateFrictionMoment(String appPackage) {
    // MVP: Use only "question" mode
    final mode = FrictionMode.question;
    final prompt = _generatePrompt(mode, appPackage);

    return FrictionMoment(
      timestamp: DateTime.now(),
      targetApp: appPackage,
      mode: mode,
      prompt: prompt,
      context: {
        'app': appPackage,
        'hour': DateTime.now().hour,
      },
    );
  }

  String _generatePrompt(FrictionMode mode, String appPackage) {
    final appName = _getAppName(appPackage);

    switch (mode) {
      case FrictionMode.question:
        return _generateQuestionPrompt(appName);

      case FrictionMode.mirror:
        return _generateMirrorPrompt(appName);

      case FrictionMode.tradeOff:
        return _generateTradeOffPrompt(appName);

      case FrictionMode.breath:
        return 'Take three deep breaths.\n\nThen choose.';

      case FrictionMode.alternative:
        return _generateAlternativePrompt();
    }
  }

  String _generateQuestionPrompt(String appName) {
    final questions = [
      'Before you open $appName...\n\nWhat are you hoping to find?',
      'Opening $appName...\n\nAre you:\n• Bored?\n• Avoiding something?\n• Seeking connection?\n• Genuinely curious?',
      'Pause for a moment.\n\nWhy $appName right now?',
      'Before scrolling...\n\nWhat do you really need in this moment?',
    ];

    return questions[_random.nextInt(questions.length)];
  }

  String _generateMirrorPrompt(String appName) {
    final todayMoments = _storage.getFrictionMomentsForToday();
    final appOpens = todayMoments
        .where((m) => _getAppName(m.targetApp) == appName)
        .length;

    return "You've opened $appName ${appOpens + 1} times today.\n\nWhat are you hoping to find right now?";
  }

  String _generateTradeOffPrompt(String appName) {
    final tradeOffs = [
      '5 more minutes here =\nOne less chapter tonight\n\nWorth it?',
      'Every scroll is a choice\nto not do something else.\n\nWhat could you do instead?',
      'Time spent here\nis time not spent elsewhere.\n\nChoose wisely.',
    ];

    return tradeOffs[_random.nextInt(tradeOffs.length)];
  }

  String _generateAlternativePrompt() {
    final alternatives = [
      'Instead, you could:\n\n• Message someone you miss\n• Take a 2-minute walk\n• Just sit with the feeling',
      'What if you:\n\n• Stretched for 30 seconds\n• Wrote one sentence\n• Looked out a window',
      'Alternative ideas:\n\n• Call a friend\n• Drink a glass of water\n• Take 5 deep breaths',
    ];

    return alternatives[_random.nextInt(alternatives.length)];
  }

  String _getAppName(String packageName) {
    final Map<String, String> appNames = {
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

    return appNames[packageName] ?? 'this app';
  }
}
```

### Step 5: Riverpod Providers

**`lib/providers/friction_providers.dart`**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../core/services/usage_monitor_service.dart';
import '../core/services/friction_decision_engine.dart';
import '../core/models/friction_moment.dart';

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Usage Monitor Service Provider
final usageMonitorServiceProvider = Provider<UsageMonitorService>((ref) {
  final service = UsageMonitorService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Friction Decision Engine Provider
final frictionDecisionEngineProvider = Provider<FrictionDecisionEngine>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return FrictionDecisionEngine(storage);
});

// Current Friction Moment Provider (state)
final currentFrictionMomentProvider =
    StateProvider<FrictionMoment?>((ref) => null);

// Today's Friction Moments Provider
final todayFrictionMomentsProvider = Provider<List<FrictionMoment>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFrictionMomentsForToday();
});

// Stats Provider
final todayStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final moments = ref.watch(todayFrictionMomentsProvider);

  final total = moments.length;
  final proceeded = moments.where((m) => m.choice == UserChoice.proceeded).length;
  final closed = moments.where((m) => m.choice == UserChoice.closed).length;

  final mindfulnessRate = total > 0 ? (closed / total * 100).round() : 0;

  return {
    'total': total,
    'proceeded': proceeded,
    'closed': closed,
    'mindfulnessRate': mindfulnessRate,
  };
});
```

### Step 6: Friction Screen UI

**`lib/features/friction_moment/presentation/friction_screen.dart`**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/models/friction_moment.dart';
import '../../../providers/friction_providers.dart';

class FrictionScreen extends ConsumerStatefulWidget {
  final FrictionMoment moment;

  const FrictionScreen({
    super.key,
    required this.moment,
  });

  @override
  ConsumerState<FrictionScreen> createState() => _FrictionScreenState();
}

class _FrictionScreenState extends ConsumerState<FrictionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _canDismiss = false;
  final int _minimumWaitSeconds = 3;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Enable dismiss after minimum wait time
    Timer(Duration(seconds: _minimumWaitSeconds), () {
      if (mounted) {
        setState(() => _canDismiss = true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleChoice(UserChoice choice) async {
    final duration = DateTime.now().difference(_startTime);

    final updatedMoment = widget.moment.copyWith(
      choice: choice,
      displayDurationMs: duration.inMilliseconds,
    );

    final storage = ref.read(storageServiceProvider);
    await storage.updateFrictionMoment(updatedMoment);

    if (mounted) {
      Navigator.of(context).pop(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_canDismiss) {
          _handleChoice(UserChoice.dismissed);
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Breathing animation circle
                    _buildBreathingCircle(),

                    const SizedBox(height: 60),

                    // Prompt text
                    Text(
                      widget.moment.prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Action buttons
                    if (_canDismiss) ...[
                      _buildActionButton(
                        label: 'Proceed Anyway',
                        onPressed: () => _handleChoice(UserChoice.proceeded),
                        isPrimary: false,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        label: 'Close',
                        onPressed: () => _handleChoice(UserChoice.closed),
                        isPrimary: true,
                      ),
                    ] else ...[
                      // Wait indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(seconds: _minimumWaitSeconds),
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6C63FF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Take a moment to reflect...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.6),
                  const Color(0xFF6C63FF).withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // Restart animation in reverse for breathing effect
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF6C63FF)
              : Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Colors.white24),
          ),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

### Step 7: Main App Setup

**`lib/main.dart`**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'providers/friction_providers.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const IntentionalFrictionApp(),
    ),
  );
}
```

**`lib/app.dart`**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/home_screen.dart';

class IntentionalFrictionApp extends ConsumerWidget {
  const IntentionalFrictionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Intentional Friction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

### Step 8: Home Screen with Stats

**`lib/features/home/presentation/home_screen.dart`**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/friction_providers.dart';
import '../../../core/services/usage_monitor_service.dart';
import '../../friction_moment/presentation/friction_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMonitoring = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final monitor = ref.read(usageMonitorServiceProvider);
    final hasPermission = await monitor.requestPermissions();

    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
      });
    }
  }

  Future<void> _startMonitoring() async {
    final monitor = ref.read(usageMonitorServiceProvider);
    final engine = ref.read(frictionDecisionEngineProvider);
    final storage = ref.read(storageServiceProvider);

    try {
      await monitor.startMonitoring();

      // Listen for app launches
      monitor.appLaunchStream.listen((appPackage) async {
        // Decide if we should show friction
        if (engine.shouldShowFriction(appPackage)) {
          // Generate friction moment
          final moment = engine.generateFrictionMoment(appPackage);

          // Save to storage
          await storage.saveFrictionMoment(moment);

          // Show friction screen
          if (mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FrictionScreen(moment: moment),
                fullscreenDialog: true,
              ),
            );
          }
        }
      });

      setState(() => _isMonitoring = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _stopMonitoring() {
    final monitor = ref.read(usageMonitorServiceProvider);
    monitor.stopMonitoring();
    setState(() => _isMonitoring = false);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(todayStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intentional Friction'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            _buildStatusCard(),

            const SizedBox(height: 32),

            // Stats
            Text(
              'Today\'s Choices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            _buildStatRow('Friction Moments', stats['total'].toString()),
            _buildStatRow('Proceeded', stats['proceeded'].toString()),
            _buildStatRow('Chose to Close', stats['closed'].toString()),
            _buildStatRow(
              'Mindfulness Rate',
              '${stats['mindfulnessRate']}%',
            ),

            const Spacer(),

            // Control button
            if (!_hasPermission)
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Grant Permissions'),
              )
            else if (!_isMonitoring)
              ElevatedButton(
                onPressed: _startMonitoring,
                child: const Text('Start Monitoring'),
              )
            else
              ElevatedButton(
                onPressed: _stopMonitoring,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Stop Monitoring'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              _isMonitoring ? Icons.shield_outlined : Icons.shield,
              size: 48,
              color: _isMonitoring
                  ? const Color(0xFF6C63FF)
                  : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isMonitoring
                  ? 'Friction will appear when you open monitored apps'
                  : 'Start monitoring to begin your mindful journey',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 9: Run MVP

```bash
# Make sure you're in the project directory
cd intentional_friction

# Get dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run on Android device/emulator
flutter run
```

**Testing the MVP**:
1. Grant usage stats permission when prompted
2. Tap "Start Monitoring"
3. Open Instagram, Twitter, or any monitored app
4. Friction screen should appear after 2-second delay
5. Wait 3 seconds for buttons to appear
6. Choose to proceed or close
7. Return to app to see stats update

---

## Phase 2: Intelligence Layer

*(To be implemented after MVP is validated)*

### Features to Add:

1. **Multiple Friction Modes**: Implement all 5 modes (mirror, question, tradeOff, breath, alternative)
2. **Mode Rotation**: Cycle through modes to prevent habituation
3. **Adaptive Timing**: Adjust friction frequency based on patterns
4. **Emotion Tracking**: Add emotion selection to friction moments
5. **Pattern Recognition**: Analyze when user is most mindless
6. **Weekly Insights**: Generate AI-powered insights about patterns

### Key Implementation:

**Enhanced Friction Decision Engine**:
- Time-of-day analysis
- Frequency analysis (don't show friction every single time)
- Context awareness (location, recent activity)
- Effectiveness tracking (which modes work best)

**Pattern Recognition Service**:
- Machine learning for pattern detection
- Predictive modeling (when will user be mindless next?)
- Insight generation
- Recommendation engine

---

## Phase 3: Polish & UX

*(Final phase before release)*

### Features:

1. **Beautiful Onboarding**: Explain philosophy, set expectations
2. **Custom Animations**: Rive or Lottie animations
3. **Sound Design**: Optional gentle sounds
4. **Settings Screen**: Customize behavior
5. **iOS Support**: Platform-specific implementation
6. **Dark/Light Themes**: User preference
7. **Accessibility**: Screen readers, large text support

---

## Testing Strategy

### Unit Tests

```dart
// test/services/friction_decision_engine_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_friction/core/services/friction_decision_engine.dart';

void main() {
  group('FrictionDecisionEngine', () {
    test('generates question mode prompt', () {
      // Test prompt generation
    });

    test('should show friction when enabled', () {
      // Test decision logic
    });
  });
}
```

### Widget Tests

```dart
// test/features/friction_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_friction/features/friction_moment/presentation/friction_screen.dart';

void main() {
  testWidgets('Friction screen shows prompt', (tester) async {
    // Test UI rendering
  });

  testWidgets('Buttons appear after delay', (tester) async {
    // Test button appearance timing
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete friction flow', (tester) async {
    // Test entire user journey
  });
}
```

---

## Deployment

### Android Release

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### iOS Release

```bash
# Build iOS release
flutter build ios --release
```

### Prepare for Stores

1. **App Icon**: Create in `android/app/src/main/res/` and `ios/Runner/Assets.xcassets/`
2. **Screenshots**: Capture from real devices
3. **Store Listing**:
   - Title: "Intentional Friction"
   - Subtitle: "Mindful technology use"
   - Description: Focus on awareness, not restriction
4. **Privacy Policy**: Emphasize local-first, no tracking

---

## Next Steps

1. **Build MVP** following Phase 1 guide
2. **Test with real users** (friends, family)
3. **Gather feedback**: What moments resonate? What's annoying?
4. **Iterate rapidly**: Adjust friction modes, timing, prompts
5. **Add intelligence** once core concept is validated
6. **Polish** for public release
7. **Launch** and gather more feedback
8. **Build community** around intentional tech use

---

## Troubleshooting

### "App usage permission denied"
- Go to device Settings > Apps > Special access > Usage access
- Enable for Intentional Friction

### "Friction not appearing"
- Check monitoring is active
- Verify app package names in monitored list
- Check device logs: `flutter logs`

### "Hive errors"
- Delete adapters: `flutter pub run build_runner clean`
- Regenerate: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [app_usage Package](https://pub.dev/packages/app_usage)
- [Material Design 3](https://m3.material.io)

---

**Ready to build something meaningful? Start with Phase 1 MVP!**
