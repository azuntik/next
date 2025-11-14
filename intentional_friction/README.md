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

#### iOS (Manual Trigger or Shortcuts Automation)
1. Launch the app and complete the onboarding
2. **Option 1 - Manual**: Tap the "Pause & Reflect" button before opening social apps
3. **Option 2 - Automatic** (Recommended): Set up iOS Shortcuts automation
   - Go to Settings > iOS Shortcuts Setup
   - Choose Quick Import (2 min) or Manual Setup (5 min)
   - **Quick Import**: One-tap shortcut download + simple automation
   - **Manual Setup**: Step-by-step guide to create from scratch
   - Once set up, friction appears automatically when opening apps!
   - Use Siri: "Hey Siri, check Instagram" for quick access
4. Your patterns are tracked over time

**Note**: iOS doesn't allow background monitoring like Android, but iOS Shortcuts makes it nearly automatic! The setup guide offers pre-made shortcuts you can import with one tap, or detailed instructions to create them manually.

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
- ✅ iOS Shortcuts automation (App Intents + URL schemes)
- ✅ Comprehensive setup guide for iOS automations
- ✅ Siri voice commands support
- ✅ 8-page interactive onboarding
- ✅ Haptic feedback system
- ✅ Material Design 3 theming
- ✅ Bottom navigation
- ✅ Production-ready architecture

### Future Enhancements

- iOS widgets for quick friction access
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

### iOS: Manual Trigger + Shortcuts Automation
- **Why not automatic?**: iOS doesn't allow background app monitoring (privacy restrictions)
- **Manual mode**: Tap "Pause & Reflect" button before opening social apps
- **Shortcuts mode** (Recommended):
  - Set up iOS Shortcuts automations (one-time, 5 min per app)
  - Friction appears automatically when opening apps
  - Use Siri commands: "Hey Siri, check Instagram"
  - Add shortcuts to home screen widgets
  - Create personal automations in Shortcuts app
- **User experience**: Nearly automatic with Shortcuts, or self-initiated with button
- **Permissions**: None required (all local)
- **Benefits**:
  - Shortcuts make it nearly automatic after setup
  - Works with any app (not limited to monitored list)
  - Voice control via Siri
  - Widget support for quick access
  - More intentional (you set it up consciously)
- **Setup guide**: Built-in step-by-step guide in Settings > iOS Shortcuts

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
- Or set up iOS Shortcuts for automatic friction

**Want automatic friction on iOS?**
- Go to Settings > iOS Shortcuts Setup
- Follow the step-by-step guide to create automations
- Takes 5 minutes per app, works forever
- Friction will appear automatically when opening apps

**Shortcuts not triggering friction**
- Make sure you disabled "Ask Before Running" in automation settings
- Check that the URL scheme is correct in your shortcut
- Verify the app is open when the automation runs
- Try saying "Hey Siri, check [app name]" to test

**Siri commands not working**
- Ensure you've created the shortcut first
- The shortcut must use the URL scheme from the setup guide
- Try renaming your shortcut to match what you say to Siri

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
