import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:intentional_friction/core/services/data_export_service.dart';
import 'package:intentional_friction/core/services/storage_service.dart';
import 'package:intentional_friction/core/models/friction_moment.dart';

void main() {
  late DataExportService exportService;
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();
    exportService = DataExportService(mockStorage);
  });

  group('Data Export', () {
    test('exports data as JSON with correct structure', () async {
      mockStorage.addMoments([
        createTestMoment(id: '1', app: 'Instagram'),
        createTestMoment(id: '2', app: 'Facebook'),
      ]);

      final file = await exportService.exportAsJson();
      final content = await file.readAsString();
      final data = jsonDecode(content);

      expect(data['version'], equals('1.0'));
      expect(data['exportDate'], isA<String>());
      expect(data['totalMoments'], equals(2));
      expect(data['frictionMoments'], isA<List>());
      expect(data['frictionMoments'].length, equals(2));
      expect(data['settings'], isA<Map>());
    });

    test('exports all friction moment fields correctly', () async {
      final moment = FrictionMoment(
        id: 'test123',
        timestamp: DateTime(2025, 11, 14, 10, 30),
        targetApp: 'com.instagram.android',
        mode: FrictionMode.mirror,
        prompt: 'Test prompt',
        choice: UserChoice.closed,
        emotionalState: 'Bored',
        displayDurationMs: 5000,
        context: {'test': 'value'},
      );

      mockStorage.addMoments([moment]);

      final file = await exportService.exportAsJson();
      final content = await file.readAsString();
      final data = jsonDecode(content);
      final exported = data['frictionMoments'][0];

      expect(exported['id'], equals('test123'));
      expect(exported['targetApp'], equals('com.instagram.android'));
      expect(exported['mode'], contains('mirror'));
      expect(exported['prompt'], equals('Test prompt'));
      expect(exported['choice'], contains('closed'));
      expect(exported['emotionalState'], equals('Bored'));
      expect(exported['displayDurationMs'], equals(5000));
      expect(exported['context'], isA<Map>());
    });

    test('exports data as CSV with correct format', () async {
      mockStorage.addMoments([
        createTestMoment(
          id: '1',
          app: 'Instagram',
          choice: UserChoice.closed,
        ),
        createTestMoment(
          id: '2',
          app: 'Facebook',
          choice: UserChoice.proceeded,
        ),
      ]);

      final file = await exportService.exportAsCsv();
      final content = await file.readAsString();
      final lines = content.split('\n');

      // Check header
      expect(lines[0], contains('Date'));
      expect(lines[0], contains('Time'));
      expect(lines[0], contains('App'));
      expect(lines[0], contains('Mode'));
      expect(lines[0], contains('Choice'));

      // Check data rows
      expect(lines.length, greaterThanOrEqualTo(3)); // Header + 2 rows
      expect(lines[1], contains('Instagram'));
      expect(lines[2], contains('Facebook'));
    });

    test('CSV escapes special characters correctly', () async {
      mockStorage.addMoments([
        createTestMoment(
          id: '1',
          app: 'App,With,Commas',
        ),
        createTestMoment(
          id: '2',
          app: 'App"With"Quotes',
        ),
      ]);

      final file = await exportService.exportAsCsv();
      final content = await file.readAsString();

      // Values with commas or quotes should be quoted and escaped
      expect(content, contains('"App,With,Commas"'));
      expect(content, contains('App""With""Quotes'));
    });

    test('handles empty data gracefully', () async {
      mockStorage.clearAll();

      final file = await exportService.exportAsJson();
      final content = await file.readAsString();
      final data = jsonDecode(content);

      expect(data['totalMoments'], equals(0));
      expect(data['frictionMoments'], isEmpty);
    });

    test('includes settings in export', () async {
      mockStorage.setSetting('friction_enabled', true);
      mockStorage.setSetting('friction_intensity', 'high');

      final file = await exportService.exportAsJson();
      final content = await file.readAsString();
      final data = jsonDecode(content);

      expect(data['settings']['frictionEnabled'], isTrue);
      expect(data['settings']['frictionIntensity'], equals('high'));
    });
  });

  group('Data Import', () {
    test('imports valid JSON data correctly', () async {
      final jsonData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalMoments': 2,
        'frictionMoments': [
          {
            'id': 'import1',
            'timestamp': DateTime.now().toIso8601String(),
            'targetApp': 'Instagram',
            'mode': 'FrictionMode.mirror',
            'prompt': 'Test prompt',
            'choice': 'UserChoice.closed',
            'emotionalState': 'Curious',
            'displayDurationMs': 3000,
          },
          {
            'id': 'import2',
            'timestamp': DateTime.now().toIso8601String(),
            'targetApp': 'Facebook',
            'mode': 'FrictionMode.question',
            'prompt': 'Another prompt',
            'displayDurationMs': 5000,
          },
        ],
        'settings': {
          'frictionEnabled': true,
          'frictionIntensity': 'medium',
        },
      };

      final file = File('test_import.json');
      await file.writeAsString(jsonEncode(jsonData));

      final result = await exportService.importFromJson(file);

      expect(result.success, isTrue);
      expect(result.importedCount, equals(2));
      expect(mockStorage.getAllFrictionMoments().length, equals(2));

      await file.delete();
    });

    test('rejects invalid JSON format', () async {
      final invalidData = {
        'notTheRightFormat': true,
      };

      final file = File('test_invalid.json');
      await file.writeAsString(jsonEncode(invalidData));

      final result = await exportService.importFromJson(file);

      expect(result.success, isFalse);
      expect(result.message, contains('Invalid'));

      await file.delete();
    });

    test('handles corrupted JSON gracefully', () async {
      final file = File('test_corrupted.json');
      await file.writeAsString('{ not valid json');

      final result = await exportService.importFromJson(file);

      expect(result.success, isFalse);
      expect(result.message, contains('Error'));

      await file.delete();
    });

    test('skips duplicate moments during import', () async {
      // Add existing moment
      mockStorage.addMoments([
        createTestMoment(id: 'duplicate', app: 'Instagram'),
      ]);

      final jsonData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalMoments': 2,
        'frictionMoments': [
          {
            'id': 'duplicate', // Same ID as existing
            'timestamp': DateTime.now().toIso8601String(),
            'targetApp': 'Instagram',
            'mode': 'FrictionMode.mirror',
            'prompt': 'Test',
            'displayDurationMs': 3000,
          },
          {
            'id': 'new',
            'timestamp': DateTime.now().toIso8601String(),
            'targetApp': 'Facebook',
            'mode': 'FrictionMode.question',
            'prompt': 'Test',
            'displayDurationMs': 3000,
          },
        ],
      };

      final file = File('test_duplicates.json');
      await file.writeAsString(jsonEncode(jsonData));

      final result = await exportService.importFromJson(file);

      expect(result.success, isTrue);
      expect(result.importedCount, equals(1)); // Only new one
      expect(result.skippedCount, greaterThan(0)); // Duplicate skipped

      await file.delete();
    });

    test('imports settings correctly', () async {
      final jsonData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalMoments': 0,
        'frictionMoments': [],
        'settings': {
          'frictionEnabled': false,
          'frictionIntensity': 'low',
        },
      };

      final file = File('test_settings.json');
      await file.writeAsString(jsonEncode(jsonData));

      await exportService.importFromJson(file);

      expect(mockStorage.getSetting<bool>('friction_enabled'), isFalse);
      expect(mockStorage.getSetting<String>('friction_intensity'), equals('low'));

      await file.delete();
    });
  });

  group('Export Statistics', () {
    test('calculates statistics correctly', () async {
      final oldDate = DateTime(2025, 10, 1);
      final newDate = DateTime(2025, 11, 14);

      mockStorage.addMoments([
        createTestMoment(id: '1', timestamp: oldDate),
        createTestMoment(id: '2'),
        createTestMoment(id: '3', timestamp: newDate),
      ]);

      final stats = await exportService.getExportStats();

      expect(stats.totalMoments, equals(3));
      expect(stats.dateRange, contains('2025-10-01'));
      expect(stats.dateRange, contains('2025-11-14'));
      expect(stats.estimatedFileSize, isNotEmpty);
    });

    test('handles empty data in statistics', () async {
      mockStorage.clearAll();

      final stats = await exportService.getExportStats();

      expect(stats.totalMoments, equals(0));
      expect(stats.dateRange, equals('No data'));
      expect(stats.estimatedFileSize, equals('0 KB'));
    });

    test('estimates file size reasonably', () async {
      // Add many moments
      for (int i = 0; i < 100; i++) {
        mockStorage.addMoments([createTestMoment(id: '$i')]);
      }

      final stats = await exportService.getExportStats();

      // Should estimate size
      expect(stats.estimatedFileSize, isNot(equals('0 KB')));
      expect(stats.estimatedFileSize, contains(RegExp(r'\d+')));
    });
  });

  group('File Handling', () {
    test('creates files with unique names', () async {
      mockStorage.addMoments([createTestMoment(id: '1')]);

      final file1 = await exportService.exportAsJson();
      await Future.delayed(const Duration(milliseconds: 10));
      final file2 = await exportService.exportAsJson();

      expect(file1.path, isNot(equals(file2.path)));

      await file1.delete();
      await file2.delete();
    });

    test('files are created in temp directory', () async {
      mockStorage.addMoments([createTestMoment(id: '1')]);

      final file = await exportService.exportAsJson();

      expect(file.path, contains('intentional_friction_export'));
      expect(await file.exists(), isTrue);

      await file.delete();
    });
  });
}

// Helper functions and mock classes
class MockStorageService extends StorageService {
  final List<FrictionMoment> _moments = [];
  final Map<String, dynamic> _settings = {};

  void addMoments(List<FrictionMoment> moments) {
    _moments.addAll(moments);
  }

  @override
  Future<void> saveFrictionMoment(FrictionMoment moment) async {
    // Check for duplicates
    if (!_moments.any((m) => m.id == moment.id)) {
      _moments.add(moment);
    }
  }

  @override
  List<FrictionMoment> getAllFrictionMoments() {
    return List.from(_moments);
  }

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    return (_settings[key] as T?) ?? defaultValue;
  }

  @override
  void setSetting<T>(String key, T value) {
    _settings[key] = value;
  }

  void clearAll() {
    _moments.clear();
    _settings.clear();
  }
}

FrictionMoment createTestMoment({
  required String id,
  String? app,
  DateTime? timestamp,
  UserChoice? choice,
}) {
  return FrictionMoment(
    id: id,
    timestamp: timestamp ?? DateTime.now(),
    targetApp: app ?? 'test',
    mode: FrictionMode.question,
    prompt: 'Test prompt',
    choice: choice,
    displayDurationMs: 3000,
  );
}
