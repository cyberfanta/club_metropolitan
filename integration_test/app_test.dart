import 'package:club_metropolitan/main.dart' as app;
import 'package:club_metropolitan/utils/stamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile Integration Tests', () {
    testWidgets('Complete app navigation test', (WidgetTester tester) async {
      // Start the app
      stamp('INTEGRATION_TEST', 'Starting mobile integration test');
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the splash screen
      stamp('TEST_SCREEN', 'Verifying splash screen');
      expect(find.byType(Image), findsWidgets);

      // Allow time for splash screen to complete
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify we're on the home screen (look for elements that actually exist on the home screen)
      stamp('TEST_SCREEN', 'Verifying home screen');
      // Instead of looking for specific text, we look for widgets we know are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byKey(Key('MyName')), findsOneWidget);

      // Find the "All Activities" navigation button that should be in the navigation bar
      final allActivitiesTab = find.byIcon(Icons.list).first;
      expect(allActivitiesTab, findsOneWidget);
      stamp('TEST_ACTION', 'Found All Activities tab');

      // Navigate to the All Activities screen
      stamp('TEST_ACTION', 'Navigating to All Activities screen');
      await tester.tap(allActivitiesTab);
      await tester.pumpAndSettle();

      // Verify the All Activities screen
      stamp('TEST_SCREEN', 'Verifying All Activities screen');
      // Look for specific elements on the activities screen
      expect(
        find.byType(TextField),
        findsOneWidget,
      ); // Look for the search field

      // Test the search functionality
      stamp('TEST_ACTION', 'Testing search functionality');
      await tester.enterText(find.byType(TextField), 'yoga');
      await tester.pumpAndSettle();

      // Clear the search
      stamp('TEST_ACTION', 'Clearing search field');
      final clearIcon = find.byIcon(Icons.clear);
      if (clearIcon.evaluate().isNotEmpty) {
        await tester.tap(clearIcon.first);
        await tester.pumpAndSettle();
      } else {
        stamp('TEST_INFO', 'Clear icon not found, continuing test');
        // Manually clear the text
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
      }

      // Navigate to My Activities
      stamp('TEST_ACTION', 'Navigating to My Activities screen');
      final myActivitiesTab = find.byIcon(Icons.person).first;
      expect(myActivitiesTab, findsOneWidget);
      await tester.tap(myActivitiesTab);
      await tester.pumpAndSettle();

      // Verify the My Activities screen
      stamp('TEST_SCREEN', 'Verifying My Activities screen');

      // Navigate to Home
      stamp('TEST_ACTION', 'Navigating back to home screen');
      final homeTab = find.byIcon(Icons.arrow_back).first;
      expect(homeTab, findsOneWidget);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // Verify we're back on the home screen
      stamp('TEST_SCREEN', 'Verifying return to home screen');
      expect(find.byType(AppBar), findsOneWidget);

      stamp(
        'INTEGRATION_TEST',
        'Mobile integration test completed successfully',
      );
    });
  });
}
