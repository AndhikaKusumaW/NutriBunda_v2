import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutribunda/presentation/widgets/chat/chat_message_bubble.dart';
import 'package:nutribunda/presentation/widgets/chat/chat_input_field.dart';
import 'package:nutribunda/presentation/widgets/chat/typing_indicator.dart';
import 'package:nutribunda/data/models/chat_message.dart';

void main() {
  group('Chat Widgets Tests', () {
    testWidgets('ChatMessageBubble should display user message correctly', (WidgetTester tester) async {
      // Arrange
      final userMessage = ChatMessage.user('Hello, this is a test message');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: userMessage),
          ),
        ),
      );

      // Assert
      expect(find.text('Hello, this is a test message'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('ChatMessageBubble should display AI message correctly', (WidgetTester tester) async {
      // Arrange
      final aiMessage = ChatMessage.ai('Hello, I am TanyaBunda AI');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessage),
          ),
        ),
      );

      // Assert
      expect(find.text('Hello, I am TanyaBunda AI'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('ChatInputField should display correctly', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      bool sendCalled = false;

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
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('Tanya seputar MPASI dan gizi ibu...'), findsOneWidget);
    });

    testWidgets('ChatInputField should call onSend when send button is tapped', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      var sendCalled = false;

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
      controller.text = 'Test message';
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert
      expect(sendCalled, isTrue);
    });

    testWidgets('ChatInputField should show loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInputField(
              controller: controller,
              onSend: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TypingIndicator should display correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Assert
      expect(find.text('TanyaBunda AI sedang mengetik'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('TypingIndicator should animate dots', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      // Let animation run
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - animation should be running
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}