import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/presentation/widgets/chat/chat_input_field.dart';

void main() {
  group('ChatInputField Widget Tests', () {
    late TextEditingController controller;
    bool sendCalled = false;

    setUp(() {
      controller = TextEditingController();
      sendCalled = false;
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display input field with hint text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Tanya seputar MPASI dan gizi ibu...'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should call onSend when send button tapped with text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert
      expect(sendCalled, isTrue);
    });

    testWidgets('should not call onSend when send button tapped with empty text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert
      expect(sendCalled, isFalse);
    });

    testWidgets('should call onSend when Enter key pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert
      expect(sendCalled, isTrue);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('should disable input when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () => sendCalled = true,
              isLoading: true,
            ),
          ),
        ),
      );

      // Try to enter text
      await tester.enterText(find.byType(TextField), 'Test message');
      
      // Try to tap send button (should be disabled)
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Assert
      expect(sendCalled, isFalse);
    });
  });
}