import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/providers/chat_provider.dart';
import 'package:nutribunda/core/services/chat_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';
import 'package:nutribunda/data/models/chat_message.dart';

// Simple mock service for testing
class TestChatService implements ChatService {
  bool shouldThrowError = false;
  ChatErrorType? errorType;
  String? customResponse;
  Duration delay = const Duration(milliseconds: 10); // Shorter delay for tests

  @override
  Future<String> sendMessage(String message, List<ChatMessage> conversationHistory) async {
    // Simulate API delay
    await Future.delayed(delay);
    
    if (shouldThrowError) {
      throw ChatException('Test error', errorType ?? ChatErrorType.networkError);
    }
    
    if (customResponse != null) {
      return customResponse!;
    }
    
    // Default response based on message content
    if (message.toLowerCase().contains('mpasi')) {
      return 'MPASI adalah Makanan Pendamping ASI yang diberikan kepada bayi usia 6-24 bulan untuk memenuhi kebutuhan nutrisi yang tidak lagi dapat dipenuhi oleh ASI saja.';
    } else if (message.toLowerCase().contains('ibu menyusui')) {
      return 'Ibu menyusui membutuhkan nutrisi yang cukup untuk mendukung produksi ASI dan pemulihan pasca melahirkan. Konsumsi makanan bergizi seimbang sangat penting.';
    } else {
      return 'Terima kasih atas pertanyaan Anda: "$message". Ini adalah respons dari TanyaBunda AI.';
    }
  }

  void reset() {
    shouldThrowError = false;
    errorType = null;
    customResponse = null;
    delay = const Duration(milliseconds: 10);
  }
}

