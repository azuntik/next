import '../models/friction_moment.dart';
import 'storage_service.dart';

/// Insight data model
class InsightData {
  final String id;
  final String type;
  final String message;
  final DateTime generated;
  final Map<String, dynamic> supportingData;
  final List<String> recommendations;

  InsightData({
    required this.id,
    required this.type,
    required this.message,
    required this.generated,
    required this.supportingData,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'generated': generated.toIso8601String(),
      'supportingData': supportingData,
      'recommendations': recommendations,
    };
  }
}

/// Pattern recognition and insights generation service
class PatternRecognitionService {
  final StorageService _storage;

  PatternRecognitionService(this._storage);

  /// Generates comprehensive insights from user patterns
  List<InsightData> generateWeeklyInsights() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final moments = _storage.getFrictionMomentsInRange(weekAgo, now);

    if (moments.isEmpty || moments.length < 10) {
      return [];
    }

    final insights = <InsightData>[];

    // Generate different types of insights
    insights.addAll(_analyzeEmotionalTriggers(moments));
    insights.addAll(_analyzeTimePatterns(moments));
    insights.addAll(_analyzeMindfulnessProgress(moments));
    insights.addAll(_analyzeAppSpecificPatterns(moments));
    insights.addAll(_analyzeBehaviorChanges(moments));

