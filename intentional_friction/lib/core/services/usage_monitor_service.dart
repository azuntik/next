import 'dart:async';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class UsageMonitorService {
  final AppUsage _appUsage = AppUsage();
  String? _lastForegroundApp;
  Timer? _monitorTimer;
  bool _isIOS = false;

  final StreamController<String> _appLaunchController =
      StreamController<String>.broadcast();

  Stream<String> get appLaunchStream => _appLaunchController.stream;

  // Monitored apps (social media, news, etc.)
  final Set<String> _monitoredApps = Set.from(AppConstants.defaultMonitoredApps);

  // iOS-specific: Track manual friction checks
  final StreamController<void> _manualTriggerController =
      StreamController<void>.broadcast();

  Stream<void> get manualTriggerStream => _manualTriggerController.stream;

  UsageMonitorService() {
    _isIOS = Platform.isIOS;
  }

  bool get isIOS => _isIOS;
  bool get isAndroid => Platform.isAndroid;

  Future<bool> requestPermissions() async {
    if (_isIOS) {
      // iOS: No special permissions needed for manual mode
      // In the future, could request Screen Time API access here
      return true;
    }

    // Android: Request usage stats permission
    final status = await Permission.appUsage.status;

    if (status.isGranted) {
      return true;
    }

    final result = await Permission.appUsage.request();
    return result.isGranted;
  }

  Future<void> startMonitoring() async {
    if (_isIOS) {
      // iOS: Background monitoring not supported
      // App will use manual trigger mode
      print('iOS detected: Using manual friction trigger mode');
      return;
    }

    // Android: Full background monitoring
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
    if (_isIOS) return; // Not supported on iOS

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

  /// iOS-specific: Manually trigger a friction check
  /// User calls this when they feel the urge to open a social app
  void triggerManualFrictionCheck(String appName) {
    if (!_isIOS) {
      print('Warning: Manual trigger is designed for iOS');
    }

    // Simulate app launch event
    _appLaunchController.add(appName);
  }

  /// iOS-specific: Quick friction check (opens friction moment)
  void quickFrictionCheck() {
    _manualTriggerController.add(null);
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
    if (_isIOS) {
      // iOS: Screen Time data not accessible without special entitlements
      return {};
    }

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

  String getPlatformInstructions() {
    if (_isIOS) {
      return 'iOS Mode: Tap "Pause & Reflect" button before opening social apps, '
          'or set up a Siri Shortcut to trigger friction automatically.';
    } else {
      return 'Android Mode: Friction moments appear automatically when you '
          'try to open monitored apps.';
    }
  }

  void dispose() {
    stopMonitoring();
    _appLaunchController.close();
    _manualTriggerController.close();
  }
}