void main() {
  group('Chat Integration Tests - Core Functionality', () {
    late TestChatService testChatService;
    late ChatProvider chatProvider;

    setUp(() {
      testChatService = TestChatService();
      chatProvider = ChatProvider(chatService: testChatService);
    });

    test('should initialize chat with disclaimer message', () {
      // Act
      chatProvider.initializeChat();

      // Assert
      expect(chatProvider.isInitialized, isTrue);
      expect(chatProvider.messages.length, equals(1));
      expect(chatProvider.messages.first.content, contains('DISCLAIMER'));
      expect(chatProvider.messages.first.isUser, isFalse);
    });

    test('should send message and receive response', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act
      await chatProvider.sendMessage('Apa itu MPASI?');

      // Assert
      expect(chatProvider.messages.length, equals(3)); // disclaimer + user + AI
      expect(chatProvider.messages[1].content, equals('Apa itu MPASI?'));
      expect(chatProvider.messages[1].isUser, isTrue);
      expect(chatProvider.messages[2].content, contains('MPASI adalah Makanan Pendamping ASI'));
      expect(chatProvider.messages[2].isUser, isFalse);
      expect(chatProvider.isLoading, isFalse);
    });

    test('should handle MPASI-related questions correctly', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act
      await chatProvider.sendMessage('Apa itu MPASI?'); // This should trigger MPASI response

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages.last.content, contains('MPASI adalah Makanan Pendamping ASI'));
      expect(chatProvider.messages.last.content, contains('6-24 bulan'));
    });

    test('should handle breastfeeding mother questions correctly', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act
      await chatProvider.sendMessage('Makanan apa yang baik untuk ibu menyusui?');

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages.last.content, contains('Ibu menyusui membutuhkan nutrisi'));
      expect(chatProvider.messages.last.content, contains('produksi ASI'));
    });

    test('should maintain conversation context across multiple messages', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act - Send multiple related messages
      await chatProvider.sendMessage('Apa itu MPASI?');
      await chatProvider.sendMessage('Kapan mulai memberikannya?');
      await chatProvider.sendMessage('Berapa kali sehari?');

      // Assert
      expect(chatProvider.messages.length, equals(7)); // Disclaimer + 3 user + 3 AI
      
      // Check that all messages are preserved
      final userMessages = chatProvider.messages.where((m) => m.isUser).toList();
      expect(userMessages[0].content, equals('Apa itu MPASI?'));
      expect(userMessages[1].content, equals('Kapan mulai memberikannya?'));
      expect(userMessages[2].content, equals('Berapa kali sehari?'));
    });

    test('should handle special characters in messages', () async {
      // Arrange
      chatProvider.initializeChat();
      final specialMessage = 'Bagaimana cara membuat bubur "halus" untuk bayi? 🍼👶';

      // Act
      await chatProvider.sendMessage(specialMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages[1].content, equals(specialMessage));
      expect(chatProvider.messages[2].content, contains('Terima kasih'));
    });

    test('should handle very long messages', () async {
      // Arrange
      chatProvider.initializeChat();
      final longMessage = 'A' * 500; // Very long message

      // Act
      await chatProvider.sendMessage(longMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages[1].content, equals(longMessage));
      expect(chatProvider.messages[2].content, contains('Terima kasih'));
    });

    test('should not send empty messages', () async {
      // Arrange
      chatProvider.initializeChat();
      final initialMessageCount = chatProvider.messages.length;

      // Act
      await chatProvider.sendMessage('');
      await chatProvider.sendMessage('   ');
      await chatProvider.sendMessage('\n\t  \n');

      // Assert
      expect(chatProvider.messages.length, equals(initialMessageCount));
    });
  });

  group('Chat Integration Tests - Error Handling', () {
    late TestChatService testChatService;
    late ChatProvider chatProvider;

    setUp(() {
      testChatService = TestChatService();
      chatProvider = ChatProvider(chatService: testChatService);
    });

    test('should handle network error gracefully', () async {
      // Arrange
      chatProvider.initializeChat();
      testChatService.shouldThrowError = true;
      testChatService.errorType = ChatErrorType.networkError;

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(chatProvider.messages.length, equals(3)); // Disclaimer + user + error response
      expect(chatProvider.messages.last.content, contains('kesalahan'));
      expect(chatProvider.errorMessage, isNotNull);
      expect(chatProvider.errorMessage, contains('koneksi internet'));
    });

    test('should handle timeout error gracefully', () async {
      // Arrange
      chatProvider.initializeChat();
      testChatService.shouldThrowError = true;
      testChatService.errorType = ChatErrorType.apiTimeout;

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages.last.content, contains('kesalahan'));
      expect(chatProvider.errorMessage, isNotNull);
      expect(chatProvider.errorMessage, contains('terlalu lama'));
    });

    test('should handle rate limit error gracefully', () async {
      // Arrange
      chatProvider.initializeChat();
      testChatService.shouldThrowError = true;
      testChatService.errorType = ChatErrorType.rateLimitExceeded;

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages.last.content, contains('kesalahan'));
      expect(chatProvider.errorMessage, isNotNull);
      expect(chatProvider.errorMessage, contains('Terlalu banyak permintaan'));
    });

    test('should recover from error and send next message successfully', () async {
      // Arrange
      chatProvider.initializeChat();
      testChatService.shouldThrowError = true;
      testChatService.errorType = ChatErrorType.networkError;

      // Act - First message fails
      await chatProvider.sendMessage('First message');

      // Reset error state
      testChatService.reset();

      // Second message succeeds
      await chatProvider.sendMessage('Second message');

      // Assert
      expect(chatProvider.messages.length, equals(5)); // Disclaimer + 2 user + 2 responses (1 error, 1 success)
      expect(chatProvider.errorMessage, isNull); // Error should be cleared
      expect(chatProvider.messages.last.content, contains('Terima kasih'));
    });

    test('should handle multiple consecutive errors', () async {
      // Arrange
      chatProvider.initializeChat();
      testChatService.shouldThrowError = true;
      testChatService.errorType = ChatErrorType.networkError;

      // Act
      await chatProvider.sendMessage('Message 1');
      await chatProvider.sendMessage('Message 2');
      await chatProvider.sendMessage('Message 3');

      // Assert
      expect(chatProvider.messages.length, equals(7)); // Disclaimer + 3 user + 3 error responses
      expect(chatProvider.errorMessage, isNotNull);
      
      // All AI responses should be error messages
      final aiMessages = chatProvider.messages.where((m) => !m.isUser).toList();
      expect(aiMessages.length, equals(4)); // Disclaimer + 3 error responses
      
      for (int i = 1; i < aiMessages.length; i++) {
        expect(aiMessages[i].content, contains('kesalahan'));
      }
    });
  });

  group('Chat Integration Tests - Conversation Management', () {
    late TestChatService testChatService;
    late ChatProvider chatProvider;

    setUp(() {
      testChatService = TestChatService();
      chatProvider = ChatProvider(chatService: testChatService);
    });

    test('should clear conversation correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      await chatProvider.sendMessage('Test message');
      expect(chatProvider.messages.length, greaterThan(1));

      // Act
      chatProvider.clearConversation();

      // Assert
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.errorMessage, isNull);
      expect(chatProvider.isInitialized, isFalse);
    });

    test('should restart conversation correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      await chatProvider.sendMessage('Test message');
      expect(chatProvider.messages.length, greaterThan(1));

      // Act
      chatProvider.restartConversation();

      // Assert
      expect(chatProvider.messages.length, equals(1));
      expect(chatProvider.messages.first.content, contains('DISCLAIMER'));
      expect(chatProvider.isInitialized, isTrue);
      expect(chatProvider.errorMessage, isNull);
    });

    test('should handle rapid consecutive messages correctly', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act - Send multiple messages rapidly
      final futures = [
        chatProvider.sendMessage('Message 1'),
        chatProvider.sendMessage('Message 2'),
        chatProvider.sendMessage('Message 3'),
      ];

      await Future.wait(futures);

      // Assert
      expect(chatProvider.messages.length, equals(7)); // Disclaimer + 3 user + 3 AI
      expect(chatProvider.isLoading, isFalse);
      
      // Verify all messages are present
      final userMessages = chatProvider.messages.where((m) => m.isUser).toList();
      expect(userMessages.length, equals(3));
      expect(userMessages[0].content, equals('Message 1'));
      expect(userMessages[1].content, equals('Message 2'));
      expect(userMessages[2].content, equals('Message 3'));
    });

    test('should provide correct conversation summary', () async {
      // Arrange
      chatProvider.initializeChat();
      await chatProvider.sendMessage('Test 1');
      await chatProvider.sendMessage('Test 2');

      // Act
      final summary = chatProvider.getConversationSummary();

      // Assert
      expect(summary, contains('Total messages: 5')); // Disclaimer + 2 user + 2 AI
      expect(summary, contains('User messages: 2'));
      expect(summary, contains('AI messages: 3')); // Disclaimer + 2 responses
      expect(summary, contains('Is loading: false'));
    });

    test('should track user messages correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      expect(chatProvider.hasUserMessages, isFalse);
      expect(chatProvider.lastUserMessage, isNull);

      // Act
      await chatProvider.sendMessage('First message');
      await chatProvider.sendMessage('Second message');

      // Assert
      expect(chatProvider.hasUserMessages, isTrue);
      expect(chatProvider.lastUserMessage, equals('Second message'));
    });
  });
}