import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';
import '../core/services/usage_monitor_service.dart';
import '../core/services/friction_decision_engine.dart';
import '../core/models/friction_moment.dart';

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
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

// Monitoring state provider
final isMonitoringProvider = StateProvider<bool>((ref) => false);
