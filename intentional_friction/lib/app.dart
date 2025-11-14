import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/friction_moment/presentation/friction_screen.dart';
import 'core/utils/constants.dart';
import 'core/services/shortcuts_service.dart';
import 'providers/friction_providers.dart';

class IntentionalFrictionApp extends ConsumerStatefulWidget {
  const IntentionalFrictionApp({super.key});

  @override
  ConsumerState<IntentionalFrictionApp> createState() => _IntentionalFrictionAppState();
}

class _IntentionalFrictionAppState extends ConsumerState<IntentionalFrictionApp> {
  bool _checkingOnboarding = true;
  bool _onboardingCompleted = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _initializeShortcuts();
  }

  Future<void> _checkOnboardingStatus() async {
    final storage = ref.read(storageServiceProvider);
    final completed = storage.getSetting<bool>(
      AppConstants.onboardingCompletedKey,
      defaultValue: false,
    );

    setState(() {
      _onboardingCompleted = completed ?? false;
      _checkingOnboarding = false;
    });
  }

  Future<void> _initializeShortcuts() async {
    if (!Platform.isIOS) return;

    // Initialize shortcuts service to listen for iOS shortcuts/intents
    await ShortcutsService.instance.initialize(_handleShortcutFriction);
  }

  Future<void> _handleShortcutFriction(String appName) async {
    // Generate and show friction moment from iOS shortcut trigger
    final engine = ref.read(frictionDecisionEngineProvider);
    final storage = ref.read(storageServiceProvider);

    final moment = engine.generateFrictionMoment(appName);
    await storage.saveFrictionMoment(moment);

    // Navigate to friction screen
    if (_navigatorKey.currentContext != null) {
      Navigator.of(_navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => FrictionScreen(moment: moment),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Intentional Friction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColorValue),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _checkingOnboarding
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _onboardingCompleted
              ? const HomeScreen()
              : const OnboardingScreen(),
    );
  }
}
