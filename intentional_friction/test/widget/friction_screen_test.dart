import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intentional_friction/features/friction_moment/presentation/friction_screen.dart';
import 'package:intentional_friction/core/models/friction_moment.dart';

void main() {
  group('FrictionScreen Widget Tests', () {
    late FrictionMoment testMoment;

    setUp(() {
      testMoment = FrictionMoment(
        id: 'test',
        timestamp: DateTime.now(),
        targetApp: 'Instagram',
        mode: FrictionMode.question,
        prompt: 'What are you hoping to find?',
        displayDurationMs: 3000,
      );
    });

    testWidgets('displays friction prompt correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      expect(find.text('What are you hoping to find?'), findsOneWidget);
    });

    testWidgets('shows app name in UI', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      expect(find.textContaining('Instagram'), findsWidgets);
    });

    testWidgets('displays proceed and close buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      expect(find.text('Proceed Anyway'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('buttons are disabled during countdown', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      final proceedButton = find.text('Proceed Anyway');
      await tester.tap(proceedButton);
      await tester.pump();

      // Button tap should not navigate immediately (countdown active)
      expect(find.byType(FrictionScreen), findsOneWidget);
    });

    testWidgets('buttons become enabled after countdown', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Wait for countdown (3 seconds)
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // Now button should be enabled
      final proceedButton = find.text('Proceed Anyway');
      expect(tester.widget<ElevatedButton>(proceedButton).enabled, isTrue);
    });

    testWidgets('displays emotion grid when appropriate', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Skip countdown
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // Look for emotion labels
      expect(find.text('Bored'), findsOneWidget);
      expect(find.text('Anxious'), findsOneWidget);
      expect(find.text('Curious'), findsOneWidget);
    });

    testWidgets('selecting emotion updates state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Skip countdown
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // Tap an emotion
      await tester.tap(find.text('Bored'));
      await tester.pump();

      // Visual feedback should appear (chip selected state)
      final boredChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Bored'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(boredChip.selected, isTrue);
    });

    testWidgets('breathing animation is present for breath mode', (tester) async {
      final breathMoment = FrictionMoment(
        id: 'test',
        timestamp: DateTime.now(),
        targetApp: 'Instagram',
        mode: FrictionMode.breath,
        prompt: 'Take a deep breath',
        displayDurationMs: 3000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: breathMoment),
          ),
        ),
      );

      // Should have animated container for breathing
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('screen has semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Check for semantics
      expect(
        tester.getSemantics(find.text('Proceed Anyway')),
        matchesSemantics(
          label: contains('Proceed'),
          isButton: true,
        ),
      );
    });

    testWidgets('back button is disabled during countdown', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Try to pop
      await tester.pageBack();
      await tester.pump();

      // Should still be on friction screen
      expect(find.byType(FrictionScreen), findsOneWidget);
    });

    testWidgets('displays countdown timer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: testMoment),
          ),
        ),
      );

      // Should show countdown
      expect(find.textContaining('3'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('2'), findsOneWidget);
    });

    testWidgets('handles different friction modes correctly', (tester) async {
      for (final mode in FrictionMode.values) {
        final moment = FrictionMoment(
          id: 'test_$mode',
          timestamp: DateTime.now(),
          targetApp: 'Instagram',
          mode: mode,
          prompt: 'Test prompt for $mode',
          displayDurationMs: 3000,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: FrictionScreen(moment: moment),
            ),
          ),
        );

        expect(find.byType(FrictionScreen), findsOneWidget);
        expect(find.text('Test prompt for $mode'), findsOneWidget);

        await tester.pumpWidget(Container()); // Clear
      }
    });
  });

  group('FrictionScreen Accessibility', () {
    test Widgets('has proper semantic structure', (tester) async {
      final moment = FrictionMoment(
        id: 'test',
        timestamp: DateTime.now(),
        targetApp: 'Instagram',
        mode: FrictionMode.question,
        prompt: 'What are you hoping to find?',
        displayDurationMs: 3000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: moment),
          ),
        ),
      );

      // Check that important elements have semantics
      final semantics = tester.getSemantics(find.byType(FrictionScreen));
      expect(semantics, isNotNull);
    });

    testWidgets('buttons have proper labels for screen readers', (tester) async {
      final moment = FrictionMoment(
        id: 'test',
        timestamp: DateTime.now(),
        targetApp: 'Instagram',
        mode: FrictionMode.question,
        prompt: 'Test prompt',
        displayDurationMs: 3000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FrictionScreen(moment: moment),
          ),
        ),
      );

      // Skip countdown
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // Verify buttons are accessible
      expect(find.bySemanticsLabel(RegExp('Proceed', caseSensitive: false)), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Close', caseSensitive: false)), findsWidgets);
    });
  });
}
