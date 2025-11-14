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
