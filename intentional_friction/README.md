# Intentional Friction

**A Digital Wellbeing App That Creates Self-Awareness Through Thoughtful Pauses**

## What Is This?

Intentional Friction helps you understand *why* you reach for your phone and makes you consciously choose whether to proceed. Instead of blocking apps or shaming you for screen time, it creates moments of reflection that shift you from autopilot to intentional engagement.

## Quick Start

### Prerequisites

- Flutter 3.16.0 or higher
- Android Studio or VS Code with Flutter extensions
- **Android**: Device or emulator (API level 21+)
- **iOS**: Xcode 15+ on macOS, iOS device or simulator (iOS 13+)

### Installation

1. **Clone or navigate to the project**:
   ```bash
   cd /home/user/next/intentional_friction
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### First Time Setup

#### Android (Automatic Monitoring)
1. Launch the app and complete the onboarding
2. Tap "Grant Permissions" to allow usage stats access
3. Follow the Android system prompt to enable usage access
4. Tap "Start Monitoring"
5. Try opening Instagram, Twitter, or any monitored app
6. Experience your first friction moment automatically!

#### iOS (Manual Trigger Mode)
1. Launch the app and complete the onboarding
2. Tap the "Pause & Reflect" button before opening social apps
3. Experience a friction moment to check your intentions
4. Choose to proceed or close the app
5. Your patterns are tracked over time

**Note**: iOS doesn't allow background app monitoring. Instead, you manually trigger friction moments when you feel the urge to open social apps. Future updates will add Siri Shortcuts for quick access.

## How It Works

```
You reach for Instagram
       ↓
[FRICTION MOMENT]
"Before you open Instagram...
What are you hoping to find?"
       ↓
3-second reflection pause
       ↓
Choose: Proceed Anyway | Close
       ↓
Track your mindfulness over time
```

## Features

### Phase 1 (MVP) ✅ Complete

- ✅ App launch detection for social media apps
- ✅ Friction moment with reflective prompt
- ✅ 3-second minimum reflection period
- ✅ Beautiful, calming UI with breathing animation
- ✅ Daily stats tracking (opens, proceeds, closes, mindfulness rate)
- ✅ Local-first data storage with Hive
- ✅ Usage stats permission handling

### Phase 2 (Intelligence) ✅ Complete

- ✅ All 5 friction modes (mirror, question, trade-off, breath, alternative)
- ✅ Adaptive intelligence based on your patterns
- ✅ Emotion tracking (6 emotions: bored, anxious, curious, avoiding, lonely, tired)
- ✅ Time-of-day pattern recognition
- ✅ Weekly insights generation
- ✅ Zombie hour detection (high proceed-rate times)
- ✅ Adaptive intervention rate
- ✅ Settings screen with customization
- ✅ Insights screen with 30-day trends

### Phase 3 (Polish) ✅ Complete

- ✅ iOS support (manual trigger mode)
- ✅ Android support (automatic monitoring)
- ✅ 8-page interactive onboarding
- ✅ Haptic feedback system
- ✅ Material Design 3 theming
- ✅ Bottom navigation
- ✅ Production-ready architecture

### Future Enhancements

- Siri Shortcuts integration (iOS)
- Advanced animations (Rive/Lottie)
- Sound design
- Data export/import
- Premium features

## Monitored Apps

By default, the app monitors:
- Instagram
- Facebook
- Twitter
- Reddit
- TikTok
- Snapchat
- YouTube
- Flipboard
- LinkedIn

You can customize this list in the code at `lib/core/utils/constants.dart`.

## Platform Differences

### Android: Automatic Background Monitoring
- **How it works**: Uses Android's UsageStatsManager API to detect when you open monitored apps
- **User experience**: Friction appears automatically when opening social apps
- **Permissions**: Requires "Usage Access" permission (one-time setup)
- **Monitoring**: Runs in background, polls every 2 seconds
- **Controls**: Start/Stop Monitoring buttons

### iOS: Manual Trigger Mode
- **Why manual?**: iOS doesn't allow background app monitoring (privacy restrictions)
- **How it works**: Tap "Pause & Reflect" button before opening social apps
- **User experience**: Self-initiated friction moments
- **Permissions**: None required (all local)
- **Benefits**:
  - More intentional (you decide when to pause)
  - Works with any app (not limited to monitored list)
  - Can trigger friction anytime you feel impulsive
- **Future**: Siri Shortcuts will enable quick access via voice/widget

Both platforms track your choices and generate the same insights!

## Project Structure

```
lib/
├── core/
│   ├── models/           # Data models (FrictionMoment, etc.)
│   ├── services/         # Business logic services
│   └── utils/            # Constants and helpers
├── features/
│   ├── friction_moment/  # Friction screen UI
│   └── home/             # Home screen with stats
├── providers/            # Riverpod state management
├── app.dart              # App configuration
└── main.dart             # Entry point
```

## Technologies Used

- **Flutter 3.x**: Cross-platform mobile framework
- **Riverpod**: State management
- **Hive**: Local database
- **app_usage**: Android usage statistics
- **permission_handler**: Runtime permissions

## Development

### Running Tests

```bash
flutter test
```

### Building for Release

#### Android
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# iOS build (requires macOS with Xcode)
flutter build ios --release

# Or open in Xcode for signing and distribution
open ios/Runner.xcworkspace
```

### Adding New Monitored Apps

Edit `lib/core/utils/constants.dart`:

```dart
static const Set<String> defaultMonitoredApps = {
  'com.instagram.android',
  'com.example.newapp',  // Add new package name
};

static const Map<String, String> appNamesMap = {
  'com.instagram.android': 'Instagram',
  'com.example.newapp': 'New App',  // Add friendly name
};
```

## Troubleshooting

### Android-Specific

**"App usage permission denied"**
- Go to Settings > Apps > Special access > Usage access
- Enable for Intentional Friction

**Friction not appearing**
- Ensure monitoring is active (shield icon should be filled)
- Verify the app you're opening is in the monitored list
- Check Flutter logs: `flutter logs`

### iOS-Specific

**"Pause & Reflect" button not working**
- This is expected behavior - button generates friction on-demand
- Tap it when you feel urge to open social apps
- Not meant to detect apps automatically

**No friction appearing automatically**
- This is expected on iOS - friction is manual-trigger only
- Use the "Pause & Reflect" button before opening apps

### Cross-Platform

**Hive adapter errors**
- Clean and rebuild: `flutter pub run build_runner clean`
- Regenerate: `flutter pub run build_runner build --delete-conflicting-outputs`

**Onboarding appears every time**
- Settings may not be persisting
- Check Hive initialization in main.dart
- Try clearing app data and reinstalling

## Philosophy

**Core Principles**:
1. **Awareness Over Restriction**: We don't block; we pause
2. **Friction as Mirror**: Discomfort is data, not punishment
3. **Respect for Context**: Not all screen time is equal
4. **Beautiful Difficulty**: Friction should feel meaningful

## Contributing

This project is currently in MVP phase. Contributions welcome once we validate the core concept!

## License

MIT (tentative)

## Credits

Built with research from:
- Digital wellbeing studies (2024-2025)
- Behavioral psychology (System 1 vs System 2 thinking)
- Design friction and habit formation research

---

**Make technology serve you, not the other way around.**
