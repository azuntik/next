## Testing Guide for Intentional Friction

This document provides comprehensive testing strategies for the Intentional Friction app.

## Automated Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/friction_decision_engine_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Structure

```
test/
├── unit/                   # Unit tests for business logic
│   ├── friction_decision_engine_test.dart
│   ├── data_export_service_test.dart
│   └── pattern_recognition_test.dart
├── widget/                 # Widget tests for UI components
│   ├── friction_screen_test.dart
│   ├── home_screen_test.dart
│   └── onboarding_screen_test.dart
└── integration/            # End-to-end integration tests
    └── friction_flow_test.dart
```

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage for business logic
- **Widget Tests**: All critical UI components
- **Integration Tests**: Happy paths + error scenarios

## Manual Testing Checklist

### First-Time Setup (Android)

- [ ] App launches successfully
- [ ] Onboarding screens display correctly
- [ ] All 8 onboarding pages are readable
- [ ] "Get Started" button works
- [ ] Permission request appears
- [ ] Granting permission works
- [ ] Start Monitoring button enables

### First-Time Setup (iOS)

- [ ] App launches successfully
- [ ] Onboarding screens display correctly
- [ ] "Pause & Reflect" button is visible
- [ ] Manual friction trigger works
- [ ] Settings > iOS Shortcuts accessible
- [ ] Shortcuts setup guide displays correctly

### Core Friction Flow

**Android:**
- [ ] Open monitored app triggers friction
- [ ] Friction screen displays correctly
- [ ] Countdown timer works (3 seconds)
- [ ] Buttons disabled during countdown
- [ ] Buttons enable after countdown
- [ ] "Proceed Anyway" opens target app
- [ ] "Close" returns to home
- [ ] Emotion tracking appears
- [ ] Selecting emotion works
- [ ] Data is saved correctly

**iOS:**
- [ ] "Pause & Reflect" button triggers friction
- [ ] Friction screen displays correctly
- [ ] All friction functionality same as Android

### All Friction Modes

Test each mode works correctly:
- [ ] Mirror mode: Reflective questions
- [ ] Question mode: Motivation inquiry
- [ ] Trade-off mode: Alternative suggestions
- [ ] Breath mode: Breathing animation
- [ ] Alternative mode: Activity suggestions

### Insights Screen

- [ ] Insights display with data
- [ ] Empty state shows when no data
- [ ] Weekly trend chart displays
- [ ] Insight cards show relevant patterns
- [ ] Pull-to-refresh works
- [ ] Navigation works

### Settings Screen

**General:**
- [ ] All sections display correctly
- [ ] Toggle switches work
- [ ] Intensity selection works
- [ ] Settings persist after app restart

**Data Export:**
- [ ] Export shows statistics
- [ ] JSON export works
- [ ] CSV export works
- [ ] Share sheet opens
- [ ] Empty state handled

**Feedback:**
- [ ] Send Feedback opens options
- [ ] Email client launches
- [ ] Fallback contact info shows if no email
- [ ] Rate App opens store
- [ ] GitHub link opens browser

**iOS Shortcuts:**
- [ ] Setup guide accessible
- [ ] Mode selection works
- [ ] Quick import displays
- [ ] Manual setup displays
- [ ] Navigation works
- [ ] Can return to add more apps

### Error Scenarios

- [ ] No internet (if applicable)
- [ ] Permission denied handled gracefully
- [ ] Low storage handled
- [ ] Corrupted data handled
- [ ] App crash recovery
- [ ] Background/foreground transitions

### Performance

- [ ] App launches in < 3 seconds (cold start)
- [ ] Friction appears in < 500ms
- [ ] Smooth animations (60 FPS)
- [ ] No memory leaks
- [ ] Battery usage acceptable
- [ ] Database performance with 1000+ moments

### Platform-Specific

**Android:**
- [ ] Works on Android 5.0+ (API 21+)
- [ ] Works on different screen sizes
- [ ] Works with system gestures
- [ ] Battery optimization doesn't break monitoring
- [ ] App drawer integration

**iOS:**
- [ ] Works on iOS 13+
- [ ] Works on different screen sizes (SE, Pro Max)
- [ ] Works with system gestures
- [ ] Dark mode support
- [ ] Shortcuts app integration
- [ ] Siri commands work

## Accessibility Testing

### Screen Reader Testing

**VoiceOver (iOS):**
1. Enable: Settings > Accessibility > VoiceOver
2. Test navigation: Swipe right/left
3. Test activation: Double tap
4. Verify all elements have labels
5. Verify proper reading order
6. Test friction screen completely
7. Test all buttons and controls

**TalkBack (Android):**
1. Enable: Settings > Accessibility > TalkBack
2. Test navigation: Swipe right/left
3. Test activation: Double tap
4. Verify all elements have labels
5. Verify proper reading order
6. Test friction screen completely
7. Test all buttons and controls

### Dynamic Type Testing

**iOS:**
1. Settings > Accessibility > Display & Text Size
2. Test at smallest size
3. Test at largest size
4. Verify text doesn't clip
5. Verify buttons remain tappable
6. Verify layouts adjust properly

