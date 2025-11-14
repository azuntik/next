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
    // Check if user disabled friction
    final frictionEnabled = _storage.getSetting<bool>(
      AppConstants.frictionEnabledKey,
      defaultValue: true,
    );

    if (!frictionEnabled!) return false;

    // Phase 2: Adaptive logic based on patterns
    final todayMoments = _storage.getFrictionMomentsForToday();
    final hour = DateTime.now().hour;

    // Get friction intensity setting (default: medium)
    final intensity = _storage.getSetting<String>(
      'friction_intensity',
      defaultValue: 'medium',
    );

    // Calculate intervention rate based on intensity and time
    double interventionRate = _getInterventionRate(intensity!, hour);

    // Check recent friction moments to avoid overwhelming
    final recentMoments = todayMoments.where((m) =>
      m.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 30)))
    ).length;

    // Reduce rate if too many recent frictions
    if (recentMoments >= 3) {
      interventionRate *= 0.5;
    }

    // Higher friction during "zombie hours" (identified from patterns)
    final zombieHours = _getZombieHours();
    if (zombieHours.contains(hour)) {
      interventionRate *= 1.3;
    }

    return _random.nextDouble() < interventionRate;
  }

  /// Gets intervention rate based on intensity setting
  double _getInterventionRate(String intensity, int hour) {
    // Base rates
    final baseRates = {
      'low': 0.3,
      'medium': 0.7,
      'high': 0.95,
    };

    double rate = baseRates[intensity] ?? 0.7;

    // Increase during evening hours (higher mindless scrolling)
    if (hour >= 20 || hour <= 1) {
      rate = (rate * 1.2).clamp(0.0, 1.0);
    }

    return rate;
  }

  /// Identifies "zombie hours" from user patterns
  List<int> _getZombieHours() {
    final allMoments = _storage.getAllFrictionMoments();
    if (allMoments.length < 20) return []; // Need data first

    // Find hours with high "proceeded" rate (mindless behavior)
    final Map<int, Map<String, int>> hourStats = {};

    for (var moment in allMoments) {
      final hour = moment.timestamp.hour;
      hourStats.putIfAbsent(hour, () => {'total': 0, 'proceeded': 0});
      hourStats[hour]!['total'] = hourStats[hour]!['total']! + 1;

      if (moment.choice == UserChoice.proceeded) {
        hourStats[hour]!['proceeded'] = hourStats[hour]!['proceeded']! + 1;
      }
    }

    // Hours where proceeded rate > 70% are "zombie hours"
    final zombieHours = <int>[];
    hourStats.forEach((hour, stats) {
      final total = stats['total']!;
      final proceeded = stats['proceeded']!;

      if (total >= 5 && (proceeded / total) > 0.7) {
        zombieHours.add(hour);
      }
    });

    return zombieHours;
  }

  /// Generates appropriate friction moment for this context
  FrictionMoment generateFrictionMoment(String appPackage) {
    // Phase 2: Rotate through all 5 modes intelligently
    final mode = _selectFrictionMode(appPackage);
    final prompt = _generatePrompt(mode, appPackage);

    return FrictionMoment(
      timestamp: DateTime.now(),
      targetApp: appPackage,
      mode: mode,
      prompt: prompt,
      context: {
        'app': appPackage,
        'hour': DateTime.now().hour,
        'dayOfWeek': DateTime.now().weekday,
      },
    );
  }

  /// Selects which friction mode to use based on patterns
  FrictionMode _selectFrictionMode(String appPackage) {
    final todayMoments = _storage.getFrictionMomentsForToday();
    final recentMoments = _storage.getAllFrictionMoments().take(50).toList();

    // Count recent mode usage to ensure variety
    final modeCounts = <FrictionMode, int>{};
    for (var moment in todayMoments) {
      modeCounts[moment.mode] = (modeCounts[moment.mode] ?? 0) + 1;
    }

    // Get effectiveness scores for each mode
    final effectivenessScores = _getModeEffectiveness(recentMoments);

    // Weight selection by: variety (60%) + effectiveness (40%)
    final modeWeights = <FrictionMode, double>{};

    for (var mode in FrictionMode.values) {
      // Variety score: favor less-used modes
      final usageCount = modeCounts[mode] ?? 0;
      final varietyScore = 1.0 / (usageCount + 1);

      // Effectiveness score
      final effectivenessScore = effectivenessScores[mode] ?? 0.5;

      modeWeights[mode] = (varietyScore * 0.6) + (effectivenessScore * 0.4);
    }

    // Weighted random selection
    return _weightedRandomMode(modeWeights);
  }

  /// Calculates effectiveness of each mode (% times user chose "close")
  Map<FrictionMode, double> _getModeEffectiveness(List<FrictionMoment> moments) {
    final modeStats = <FrictionMode, Map<String, int>>{};

    for (var moment in moments) {
      if (moment.choice == null) continue;

      modeStats.putIfAbsent(
        moment.mode,
        () => {'total': 0, 'closed': 0},
      );

      modeStats[moment.mode]!['total'] = modeStats[moment.mode]!['total']! + 1;

      if (moment.choice == UserChoice.closed) {
        modeStats[moment.mode]!['closed'] = modeStats[moment.mode]!['closed']! + 1;
      }
    }

    final effectiveness = <FrictionMode, double>{};
    modeStats.forEach((mode, stats) {
      final total = stats['total']!;
      final closed = stats['closed']!;
      effectiveness[mode] = total > 0 ? closed / total : 0.5;
    });

    return effectiveness;
  }

  /// Selects mode using weighted random
  FrictionMode _weightedRandomMode(Map<FrictionMode, double> weights) {
    final totalWeight = weights.values.reduce((a, b) => a + b);
    double random = _random.nextDouble() * totalWeight;

    for (var entry in weights.entries) {
      random -= entry.value;
      if (random <= 0) {
        return entry.key;
      }
    }

    return FrictionMode.question; // Fallback
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
