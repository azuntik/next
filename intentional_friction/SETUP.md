# Setup Guide for Intentional Friction

This guide will help you get the app running on your development machine.

## Prerequisites

### Required Software

1. **Flutter SDK** (3.16.0 or higher)
   ```bash
   # Check your Flutter version
   flutter --version

   # If not installed, download from:
   # https://docs.flutter.dev/get-started/install
   ```

2. **Android Studio** or **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code with Flutter extension: https://code.visualstudio.com/

3. **Android SDK** (API level 21+)
   - Installed automatically with Android Studio
   - Or install separately: https://developer.android.com/studio#command-tools

4. **Android Device or Emulator**
   - Physical device (recommended for testing)
   - Or Android Emulator from Android Studio

## Step-by-Step Setup

### 1. Install Flutter Dependencies

```bash
cd /home/user/next/intentional_friction
flutter pub get
```

This will download all packages specified in `pubspec.yaml`.

### 2. Generate Hive Type Adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates the necessary code for Hive database models (`friction_moment.g.dart`).

### 3. Verify Flutter Setup

```bash
flutter doctor
```

Ensure all checkmarks are green, especially:
- ✓ Flutter
- ✓ Android toolchain
- ✓ Connected devices

### 4. Connect Android Device

**Option A: Physical Device**
1. Enable Developer Options on your Android phone
2. Enable USB Debugging
3. Connect via USB
4. Verify with: `flutter devices`

**Option B: Emulator**
1. Open Android Studio
2. AVD Manager > Create Virtual Device
3. Select device (e.g., Pixel 5)
4. Download and select system image (API 30+)
5. Start emulator
6. Verify with: `flutter devices`

### 5. Run the App

```bash
flutter run
```

Or use your IDE:
- **VS Code**: Press F5 or click "Run > Start Debugging"
- **Android Studio**: Click the green play button

## Post-Installation Setup

### 1. Grant Permissions

When you first launch the app:

1. Tap **"Grant Permissions"**
2. You'll be taken to Android Settings
3. Navigate to: Settings > Apps > Special access > Usage access
4. Find **"Intentional Friction"**
5. Toggle it **ON**
6. Return to the app

### 2. Start Monitoring

1. Tap **"Start Monitoring"**
2. The shield icon should turn from gray to purple
3. Status should show "Monitoring Active"

### 3. Test Friction

1. Minimize the app
2. Open Instagram, Twitter, or any monitored social media app
3. After 2 seconds, you should see the friction screen
4. Wait 3 seconds for buttons to appear
5. Choose "Proceed Anyway" or "Close"
6. Return to app to see updated stats

## Customization

### Change Monitored Apps

Edit `lib/core/utils/constants.dart`:

```dart
static const Set<String> defaultMonitoredApps = {
  'com.instagram.android',
  'com.facebook.katana',
  // Add more package names here
};
```

To find an app's package name:
```bash
adb shell pm list packages | grep <app_name>
```

### Adjust Friction Duration

Edit `lib/core/utils/constants.dart`:

```dart
static const int minimumFrictionDurationSeconds = 3;  // Change to 5, 8, etc.
```

### Change Theme Colors

Edit `lib/core/utils/constants.dart`:

```dart
static const int primaryColorValue = 0xFF6C63FF;  // Purple
static const int backgroundColorValue = 0xFF1A1A2E;  // Dark blue
```

## Building for Distribution

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Common Issues

### Issue: "No connected devices"

**Solution**:
```bash
# Check connected devices
flutter devices

# If physical device not showing:
# 1. Reconnect USB cable
# 2. Allow USB debugging popup on phone
# 3. Try: adb kill-server && adb start-server

# If emulator not showing:
# Start emulator from Android Studio AVD Manager
```

### Issue: "Build failed with Gradle"

**Solution**:
```bash
# Clean build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Hive adapters not found"

**Solution**:
```bash
# Regenerate adapters
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Permission denied when accessing app usage"

**Solution**:
1. Open phone Settings
2. Apps > Intentional Friction > Permissions
3. Look for "Usage access" or "Special permissions"
4. Enable it manually

### Issue: "Friction screen not appearing"

**Checklist**:
- [ ] Monitoring is active (shield icon filled, not outlined)
- [ ] App you're opening is in monitored list
- [ ] Usage stats permission granted
- [ ] Not opening from recent apps (must be fresh launch)

**Debug**:
```bash
# View logs
flutter logs

# Look for:
# - "Error checking foreground app"
# - "App usage permission not granted"
```

## Development Tips

### Hot Reload

While app is running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Or use IDE shortcuts (VS Code: Ctrl+S, Android Studio: Ctrl+S)

### Debugging

Add breakpoints and use DevTools:
```bash
flutter run --observatory-port=9999
```

Then open DevTools: http://localhost:9999/

### View Logs

```bash
flutter logs
```

### Check Performance

```bash
flutter run --profile
```

### Analyze Code

```bash
flutter analyze
```

## Next Steps

1. ✅ Get app running
2. Test friction moments with different apps
3. Check stats tracking
4. Customize monitored apps for your needs
5. Use daily to build awareness
6. Provide feedback for Phase 2 features

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Android Debugging](https://developer.android.com/studio/debug)

---

Need help? Check the main README.md or create an issue on GitHub.
