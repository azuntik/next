import 'package:flutter/services.dart';

/// Haptic feedback utilities for better UX
class Haptics {
  /// Light impact for minor interactions (button taps, switches)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for standard interactions (selections, completions)
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for significant events (important choices, confirmations)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback for toggles and selections
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for errors or warnings
  static Future<void> error() async {
    await HapticFeedback.vibrate();
  }
}