    return insights;
  }

  /// Identifies emotional triggers for mindless scrolling
  List<InsightData> _analyzeEmotionalTriggers(List<FrictionMoment> moments) {
    final insights = <InsightData>[];

    // Count emotions
    final emotionCounts = <String, Map<String, int>>{};
    for (var moment in moments) {
      if (moment.emotionalState == null) continue;

      emotionCounts.putIfAbsent(
        moment.emotionalState!,
        () => {'total': 0, 'proceeded': 0},
      );

      emotionCounts[moment.emotionalState!]!['total'] =
          emotionCounts[moment.emotionalState!]!['total']! + 1;

      if (moment.choice == UserChoice.proceeded) {
        emotionCounts[moment.emotionalState!]!['proceeded'] =
            emotionCounts[moment.emotionalState!]!['proceeded']! + 1;
      }
    }

    // Find dominant emotion with high proceed rate
    String? dominantEmotion;
    int maxCount = 0;
    double highestProceedRate = 0.0;

    emotionCounts.forEach((emotion, stats) {
      final count = stats['total']!;
      final proceeded = stats['proceeded']!;
      final proceedRate = count > 0 ? proceeded / count : 0.0;

      if (count > maxCount && proceedRate > 0.6) {
        maxCount = count;
        dominantEmotion = emotion;
        highestProceedRate = proceedRate;
      }
    });

    if (dominantEmotion != null && maxCount >= 5) {
      insights.add(
        InsightData(
          id: 'emotional_trigger_${DateTime.now().millisecondsSinceEpoch}',
          type: 'emotional_trigger',
          message:
              'You open apps most when you\'re "$dominantEmotion" (${(highestProceedRate * 100).round()}% of opens).',
          generated: DateTime.now(),
          supportingData: {
            'emotion': dominantEmotion,
            'count': maxCount,
            'proceedRate': highestProceedRate,
          },
          recommendations: _getEmotionRecommendations(dominantEmotion),
        ),
      );
    }

    return insights;
  }

  /// Analyzes time-based patterns
  List<InsightData> _analyzeTimePatterns(List<FrictionMoment> moments) {
    final insights = <InsightData>[];

    // Group by hour
    final hourCounts = <int, int>{};
    for (var moment in moments) {
      final hour = moment.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Find peak hours
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedHours.isNotEmpty) {
      final peakHour = sortedHours.first.key;
      final peakCount = sortedHours.first.value;

      if (peakCount >= 5) {
        final timeLabel = _getTimeLabel(peakHour);
        insights.add(
          InsightData(
            id: 'time_pattern_${DateTime.now().millisecondsSinceEpoch}',
            type: 'time_pattern',
            message:
                'Your peak scrolling time is $timeLabel ($peakCount opens this week).',
            generated: DateTime.now(),
            supportingData: {
              'peakHour': peakHour,
              'peakCount': peakCount,
            },
            recommendations: _getTimeRecommendations(peakHour),
          ),
        );
      }
    }

    return insights;
  }

  /// Analyzes mindfulness progress over time
  List<InsightData> _analyzeMindfulnessProgress(List<FrictionMoment> moments) {
    final insights = <InsightData>[];

    // Split into first half and second half of week
    final midpoint = moments.length ~/ 2;
    final firstHalf = moments.sublist(0, midpoint);
    final secondHalf = moments.sublist(midpoint);

    final firstRate = _calculateMindfulnessRate(firstHalf);
    final secondRate = _calculateMindfulnessRate(secondHalf);

    final improvement = secondRate - firstRate;

    if (improvement.abs() > 0.1) {
      // 10% change
      if (improvement > 0) {
        insights.add(
          InsightData(
            id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
            type: 'progress',
            message:
                'Nice! Your mindfulness improved ${(improvement * 100).round()}% this week.',
            generated: DateTime.now(),
            supportingData: {
              'firstRate': firstRate,
              'secondRate': secondRate,
              'improvement': improvement,
            },
            recommendations: [
              'Keep up the great work!',
              'You\'re building awareness muscle',
            ],
          ),
        );
      } else {
        insights.add(
          InsightData(
            id: 'regression_${DateTime.now().millisecondsSinceEpoch}',
            type: 'regression',
            message:
                'Your mindfulness dipped ${(improvement.abs() * 100).round()}% this week. That\'s okay!',
            generated: DateTime.now(),
            supportingData: {
              'firstRate': firstRate,
              'secondRate': secondRate,
              'change': improvement,
            },
            recommendations: [
              'Progress isn\'t linear',
              'Try increasing friction intensity in settings',
              'Reflect on what changed this week',
            ],
          ),
        );
      }
    }

    return insights;
  }

  /// Analyzes app-specific patterns
  List<InsightData> _analyzeAppSpecificPatterns(List<FrictionMoment> moments) {
    final insights = <InsightData>[];

    // Group by app
    final appStats = <String, Map<String, int>>{};
    for (var moment in moments) {
      appStats.putIfAbsent(
        moment.targetApp,
        () => {'total': 0, 'closed': 0},
      );

      appStats[moment.targetApp]!['total'] =
          appStats[moment.targetApp]!['total']! + 1;

      if (moment.choice == UserChoice.closed) {
        appStats[moment.targetApp]!['closed'] =
            appStats[moment.targetApp]!['closed']! + 1;
      }
    }

    // Find app with highest mindfulness rate
    String? bestApp;
    double highestRate = 0.0;
    int bestCount = 0;

    appStats.forEach((app, stats) {
      final total = stats['total']!;
      final closed = stats['closed']!;
      final rate = total > 0 ? closed / total : 0.0;

      if (total >= 5 && rate > highestRate) {
        bestApp = app;
        highestRate = rate;
        bestCount = closed;
      }
    });

    if (bestApp != null && highestRate > 0.7) {
      insights.add(
        InsightData(
          id: 'app_mindfulness_${DateTime.now().millisecondsSinceEpoch}',
          type: 'app_specific',
          message:
              'You\'re ${(highestRate * 100).round()}% mindful with $bestApp. Strong discipline!',
          generated: DateTime.now(),
          supportingData: {
            'app': bestApp,
            'rate': highestRate,
            'count': bestCount,
          },
          recommendations: [
            'Try applying this awareness to other apps',
          ],
        ),
      );
    }

    return insights;
  }

  /// Analyzes behavior changes
  List<InsightData> _analyzeBehaviorChanges(List<FrictionMoment> moments) {
    final insights = <InsightData>[];

    // Compare weekdays vs weekends
    final weekdayMoments =
        moments.where((m) => m.timestamp.weekday <= 5).toList();
    final weekendMoments =
        moments.where((m) => m.timestamp.weekday > 5).toList();

    if (weekdayMoments.length >= 5 && weekendMoments.length >= 5) {
      final weekdayRate = _calculateMindfulnessRate(weekdayMoments);
      final weekendRate = _calculateMindfulnessRate(weekendMoments);

      final diff = (weekendRate - weekdayRate).abs();

      if (diff > 0.2) {
        final better = weekendRate > weekdayRate ? 'weekends' : 'weekdays';
        final worse = weekendRate > weekdayRate ? 'weekdays' : 'weekends';

        insights.add(
          InsightData(
            id: 'weekday_pattern_${DateTime.now().millisecondsSinceEpoch}',
            type: 'behavior_change',
            message:
                'You\'re more mindful on $better than $worse (${(diff * 100).round()}% difference).',
            generated: DateTime.now(),
            supportingData: {
              'weekdayRate': weekdayRate,
              'weekendRate': weekendRate,
              'difference': diff,
            },
            recommendations: [
              'Reflect on what\'s different about $worse',
              'Maybe you need different strategies for different contexts',
            ],
          ),
        );
      }
    }

    return insights;
  }

  /// Calculate mindfulness rate for a set of moments
  double _calculateMindfulnessRate(List<FrictionMoment> moments) {
    if (moments.isEmpty) return 0.0;

    final closedCount =
        moments.where((m) => m.choice == UserChoice.closed).length;
    return closedCount / moments.length;
  }

  /// Get time-based label
  String _getTimeLabel(int hour) {
    if (hour >= 22 || hour <= 4) return 'late night (${hour}:00)';
    if (hour >= 5 && hour <= 8) return 'early morning (${hour}:00)';
    if (hour >= 9 && hour <= 12) return 'mid-morning (${hour}:00)';
    if (hour >= 13 && hour <= 17) return 'afternoon (${hour}:00)';
    return 'evening (${hour}:00)';
  }

  /// Get recommendations based on emotion
  List<String> _getEmotionRecommendations(String emotion) {
    final recommendations = <String, List<String>>{
      'Bored': [
        'Try the Pomodoro technique to stay engaged',
        'Keep a list of quick, engaging activities',
        'Call a friend when boredom hits',
      ],
      'Anxious': [
        'Practice box breathing (4-4-4-4)',
        'Journal your anxious thoughts instead',
        'Try a 5-minute meditation',
      ],
      'Avoiding': [
        'Break big tasks into tiny steps',
        'Use the 2-minute rule: just start for 2 minutes',
        'Ask yourself: what am I actually avoiding?',
      ],
      'Lonely': [
        'Send a text to someone you care about',
        'Join an online community around your interests',
        'Schedule regular video calls',
      ],
      'Tired': [
        'Take a power nap instead of scrolling',
        'Go to bed earlier tonight',
        'Get some sunlight or fresh air',
      ],
    };

    return recommendations[emotion] ??
        [
          'Notice this pattern and experiment with alternatives',
        ];
  }

  /// Get recommendations based on time
  List<String> _getTimeRecommendations(int hour) {
    if (hour >= 22 || hour <= 4) {
      return [
        'Use a blue light filter after 9pm',
        'Set a "digital sunset" time',
        'Try reading a book instead',
      ];
    } else if (hour >= 13 && hour <= 17) {
      return [
        'This is your afternoon slump - take a walk instead',
        'Use this time for focused work, not scrolling',
      ];
    }

    return [
      'Set a specific "no social media" rule for this time',
      'Plan an alternative activity',
    ];
  }

  /// Get current mindfulness trend
  Map<String, dynamic> getMindfulnessTrend() {
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final moments = _storage.getFrictionMomentsInRange(last30Days, DateTime.now());

    if (moments.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'rate': 0.0,
      };
    }

    // Group by week
    final weeklyRates = <int, List<FrictionMoment>>{};
    for (var moment in moments) {
      final weekNumber =
          moment.timestamp.difference(last30Days).inDays ~/ 7;
      weeklyRates.putIfAbsent(weekNumber, () => []);
      weeklyRates[weekNumber]!.add(moment);
    }

    final rates = <double>[];
    weeklyRates.values.forEach((weekMoments) {
      rates.add(_calculateMindfulnessRate(weekMoments));
    });

    if (rates.length < 2) {
      return {
        'trend': 'insufficient_data',
        'rate': rates.isEmpty ? 0.0 : rates.first,
      };
    }

    // Calculate trend (simple linear regression)
    final avgChange = (rates.last - rates.first) / rates.length;

    return {
      'trend': avgChange > 0.05 ? 'improving' :
               avgChange < -0.05 ? 'declining' : 'stable',
      'rate': rates.last,
      'change': avgChange,
      'weeklyRates': rates,
    };
  }
}
