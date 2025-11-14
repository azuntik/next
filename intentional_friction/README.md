# Intentional Friction

**A Digital Wellbeing App That Creates Self-Awareness Through Thoughtful Pauses**

## What Is This?

Intentional Friction helps you understand *why* you reach for your phone and makes you consciously choose whether to proceed. Instead of blocking apps or shaming you for screen time, it creates moments of reflection that shift you from autopilot to intentional engagement.

## Quick Start

### Prerequisites

- Flutter 3.16.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (API level 21+)

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

1. Launch the app
2. Tap "Grant Permissions" to allow usage stats access
3. Follow the Android system prompt to enable usage access
4. Tap "Start Monitoring"
5. Try opening Instagram, Twitter, or any monitored app
6. Experience your first friction moment!

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

### Phase 1 (MVP) - Current Implementation

- ✅ App launch detection for social media apps
- ✅ Friction moment with reflective prompt
- ✅ 3-second minimum reflection period
- ✅ Beautiful, calming UI with breathing animation
- ✅ Daily stats tracking (opens, proceeds, closes, mindfulness rate)
- ✅ Local-first data storage with Hive
- ✅ Usage stats permission handling

### Phase 2 (Coming Soon)

- Multiple friction modes (mirror, breath, trade-off, alternative)
- Adaptive intelligence based on your patterns
- Emotion tracking
- Time-of-day pattern recognition
- Weekly insights generation

### Phase 3 (Future)

- iOS support
- Custom animations
- Sound design
- Advanced settings
- Data export

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

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
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

### "App usage permission denied"
- Go to Settings > Apps > Special access > Usage access
- Enable for Intentional Friction

### Friction not appearing
- Ensure monitoring is active (shield icon should be filled)
- Verify the app you're opening is in the monitored list
- Check Flutter logs: `flutter logs`

### Hive adapter errors
- Clean and rebuild: `flutter pub run build_runner clean`
- Regenerate: `flutter pub run build_runner build --delete-conflicting-outputs`

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
