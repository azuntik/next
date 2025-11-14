import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_friction/core/services/friction_decision_engine.dart';
import 'package:intentional_friction/core/models/friction_moment.dart';
import 'package:intentional_friction/core/services/storage_service.dart';

void main() {
  late FrictionDecisionEngine engine;
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();
    engine = FrictionDecisionEngine(mockStorage);
  });

  group('FrictionDecisionEngine', () {
    test('generates friction moment with all required fields', () {
      final moment = engine.generateFrictionMoment('com.instagram.android');

      expect(moment.id, isNotEmpty);
      expect(moment.targetApp, equals('com.instagram.android'));
      expect(moment.timestamp, isA<DateTime>());
      expect(moment.mode, isA<FrictionMode>());
      expect(moment.prompt, isNotEmpty);
    });

    test('rotates through different friction modes', () {
      final modes = <FrictionMode>{};

      // Generate 20 moments to see variety
      for (int i = 0; i < 20; i++) {
        final moment = engine.generateFrictionMoment('com.instagram.android');
        modes.add(moment.mode);
      }

      // Should use at least 3 different modes in 20 attempts
      expect(modes.length, greaterThanOrEqualTo(3));
    });

    test('should show friction respects intensity setting', () {
      mockStorage.setIntensity('low');

      int showCount = 0;
      for (int i = 0; i < 100; i++) {
        if (engine.shouldShowFriction('com.instagram.android')) {
          showCount++;
        }
      }

      // Low intensity should show friction ~30% of the time
      expect(showCount, greaterThan(10)); // At least 10%
      expect(showCount, lessThan(50)); // But less than 50%
    });

    test('reduces friction when overwhelming user', () {
      // Simulate 3 recent frictions in short time
      mockStorage.addRecentMoments([
        createMoment(minutesAgo: 5),
        createMoment(minutesAgo: 10),
        createMoment(minutesAgo: 15),
      ]);

      mockStorage.setIntensity('high');

      int showCount = 0;
      for (int i = 0; i < 100; i++) {
        if (engine.shouldShowFriction('com.instagram.android')) {
          showCount++;
        }
      }

      // Should show less frequently after recent frictions
      expect(showCount, lessThan(95)); // Less than standard high (95%)
    });

    test('detects zombie hours correctly', () {
      // Add moments with high proceed rate during late night
      mockStorage.addMomentsWithPattern(
        hour: 23,
        proceedRate: 0.8, // 80% proceed rate
        count: 10,
      );

      final zombieHours = engine.getZombieHours();
      expect(zombieHours, contains(23));
    });

    test('increases friction during zombie hours', () {
      mockStorage.addMomentsWithPattern(
        hour: 22,
        proceedRate: 0.9,
        count: 15,
      );
      mockStorage.setIntensity('medium');

      // Mock current hour to be zombie hour
      engine.setTestHour(22);

      int showCount = 0;
      for (int i = 0; i < 100; i++) {
        if (engine.shouldShowFriction('com.instagram.android')) {
          showCount++;
        }
      }

      // Should show more than standard medium (70%) due to zombie hour boost
      expect(showCount, greaterThan(70));
    });

    test('generates appropriate prompts for each mode', () {
      // Test each mode has proper prompts
      for (final mode in FrictionMode.values) {
        final prompt = engine.getPromptForMode(mode, 'Instagram');

        expect(prompt, isNotEmpty);
        expect(prompt, contains('Instagram')); // Should mention the app

        switch (mode) {
          case FrictionMode.mirror:
            expect(prompt.toLowerCase(), anyOf([
              contains('why'),
              contains('hoping'),
              contains('looking'),
            ]));
            break;
          case FrictionMode.question:
            expect(prompt, contains('?')); // Should be a question
            break;
          case FrictionMode.breath:
            expect(prompt.toLowerCase(), anyOf([
              contains('breath'),
              contains('pause'),
              contains('moment'),
            ]));
            break;
          default:
            // Other modes should have relevant prompts
            break;
        }
      }
    });

    test('mode selection favors variety', () {
      // Track mode usage
      final modeUsage = <FrictionMode, int>{};

      for (int i = 0; i < 100; i++) {
        final moment = engine.generateFrictionMoment('com.instagram.android');
        modeUsage[moment.mode] = (modeUsage[moment.mode] ?? 0) + 1;
      }

      // Calculate variance - should be relatively even distribution
      final values = modeUsage.values.toList();
      final mean = values.reduce((a, b) => a + b) / values.length;
      final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;

      // Low variance means more even distribution
      expect(variance, lessThan(200)); // Reasonable variance threshold
    });

    test('mode selection favors effectiveness', () {
      // Mark one mode as highly effective (user often closes)
      mockStorage.setModeEffectiveness(FrictionMode.mirror, effectiveness: 0.8);
      mockStorage.setModeEffectiveness(FrictionMode.question, effectiveness: 0.2);

      final modeUsage = <FrictionMode, int>{};

      for (int i = 0; i < 100; i++) {
        final moment = engine.generateFrictionMoment('com.instagram.android');
        modeUsage[moment.mode] = (modeUsage[moment.mode] ?? 0) + 1;
      }

      // Mirror mode should be used more than question mode
      expect(
        modeUsage[FrictionMode.mirror] ?? 0,
        greaterThan(modeUsage[FrictionMode.question] ?? 0),
      );
    });

    test('handles empty history gracefully', () {
      mockStorage.clearAll();

      // Should not crash with no history
      expect(() => engine.shouldShowFriction('com.instagram.android'), returnsNormally);
      expect(() => engine.generateFrictionMoment('com.instagram.android'), returnsNormally);
      expect(() => engine.getZombieHours(), returnsNormally);
    });
  });

  group('Edge Cases', () {
    test('handles unknown app packages', () {
      final moment = engine.generateFrictionMoment('com.unknown.app');

      expect(moment.targetApp, equals('com.unknown.app'));
      expect(moment.prompt, isNotEmpty);
    });

    test('handles rapid successive calls', () {
      final moments = <FrictionMoment>[];

      for (int i = 0; i < 10; i++) {
        moments.add(engine.generateFrictionMoment('com.instagram.android'));
      }

      // All should have unique IDs
      final ids = moments.map((m) => m.id).toSet();
      expect(ids.length, equals(10));
    });

    test('handles intensity changes mid-session', () {
      mockStorage.setIntensity('low');
      engine.shouldShowFriction('com.instagram.android');

      mockStorage.setIntensity('high');
      engine.shouldShowFriction('com.instagram.android');

      // Should adapt to new intensity without crashing
      expect(true, isTrue);
    });
  });
}

