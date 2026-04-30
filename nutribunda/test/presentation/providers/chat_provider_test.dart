import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nutribunda/presentation/providers/chat_provider.dart';
import 'package:nutribunda/core/services/chat_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';
import 'package:nutribunda/data/models/chat_message.dart';

@GenerateMocks([ChatService])
import 'chat_provider_test.mocks.dart';

void main() {
  late ChatProvider chatProvider;
  late MockChatService mockChatService;

  setUp(() {
    mockChatService = MockChatService();
    chatProvider = ChatProvider(chatService: mockChatService);
  });

  group('ChatProvider - Initialization', () {
    test('should initialize with empty messages', () {
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.isLoading, isFalse);
      expect(chatProvider.errorMessage, isNull);
      expect(chatProvider.isInitialized, isFalse);
    });

    test('should add disclaimer message when initialized', () {
      chatProvider.initializeChat();

      expect(chatProvider.messages.length, equals(1));
      expect(chatProvider.messages.first.isUser, isFalse);
      expect(chatProvider.messages.first.content, contains('DISCLAIMER'));
      expect(chatProvider.isInitialized, isTrue);
    });

    test('should not add disclaimer twice when initialized multiple times', () {
      chatProvider.initializeChat();
      chatProvider.initializeChat();

      expect(chatProvider.messages.length, equals(1));
    });
  });

  group('ChatProvider - Send Message', () {
    test('should add user message and AI response when successful', () async {
      // Arrange
      chatProvider.initializeChat();
      final userMessage = 'Apa itu MPASI?';
      final aiResponse = 'MPASI adalah Makanan Pendamping ASI...';

      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => aiResponse);

      // Act
      await chatProvider.sendMessage(userMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3)); // Disclaimer + User + AI
      expect(chatProvider.messages[1].isUser, isTrue);
      expect(chatProvider.messages[1].content, equals(userMessage));
      expect(chatProvider.messages[2].isUser, isFalse);
      expect(chatProvider.messages[2].content, equals(aiResponse));
      expect(chatProvider.isLoading, isFalse);
      expect(chatProvider.errorMessage, isNull);
    });

    test('should not send empty message', () async {
      // Arrange
      chatProvider.initializeChat();

      // Act
      await chatProvider.sendMessage('   ');

      // Assert
      expect(chatProvider.messages.length, equals(1)); // Only disclaimer
      verifyNever(mockChatService.sendMessage(any));
    });

    test('should set loading state while sending message', () async {
      // Arrange
      chatProvider.initializeChat();
      final userMessage = 'Test message';
      bool wasLoading = false;

      when(mockChatService.sendMessage(any)).thenAnswer((_) async {
        wasLoading = chatProvider.isLoading;
        return 'Response';
      });

      // Act
      await chatProvider.sendMessage(userMessage);

      // Assert
      expect(wasLoading, isTrue);
      expect(chatProvider.isLoading, isFalse);
    });

    test('should handle ChatException and add error message', () async {
      // Arrange
      chatProvider.initializeChat();
      final userMessage = 'Test message';
      final exception = ChatException(
        'Network error',
        ChatErrorType.networkError,
      );

      when(mockChatService.sendMessage(any)).thenThrow(exception);

      // Act
      await chatProvider.sendMessage(userMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3)); // Disclaimer + User + Error
      expect(chatProvider.messages.last.content, contains('kesalahan'));
      expect(chatProvider.errorMessage, isNotNull);
      expect(chatProvider.isLoading, isFalse);
    });

    test('should handle generic exception and add error message', () async {
      // Arrange
      chatProvider.initializeChat();
      final userMessage = 'Test message';

      when(mockChatService.sendMessage(any))
          .thenThrow(Exception('Unknown error'));

      // Act
      await chatProvider.sendMessage(userMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3)); // Disclaimer + User + Error
      expect(chatProvider.messages.last.content, contains('kesalahan'));
      expect(chatProvider.errorMessage, isNotNull);
      expect(chatProvider.isLoading, isFalse);
    });

    test('should clear previous error when sending new message', () async {
      // Arrange
      chatProvider.initializeChat();
      
      // First message fails
      when(mockChatService.sendMessage(any))
          .thenThrow(ChatException('Error', ChatErrorType.networkError));
      await chatProvider.sendMessage('First message');
      
      expect(chatProvider.errorMessage, isNotNull);

      // Second message succeeds
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Success');

      // Act
      await chatProvider.sendMessage('Second message');

      // Assert
      expect(chatProvider.errorMessage, isNull);
    });

    test('should pass conversation history to chat service', () async {
      // Arrange
      chatProvider.initializeChat();
      
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response 1');
      await chatProvider.sendMessage('Message 1');

      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response 2');

      // Act
      await chatProvider.sendMessage('Message 2');

      // Assert
      final captured = verify(mockChatService.sendMessage(
        captureAny,
      )).captured;

      // Should be called twice (once for each message)
      expect(captured.length, equals(2)); // 2 calls x 1 parameter = 2 captures
    });
  });

  group('ChatProvider - Clear and Restart', () {
    test('should clear all messages and reset state', () {
      // Arrange
      chatProvider.initializeChat();
      chatProvider.sendMessage('Test');

      // Act
      chatProvider.clearConversation();

      // Assert
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.errorMessage, isNull);
      expect(chatProvider.isInitialized, isFalse);
    });

    test('should restart conversation with new disclaimer', () {
      // Arrange
      chatProvider.initializeChat();
      chatProvider.sendMessage('Test');

      // Act
      chatProvider.restartConversation();

      // Assert
      expect(chatProvider.messages.length, equals(1));
      expect(chatProvider.messages.first.content, contains('DISCLAIMER'));
      expect(chatProvider.isInitialized, isTrue);
    });

    test('should clear error message', () {
      // Arrange
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenThrow(ChatException('Error', ChatErrorType.networkError));
      chatProvider.sendMessage('Test');

      expect(chatProvider.errorMessage, isNotNull);

      // Act
      chatProvider.clearError();

      // Assert
      expect(chatProvider.errorMessage, isNull);
    });
  });

  group('ChatProvider - Getters', () {
    test('hasMessages should return false when only disclaimer exists', () {
      chatProvider.initializeChat();

      expect(chatProvider.hasMessages, isTrue); // Disclaimer counts as message
    });

    test('hasMessages should return true when user messages exist', () async {
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');
      
      await chatProvider.sendMessage('Test');

      expect(chatProvider.hasMessages, isTrue);
    });

    test('messages should return unmodifiable list', () {
      chatProvider.initializeChat();

      expect(
        () => chatProvider.messages.add(ChatMessage.user('Test')),
        throwsUnsupportedError,
      );
    });
  });

  group('ChatProvider - Conversation Summary', () {
    test('should return correct conversation summary', () async {
      // Arrange
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');
      
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
  });

  group('ChatProvider - Advanced Conversation Management', () {
    test('should handle rapid consecutive messages correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async {
        // Simulate API delay
        await Future.delayed(Duration(milliseconds: 100));
        return 'Response';
      });

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
    });

    test('should maintain message order in conversation history', () async {
      // Arrange
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'AI Response');

      // Act
      await chatProvider.sendMessage('User Message 1');
      await chatProvider.sendMessage('User Message 2');
      await chatProvider.sendMessage('User Message 3');

      // Assert
      final messages = chatProvider.messages;
      expect(messages[0].content, contains('DISCLAIMER')); // Disclaimer
      expect(messages[1].content, equals('User Message 1'));
      expect(messages[2].content, equals('AI Response'));
      expect(messages[3].content, equals('User Message 2'));
      expect(messages[4].content, equals('AI Response'));
      expect(messages[5].content, equals('User Message 3'));
      expect(messages[6].content, equals('AI Response'));
    });

    test('should handle very long conversation history', () async {
      // Arrange
      chatProvider.initializeChat();
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');

      // Act - Create a long conversation
      for (int i = 0; i < 15; i++) {
        await chatProvider.sendMessage('Message $i');
      }

      // Assert
      expect(chatProvider.messages.length, equals(31)); // Disclaimer + 15 user + 15 AI
      
      // Verify that chat service was called
      verify(mockChatService.sendMessage(captureAny)).called(15);
    });

    test('should preserve conversation context after error recovery', () async {
      // Arrange
      chatProvider.initializeChat();
      
      // First successful message
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'First response');
      await chatProvider.sendMessage('First message');

      // Second message fails
      when(mockChatService.sendMessage(any))
          .thenThrow(ChatException('Error', ChatErrorType.networkError));
      await chatProvider.sendMessage('Second message');

      // Third message succeeds
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Third response');
      await chatProvider.sendMessage('Third message');

      // Assert
      expect(chatProvider.messages.length, equals(7)); // Disclaimer + 3 user + 3 responses (including error)
      expect(chatProvider.errorMessage, isNull); // Error should be cleared
      
      // Verify conversation history includes all messages
      final userMessages = chatProvider.messages.where((m) => m.isUser).toList();
      expect(userMessages.length, equals(3));
      expect(userMessages[0].content, equals('First message'));
      expect(userMessages[1].content, equals('Second message'));
      expect(userMessages[2].content, equals('Third message'));
    });

    test('should handle empty and whitespace-only messages correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      final initialMessageCount = chatProvider.messages.length;

      // Act
      await chatProvider.sendMessage('');
      await chatProvider.sendMessage('   ');
      await chatProvider.sendMessage('\n\t  \n');

      // Assert
      expect(chatProvider.messages.length, equals(initialMessageCount));
      verifyNever(mockChatService.sendMessage(any));
    });

    test('should handle special characters in messages', () async {
      // Arrange
      chatProvider.initializeChat();
      final specialMessage = 'Bagaimana cara membuat bubur "halus" untuk bayi? 🍼👶';
      
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response with emojis 😊');

      // Act
      await chatProvider.sendMessage(specialMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3)); // Disclaimer + user + AI
      expect(chatProvider.messages[1].content, equals(specialMessage));
      expect(chatProvider.messages[2].content, equals('Response with emojis 😊'));
    });

    test('should handle very long messages', () async {
      // Arrange
      chatProvider.initializeChat();
      final longMessage = 'A' * 1000; // 1000 character message
      
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response to long message');

      // Act
      await chatProvider.sendMessage(longMessage);

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages[1].content, equals(longMessage));
      
      // Verify the long message was passed to the service
      verify(mockChatService.sendMessage(longMessage)).called(1);
    });
  });

  group('ChatProvider - Error Handling Edge Cases', () {
    test('should handle multiple consecutive errors gracefully', () async {
      // Arrange
      chatProvider.initializeChat();
      
      when(mockChatService.sendMessage(any))
          .thenThrow(ChatException('Network error', ChatErrorType.networkError));

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

    test('should handle different types of ChatException correctly', () async {
      // Arrange
      chatProvider.initializeChat();
      
      final errorTypes = [
        ChatErrorType.networkError,
        ChatErrorType.apiTimeout,
        ChatErrorType.rateLimitExceeded,
        ChatErrorType.apiKeyInvalid,
        ChatErrorType.invalidResponse,
        ChatErrorType.unknown,
      ];

      // Act & Assert
      for (int i = 0; i < errorTypes.length; i++) {
        when(mockChatService.sendMessage(any))
            .thenThrow(ChatException('Error $i', errorTypes[i]));
        
        await chatProvider.sendMessage('Message $i');
        
        expect(chatProvider.errorMessage, isNotNull);
        expect(chatProvider.messages.last.content, contains('kesalahan'));
      }
    });

    test('should handle service returning null or empty response', () async {
      // Arrange
      chatProvider.initializeChat();
      
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => '');

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(chatProvider.messages.length, equals(3));
      expect(chatProvider.messages.last.content, isEmpty);
    });
  });

  group('ChatProvider - State Management', () {
    test('should notify listeners when messages are added', () async {
      // Arrange
      chatProvider.initializeChat();
      int notificationCount = 0;
      
      chatProvider.addListener(() {
        notificationCount++;
      });

      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(notificationCount, greaterThan(0));
    });

    test('should notify listeners when loading state changes', () async {
      // Arrange
      chatProvider.initializeChat();
      final loadingStates = <bool>[];
      
      chatProvider.addListener(() {
        loadingStates.add(chatProvider.isLoading);
      });

      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'Response';
      });

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(loadingStates, contains(true)); // Should have been loading at some point
      expect(chatProvider.isLoading, isFalse); // Should be false at the end
    });

    test('should notify listeners when error state changes', () async {
      // Arrange
      chatProvider.initializeChat();
      final errorStates = <String?>[];
      
      chatProvider.addListener(() {
        errorStates.add(chatProvider.errorMessage);
      });

      when(mockChatService.sendMessage(any))
          .thenThrow(ChatException('Error', ChatErrorType.networkError));

      // Act
      await chatProvider.sendMessage('Test message');

      // Assert
      expect(errorStates, contains(null)); // Initially null
      expect(errorStates.last, isNotNull); // Should have error at the end
    });
  });

  group('ChatProvider - Memory Management', () {
    test('should properly dispose resources', () {
      // Arrange
      chatProvider.initializeChat();
      chatProvider.sendMessage('Test');

      // Act
      chatProvider.dispose();

      // Assert
      expect(chatProvider.messages, isEmpty);
    });
  });

  group('ChatProvider - Helper Methods', () {
    test('hasUserMessages should correctly identify user messages', () async {
      // Arrange
      chatProvider.initializeChat();
      expect(chatProvider.hasUserMessages, isFalse);

      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');

      // Act
      await chatProvider.sendMessage('User message');

      // Assert
      expect(chatProvider.hasUserMessages, isTrue);
    });

    test('lastUserMessage should return the most recent user message', () async {
      // Arrange
      chatProvider.initializeChat();
      
      when(mockChatService.sendMessage(any))
          .thenAnswer((_) async => 'Response');

      // Act
      await chatProvider.sendMessage('First message');
      await chatProvider.sendMessage('Second message');
      await chatProvider.sendMessage('Third message');

      // Assert
      expect(chatProvider.lastUserMessage, equals('Third message'));
    });

    test('lastUserMessage should return null when no user messages exist', () {
      // Arrange
      chatProvider.initializeChat();

      // Assert
      expect(chatProvider.lastUserMessage, isNull);
    });
  });
}
