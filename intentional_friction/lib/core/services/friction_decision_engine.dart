import 'dart:math';
import '../models/friction_moment.dart';
import '../utils/constants.dart';
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
      AppConstants.frictionEnabledKey,
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
    return AppConstants.appNamesMap[packageName] ?? 'this app';
  }
}