**Android:**
1. Settings > Display > Font size
2. Test at smallest size
3. Test at largest size
4. Verify text doesn't clip
5. Verify buttons remain tappable
6. Verify layouts adjust properly

### Reduce Motion Testing

**iOS:**
1. Enable: Settings > Accessibility > Motion > Reduce Motion
2. Verify animations are simplified
3. Verify breathing animation adapts
4. Verify transitions work

**Android:**
1. Enable: Settings > Accessibility > Remove animations
2. Verify animations are simplified
3. Verify breathing animation adapts
4. Verify transitions work

### Color Contrast Testing

1. Use accessibility inspector tools
2. Verify WCAG AA compliance (4.5:1 for normal text)
3. Test in different lighting conditions
4. Test with color blindness filters
5. Verify important information not conveyed by color alone

### Focus Management

- [ ] Logical tab order
- [ ] Focus indicators visible
- [ ] Focus moves correctly after actions
- [ ] Keyboard navigation works (if applicable)
- [ ] Focus announcements correct

## Beta Testing

### Preparation

1. Build release version:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. Create testing group:
   - 10-20 diverse users
   - Mix of iOS and Android
   - Various usage patterns
   - Different accessibility needs

3. Testing duration: 2 weeks minimum

### Feedback Collection

**Required Feedback:**
- Installation experience
- First-time onboarding clarity
- Friction effectiveness
- Bugs encountered
- Feature requests
- Performance issues
- Battery impact
- Accessibility issues

**Tools:**
- Google Forms for structured feedback
- TestFlight (iOS) for crash reports
- Google Play Console (Android) for crash reports
- In-app feedback mechanism
- Email for detailed reports

### Key Metrics to Track

- Crash-free rate (target: >99%)
- App launch time (target: <3s)
- Friction display time (target: <500ms)
- User retention after 1 week
- Average friction moments per day
- Proceed vs Close ratio
- User-reported bugs
- App store ratings

## Continuous Integration

### Automated Checks

```yaml
# .github/workflows/test.yml
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug
```

### Pre-Commit Checks

```bash
# Run before committing
flutter analyze
flutter test
flutter format lib/ test/
```

### Pre-Release Checks

- [ ] All tests passing
- [ ] No analyzer warnings
- [ ] Code formatted
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version bumped
- [ ] Screenshots current
- [ ] Privacy policy current
- [ ] App store descriptions current

## Regression Testing

After any major changes, re-test:
- [ ] Core friction flow
- [ ] Data export/import
- [ ] All friction modes
- [ ] iOS Shortcuts integration
- [ ] Settings changes persist
- [ ] Insights generation
- [ ] Accessibility features

## Performance Testing

### Tools

- Flutter DevTools
- Android Profiler
- Xcode Instruments
- Firebase Performance Monitoring (if added)

### Key Areas

1. **App Launch**: Profile cold start
2. **Database**: Test with 10,000+ records
3. **Memory**: Check for leaks
4. **Battery**: Monitor background usage (Android)
5. **Network**: Test offline behavior
6. **Rendering**: Ensure 60 FPS

### Performance Benchmarks

```dart
// test/performance/friction_display_benchmark.dart
void main() {
  testWidgets('Friction screen renders in < 500ms', (tester) async {
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
```

## Security Testing

- [ ] Local data encryption
- [ ] No data leaks to logs
- [ ] Secure data export
- [ ] No sensitive data in screenshots
- [ ] Proper permission handling
- [ ] URL scheme validation (iOS)
- [ ] No SQL injection (if applicable)

## Localization Testing (Future)

When adding localization:
- [ ] All strings externalized
- [ ] Translations complete
- [ ] RTL support (if applicable)
- [ ] Date/time formatting
- [ ] Number formatting
- [ ] Currency formatting (if applicable)

## App Store Testing

### Before Submission

**Both Platforms:**
- [ ] App icon looks good
- [ ] Screenshots look professional
- [ ] Description is compelling
- [ ] Keywords optimized
- [ ] Privacy policy accessible
- [ ] Support URL works
- [ ] App rating appropriate

**iOS Specific:**
- [ ] TestFlight testing complete
- [ ] App Review Guidelines compliance
- [ ] Required metadata complete
- [ ] In-app purchases configured (if applicable)

**Android Specific:**
- [ ] Internal testing track used
- [ ] Open testing track used (optional)
- [ ] Content rating complete
- [ ] Required metadata complete

## Known Issues

Document any known issues:
1. **Issue**: Brief description
   - **Impact**: Who it affects
   - **Workaround**: If available
   - **Status**: In progress / Won't fix / etc.

## Test Report Template

```markdown
# Test Report - [Date]

## Environment
- Device: iPhone 14 Pro / Pixel 7
- OS Version: iOS 17.1 / Android 14
- App Version: 1.0.0

## Tests Performed
- [ ] Feature X
- [ ] Feature Y

## Results
- Passed: X tests
- Failed: Y tests
- Blocked: Z tests

## Bugs Found
1. [Description] - Severity: High/Medium/Low

## Notes
[Any additional observations]
```

---

**Remember**: Testing is ongoing! Every release should include:
1. Automated test run
2. Manual regression testing
3. Accessibility check
4. Performance validation
5. Beta feedback review

**Quality > Speed**: Better to delay release than ship broken code.
