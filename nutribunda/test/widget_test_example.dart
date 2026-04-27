import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Testing Examples', () {
    testWidgets('simple widget test', (WidgetTester tester) async {
      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Hello NutriBunda'),
            ),
          ),
        ),
      );

      // Verify the widget is displayed
      expect(find.text('Hello NutriBunda'), findsOneWidget);
      expect(find.text('Wrong Text'), findsNothing);
    });

    testWidgets('button tap test', (WidgetTester tester) async {
      // Arrange
      int counter = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Counter: $counter'),
                  ElevatedButton(
                    onPressed: () {
                      counter++;
                    },
                    child: const Text('Increment'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);

      // Act - tap the button
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Note: In a real StatefulWidget, the counter would update
      // This is just a demonstration of widget interaction
    });

    testWidgets('text field input test', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
          ),
        ),
      );

      // Act - enter text
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Assert
      expect(controller.text, equals('test@example.com'));
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('find by key test', (WidgetTester tester) async {
      // Arrange
      const testKey = Key('test_button');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              key: testKey,
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byKey(testKey), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('scroll test example', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify first item is visible
      expect(find.text('Item 0'), findsOneWidget);
      
      // Verify last item is not visible yet
      expect(find.text('Item 99'), findsNothing);

      // Act - scroll to the end
      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pumpAndSettle();

      // Assert - last item should now be visible
      expect(find.text('Item 99'), findsOneWidget);
    });
  });

  group('Golden Tests Example', () {
    testWidgets('golden test example', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('NutriBunda'),
            ),
            body: const Center(
              child: Text('Welcome'),
            ),
          ),
        ),
      );

      // Compare with golden file
      // await expectLater(
      //   find.byType(Scaffold),
      //   matchesGoldenFile('goldens/home_screen.png'),
      // );
      
      // Placeholder assertion
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
