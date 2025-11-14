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
