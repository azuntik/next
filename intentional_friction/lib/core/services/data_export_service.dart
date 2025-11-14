import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/friction_moment.dart';
import 'storage_service.dart';

/// Service for exporting and importing user data
class DataExportService {
  final StorageService _storage;

  DataExportService(this._storage);

  /// Export all friction moments as JSON
  Future<File> exportAsJson() async {
    final moments = await _storage.getAllFrictionMoments();

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'totalMoments': moments.length,
      'frictionMoments': moments.map((m) => _momentToJson(m)).toList(),
      'settings': {
        'frictionEnabled': _storage.getSetting<bool>('friction_enabled', defaultValue: true),
        'frictionIntensity': _storage.getSetting<String>('friction_intensity', defaultValue: 'medium'),
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/intentional_friction_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    return file;
  }

  /// Export all friction moments as CSV
  Future<File> exportAsCsv() async {
    final moments = await _storage.getAllFrictionMoments();

    final csv = StringBuffer();
    // CSV Header
    csv.writeln('Date,Time,App,Mode,Choice,Emotional State,Duration (ms)');

    // CSV Rows
    for (final moment in moments) {
      final date = _formatDate(moment.timestamp);
      final time = _formatTime(moment.timestamp);
      final app = _escapeC sv(moment.targetApp);
      final mode = moment.mode.toString().split('.').last;
      final choice = moment.choice?.toString().split('.').last ?? 'no_choice';
      final emotion = moment.emotionalState ?? '';
      final duration = moment.displayDurationMs;

      csv.writeln('$date,$time,$app,$mode,$choice,$emotion,$duration');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/intentional_friction_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());

    return file;
  }

  /// Share export file via system share sheet
  Future<void> shareExport(File file, {String? mimeType}) async {
    final xFile = XFile(file.path, mimeType: mimeType);
    await Share.shareXFiles(
      [xFile],
      subject: 'Intentional Friction Data Export',
      text: 'My friction moments data from Intentional Friction app',
    );
  }

  /// Import data from JSON file
  Future<ImportResult> importFromJson(File file) async {
    try {
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate format
      if (!data.containsKey('version') || !data.containsKey('frictionMoments')) {
        return ImportResult(
          success: false,
          message: 'Invalid export file format',
        );
      }

      // Import friction moments
      final momentsData = data['frictionMoments'] as List;
      int imported = 0;
      int skipped = 0;

      for (final momentData in momentsData) {
        try {
          final moment = _momentFromJson(momentData as Map<String, dynamic>);
          await _storage.saveFrictionMoment(moment);
          imported++;
        } catch (e) {
          skipped++;
        }
      }

      // Import settings (optional)
      if (data.containsKey('settings')) {
        final settings = data['settings'] as Map<String, dynamic>;
        if (settings.containsKey('frictionEnabled')) {
          _storage.setSetting('friction_enabled', settings['frictionEnabled']);
        }
        if (settings.containsKey('frictionIntensity')) {
          _storage.setSetting('friction_intensity', settings['frictionIntensity']);
        }
      }

      return ImportResult(
        success: true,
        message: 'Imported $imported moments${skipped > 0 ? ", skipped $skipped duplicates" : ""}',
        importedCount: imported,
        skippedCount: skipped,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Error importing data: $e',
      );
    }
  }

  /// Get export statistics
  Future<ExportStats> getExportStats() async {
    final moments = await _storage.getAllFrictionMoments();

    if (moments.isEmpty) {
      return ExportStats(
        totalMoments: 0,
        dateRange: 'No data',
        estimatedFileSize: '0 KB',
      );
    }

    moments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final oldest = moments.first.timestamp;
    final newest = moments.last.timestamp;

    final jsonSize = (moments.length * 500).toDouble(); // Rough estimate: 500 bytes per moment

    return ExportStats(
      totalMoments: moments.length,
      dateRange: '${_formatDate(oldest)} to ${_formatDate(newest)}',
      estimatedFileSize: _formatBytes(jsonSize),
    );
  }

  // Helper methods
  Map<String, dynamic> _momentToJson(FrictionMoment moment) {
    return {
      'id': moment.id,
      'timestamp': moment.timestamp.toIso8601String(),
      'targetApp': moment.targetApp,
      'mode': moment.mode.toString(),
      'prompt': moment.prompt,
      'choice': moment.choice?.toString(),
      'emotionalState': moment.emotionalState,
      'displayDurationMs': moment.displayDurationMs,
      'context': moment.context,
    };
  }

  FrictionMoment _momentFromJson(Map<String, dynamic> json) {
    return FrictionMoment(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      targetApp: json['targetApp'] as String,
      mode: _parseFrictionMode(json['mode'] as String),
      prompt: json['prompt'] as String,
      choice: json['choice'] != null ? _parseUserChoice(json['choice'] as String) : null,
      emotionalState: json['emotionalState'] as String?,
      displayDurationMs: json['displayDurationMs'] as int,
      context: json['context'] as Map<String, dynamic>?,
    );
  }

  FrictionMode _parseFrictionMode(String mode) {
    switch (mode.split('.').last) {
      case 'mirror':
        return FrictionMode.mirror;
      case 'question':
        return FrictionMode.question;
      case 'tradeOff':
        return FrictionMode.tradeOff;
      case 'breath':
        return FrictionMode.breath;
      case 'alternative':
        return FrictionMode.alternative;
      default:
        return FrictionMode.question;
    }
  }

  UserChoice _parseUserChoice(String choice) {
    switch (choice.split('.').last) {
      case 'proceeded':
        return UserChoice.proceeded;
      case 'closed':
        return UserChoice.closed;
      case 'timeout':
        return UserChoice.timeout;
      default:
        return UserChoice.proceeded;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Result of data import operation
class ImportResult {
  final bool success;
  final String message;
  final int importedCount;
  final int skippedCount;

  ImportResult({
    required this.success,
    required this.message,
    this.importedCount = 0,
    this.skippedCount = 0,
  });
}

/// Statistics about exportable data
class ExportStats {
  final int totalMoments;
  final String dateRange;
  final String estimatedFileSize;

  ExportStats({
    required this.totalMoments,
    required this.dateRange,
    required this.estimatedFileSize,
  });
}
