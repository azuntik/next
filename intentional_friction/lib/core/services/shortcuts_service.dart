import 'dart:io';
import 'package:flutter/services.dart';

/// Service to handle iOS Shortcuts integration
class ShortcutsService {
  static const MethodChannel _channel =
      MethodChannel('com.intentionalfriction/shortcuts');

  static ShortcutsService? _instance;
  Function(String)? _onFrictionTriggered;

  ShortcutsService._();

  static ShortcutsService get instance {
    _instance ??= ShortcutsService._();
    return _instance!;
  }

  /// Initialize shortcuts service and set up method channel handler
  Future<void> initialize(Function(String) onFrictionTriggered) async {
    if (!Platform.isIOS) return;

    _onFrictionTriggered = onFrictionTriggered;

    // Set up method call handler to receive calls from iOS
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from iOS (App Intents and URL schemes)
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'showFriction') {
      final String appName =
          (call.arguments as Map<dynamic, dynamic>)['appName'] ?? 'manual_trigger';
      _onFrictionTriggered?.call(appName);
      return true;
    }
    return false;
  }

  /// Get URL scheme for manual shortcuts
  static String getUrlScheme({String? appName}) {
    if (appName != null && appName.isNotEmpty) {
      return 'intentionalfriction://trigger?app=${Uri.encodeComponent(appName)}';
    }
    return 'intentionalfriction://trigger';
  }

  /// Check if device supports App Intents (iOS 16+)
  static bool supportsAppIntents() {
    if (!Platform.isIOS) return false;
    // In a real app, you'd check iOS version here
    // For now, assume iOS 16+ is available
    return true;
  }
}
