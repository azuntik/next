import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'core/utils/constants.dart';
import 'providers/friction_providers.dart';

class IntentionalFrictionApp extends ConsumerStatefulWidget {
  const IntentionalFrictionApp({super.key});

  @override
  ConsumerState<IntentionalFrictionApp> createState() => _IntentionalFrictionAppState();
}

class _IntentionalFrictionAppState extends ConsumerState<IntentionalFrictionApp> {
  bool _checkingOnboarding = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
