import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/presentation/widgets/chat/chat_message_bubble.dart';
import 'package:nutribunda/data/models/chat_message.dart';

void main() {
  group('ChatMessageBubble Widget Tests', () {
    testWidgets('should display user message correctly', (WidgetTester tester) async {
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

    testWidgets('should display AI message correctly', (WidgetTester tester) async {
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

    testWidgets('should show copy button only for AI messages', (WidgetTester tester) async {
      // Test AI message has copy button
      final aiMessage = ChatMessage.ai('AI response');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessage),
          ),
        ),
      );
      expect(find.byIcon(Icons.copy), findsOneWidget);

      // Test user message doesn't have copy button
      final userMessage = ChatMessage.user('User message');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: userMessage),
          ),
        ),
      );
      expect(find.byIcon(Icons.copy), findsNothing);
    });

    testWidgets('should copy message to clipboard when copy button tapped', (WidgetTester tester) async {
      // Arrange
      final aiMessage = ChatMessage.ai('Message to copy');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: aiMessage),
          ),
        ),
      );

      // Tap copy button
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      // Assert - should show snackbar
      expect(find.text('Pesan disalin ke clipboard'), findsOneWidget);
    });

    testWidgets('should display timestamp correctly', (WidgetTester tester) async {
      // Arrange
      final message = ChatMessage.user('Test message');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageBubble(message: message),
          ),
        ),
      );

      // Assert - should show "Baru saja" for recent messages
      expect(find.text('Baru saja'), findsOneWidget);
    });
  });
}