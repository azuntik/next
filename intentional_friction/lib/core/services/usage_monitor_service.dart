import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class UsageMonitorService {
  final AppUsage _appUsage = AppUsage();
  String? _lastForegroundApp;
  Timer? _monitorTimer;

  final StreamController<String> _appLaunchController =
      StreamController<String>.broadcast();

  Stream<String> get appLaunchStream => _appLaunchController.stream;

  // Monitored apps (social media, news, etc.)
  final Set<String> _monitoredApps = Set.from(AppConstants.defaultMonitoredApps);

  Future<bool> requestPermissions() async {
    // Check if permission is granted
    final status = await Permission.appUsage.status;

    if (status.isGranted) {
      return true;
    }

    // Request permission
    final result = await Permission.appUsage.request();
    return result.isGranted;
  }

  Future<void> startMonitoring() async {
    final hasPermission = await requestPermissions();

    if (!hasPermission) {
      throw Exception('App usage permission not granted');
    }

    // Poll every 2 seconds to detect foreground app changes
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkForegroundApp(),
    );
  }

  Future<void> _checkForegroundApp() async {
    try {
      final now = DateTime.now();
      final endDate = now;
      final startDate = now.subtract(const Duration(seconds: 5));

      final usageInfo = await _appUsage.getAppUsage(startDate, endDate);

      if (usageInfo.isEmpty) return;

      // Find most recently used app
      final recentApp = usageInfo.reduce((a, b) =>
        a.endDate!.isAfter(b.endDate!) ? a : b
      );

      final currentApp = recentApp.packageName;

      // Check if app changed and is a monitored app
      if (currentApp != _lastForegroundApp &&
          _monitoredApps.contains(currentApp)) {
        _lastForegroundApp = currentApp;
        _appLaunchController.add(currentApp);
      }
    } catch (e) {
      print('Error checking foreground app: $e');
    }
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void addMonitoredApp(String packageName) {
    _monitoredApps.add(packageName);
  }

  void removeMonitoredApp(String packageName) {
    _monitoredApps.remove(packageName);
  }

  Set<String> get monitoredApps => Set.unmodifiable(_monitoredApps);

  Future<Map<String, Duration>> getTodayUsage() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final usageInfo = await _appUsage.getAppUsage(startOfDay, now);

      final Map<String, Duration> usageMap = {};
      for (var info in usageInfo) {
        if (_monitoredApps.contains(info.packageName)) {
          usageMap[info.packageName] = Duration(
            milliseconds: info.usage.inMilliseconds,
          );
        }
      }

      return usageMap;
    } catch (e) {
      print('Error getting usage: $e');
      return {};
    }
  }

  void dispose() {
    stopMonitoring();
    _appLaunchController.close();
  }
}
