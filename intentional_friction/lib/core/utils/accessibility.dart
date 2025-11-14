import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utility functions and constants for the app
class AccessibilityHelper {
  // Semantic label builders
  static String frictionMomentLabel(String appName, String prompt) {
    return 'Friction moment for $appName. $prompt. Take a moment to reflect before proceeding.';
  }

  static String buttonLabel(String text, {bool enabled = true}) {
    return enabled ? text : '$text, disabled during countdown';
  }

  static String statLabel(String label, String value) {
    return '$label: $value';
  }

  static String modeLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'mirror':
        return 'Mirror mode: Reflects your intentions';
      case 'question':
        return 'Question mode: Asks about your motivations';
      case 'tradeoff':
        return 'Trade-off mode: Consider what you might miss';
      case 'breath':
        return 'Breath mode: Take a mindful breath';
      case 'alternative':
        return 'Alternative mode: Suggests other activities';
      default:
        return mode;
    }
  }

  static String emotionLabel(String emotion) {
    return 'Select $emotion as your current emotional state';
  }

  static String chartLabel(String title, String description) {
    return '$title. $description';
  }

  // Announce changes to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  // Create semantic widget wrapper
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? enabled,
    bool? checked,
    bool? selected,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      enabled: enabled,
      checked: checked,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  // Check if large text is enabled
  static bool isLargeText(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }

  // Get scaled text size based on user preferences
  static double getScaledFontSize(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return baseSize * textScaleFactor.clamp(0.8, 2.0);
  }

  // Check if reduce motion is enabled
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  // Get animation duration based on accessibility settings
  static Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    return shouldReduceMotion(context)
        ? Duration.zero
        : defaultDuration;
  }

  // Focus management helpers
  static void requestFocus(BuildContext context, FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(node);
    });
  }

  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Color contrast checker
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    final contrast = (lighter + 0.05) / (darker + 0.05);

    // WCAG AA requires 4.5:1 for normal text, 3:1 for large text
    return contrast >= 4.5;
  }

  // Get accessible text color for background
  static Color getAccessibleTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Semantic hints for common actions
  static const String tapToSelectHint = 'Double tap to select';
  static const String tapToOpenHint = 'Double tap to open';
  static const String tapToCloseHint = 'Double tap to close';
  static const String tapToToggleHint = 'Double tap to toggle';
  static const String swipeHint = 'Swipe left or right to navigate';
  static const String longPressHint = 'Long press for more options';

  // Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    required VoidCallback onTap,
    String? value,
    bool showTrailingIcon = true,
  }) {
    return Semantics(
      label: label,
      value: value,
      button: true,
      hint: tapToOpenHint,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }

  // Create accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint ?? (onTap != null ? tapToOpenHint : null),
      button: onTap != null,
      child: onTap != null
          ? InkWell(onTap: onTap, child: child)
          : child,
    );
  }

  // Create accessible icon button
  static Widget accessibleIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String? hint,
    Color? color,
  }) {
    return Semantics(
      label: label,
      hint: hint ?? tapToSelectHint,
      button: true,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: color,
        tooltip: label, // Also set tooltip for hover
      ),
    );
  }

  // Create accessible text field
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  // Merge semantics for grouped content
  static Widget mergeSemantics({
    required Widget child,
    String? label,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: child,
      ),
    );
  }

  // Exclude from semantics tree (for decorative elements)
  static Widget excludeSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  // Create accessible switch
  static Widget accessibleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      value: value ? 'On' : 'Off',
      hint: hint ?? tapToToggleHint,
      toggled: value,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // Create accessible slider
  static Widget accessibleSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      value: value.toStringAsFixed(0),
      hint: hint ?? 'Swipe up or down to adjust',
      slider: true,
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

/// Extension on BuildContext for easier accessibility checks
extension AccessibilityContext on BuildContext {
  bool get isLargeText => AccessibilityHelper.isLargeText(this);
  bool get shouldReduceMotion => AccessibilityHelper.shouldReduceMotion(this);

  void announce(String message) {
    AccessibilityHelper.announce(this, message);
  }

  double scaleFont(double baseSize) {
    return AccessibilityHelper.getScaledFontSize(this, baseSize);
  }

  Duration scaleAnimation(Duration defaultDuration) {
    return AccessibilityHelper.getAnimationDuration(this, defaultDuration);
  }
}

/// Widget for testing accessibility in debug mode
class AccessibilityDebugOverlay extends StatelessWidget {
  final Widget child;

  const AccessibilityDebugOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (const bool.fromEnvironment('SHOW_ACCESSIBILITY_DEBUG'))
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A11y Debug',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Text Scale: ${MediaQuery.of(context).textScaleFactor.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Reduce Motion: ${MediaQuery.of(context).disableAnimations}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Bold Text: ${MediaQuery.of(context).boldText}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