// Mock Storage Service for testing
class MockStorageService extends StorageService {
  String _intensity = 'medium';
  List<FrictionMoment> _moments = [];
  Map<FrictionMode, double> _effectiveness = {};

  void setIntensity(String intensity) {
    _intensity = intensity;
  }

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    if (key == 'friction_intensity') {
      return _intensity as T;
    }
    return defaultValue;
  }

  void addRecentMoments(List<FrictionMoment> moments) {
    _moments.addAll(moments);
  }

  void addMomentsWithPattern({
    required int hour,
    required double proceedRate,
    required int count,
  }) {
    for (int i = 0; i < count; i++) {
      final timestamp = DateTime.now().subtract(Duration(days: i));
      final moment = FrictionMoment(
        id: 'test_$i',
        timestamp: DateTime(timestamp.year, timestamp.month, timestamp.day, hour),
        targetApp: 'test',
        mode: FrictionMode.question,
        prompt: 'test',
        choice: i < (count * proceedRate) ? UserChoice.proceeded : UserChoice.closed,
      );
      _moments.add(moment);
    }
  }

  @override
  List<FrictionMoment> getAllFrictionMoments() {
    return _moments;
  }

  void setModeEffectiveness(FrictionMode mode, {required double effectiveness}) {
    _effectiveness[mode] = effectiveness;
  }

  void clearAll() {
    _moments.clear();
    _effectiveness.clear();
  }
}

FrictionMoment createMoment({required int minutesAgo}) {
  return FrictionMoment(
    id: 'test',
    timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo)),
    targetApp: 'test',
    mode: FrictionMode.question,
    prompt: 'test',
  );
}
