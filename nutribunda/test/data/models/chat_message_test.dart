import 'package:flutter_test/flutter_test.dart';
import 'package:nutribunda/data/models/chat_message.dart';

void main() {
  group('ChatMessage Model Tests', () {
    group('Constructor Tests', () {
      test('should create user message correctly', () {
        // Arrange
        final content = 'Apa itu MPASI?';
        final beforeCreation = DateTime.now();

        // Act
        final message = ChatMessage.user(content);
        final afterCreation = DateTime.now();

        // Assert
        expect(message.content, equals(content));
        expect(message.isUser, isTrue);
        expect(message.id, isNotEmpty);
        expect(message.timestamp.isAfter(beforeCreation) || 
               message.timestamp.isAtSameMomentAs(beforeCreation), isTrue);
        expect(message.timestamp.isBefore(afterCreation) || 
               message.timestamp.isAtSameMomentAs(afterCreation), isTrue);
      });

      test('should create AI message correctly', () {
        // Arrange
        final content = 'MPASI adalah Makanan Pendamping ASI...';
        final beforeCreation = DateTime.now();

        // Act
        final message = ChatMessage.ai(content);
        final afterCreation = DateTime.now();

        // Assert
        expect(message.content, equals(content));
        expect(message.isUser, isFalse);
        expect(message.id, isNotEmpty);
        expect(message.timestamp.isAfter(beforeCreation) || 
               message.timestamp.isAtSameMomentAs(beforeCreation), isTrue);
        expect(message.timestamp.isBefore(afterCreation) || 
               message.timestamp.isAtSameMomentAs(afterCreation), isTrue);
      });

      test('should generate unique IDs for different messages', () async {
        // Act
        final message1 = ChatMessage.user('Message 1');
        // Small delay to ensure different timestamps and IDs
        await Future.delayed(Duration(milliseconds: 2));
        final message2 = ChatMessage.user('Message 2');

        // Assert
        expect(message1.id, isNot(equals(message2.id)));
      });
    });

    group('Gemini API Format Tests', () {
      test('should convert user message to correct Gemini format', () {
        // Arrange
        final message = ChatMessage.user('Apa itu MPASI?');

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat, isA<Map<String, dynamic>>());
        expect(geminiFormat['role'], equals('user'));
        expect(geminiFormat['parts'], isA<List>());
        expect(geminiFormat['parts'].length, equals(1));
        expect(geminiFormat['parts'][0], isA<Map<String, dynamic>>());
        expect(geminiFormat['parts'][0]['text'], equals('Apa itu MPASI?'));
      });

      test('should convert AI message to correct Gemini format', () {
        // Arrange
        final message = ChatMessage.ai('MPASI adalah Makanan Pendamping ASI...');

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat, isA<Map<String, dynamic>>());
        expect(geminiFormat['role'], equals('model'));
        expect(geminiFormat['parts'], isA<List>());
        expect(geminiFormat['parts'].length, equals(1));
        expect(geminiFormat['parts'][0], isA<Map<String, dynamic>>());
        expect(geminiFormat['parts'][0]['text'], equals('MPASI adalah Makanan Pendamping ASI...'));
      });

      test('should handle empty content in Gemini format', () {
        // Arrange
        final message = ChatMessage.user('');

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat['parts'][0]['text'], equals(''));
      });

      test('should handle special characters in Gemini format', () {
        // Arrange
        final specialContent = 'Bagaimana cara membuat bubur "halus" untuk bayi? 🍼👶';
        final message = ChatMessage.user(specialContent);

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat['parts'][0]['text'], equals(specialContent));
      });

      test('should handle very long content in Gemini format', () {
        // Arrange
        final longContent = 'A' * 1000;
        final message = ChatMessage.user(longContent);

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat['parts'][0]['text'], equals(longContent));
      });

      test('should handle newlines and special formatting in Gemini format', () {
        // Arrange
        final formattedContent = '''
        Ini adalah pesan dengan:
        - Baris baru
        - Tab\t\tdan spasi
        - Karakter khusus: @#\$%^&*()
        ''';
        final message = ChatMessage.user(formattedContent);

        // Act
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(geminiFormat['parts'][0]['text'], equals(formattedContent));
      });
    });

    group('JSON Serialization Tests', () {
      test('should convert to JSON correctly', () {
        // Arrange
        final message = ChatMessage.user('Test message');

        // Act
        final json = message.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['content'], equals('Test message'));
        expect(json['isUser'], isTrue);
        expect(json['id'], isNotEmpty);
        expect(json['timestamp'], isA<String>());
      });

      test('should create from JSON correctly', () {
        // Arrange
        final timestamp = DateTime.parse('2024-01-01T12:00:00Z');
        final json = {
          'id': 'test-id-123',
          'content': 'Test message',
          'isUser': true,
          'timestamp': timestamp.toIso8601String(),
        };

        // Act
        final message = ChatMessage.fromJson(json);

        // Assert
        expect(message.id, equals('test-id-123'));
        expect(message.content, equals('Test message'));
        expect(message.isUser, isTrue);
        expect(message.timestamp, equals(timestamp));
      });

      test('should handle JSON roundtrip correctly', () {
        // Arrange
        final originalMessage = ChatMessage.ai('AI response message');

        // Act
        final json = originalMessage.toJson();
        final reconstructedMessage = ChatMessage.fromJson(json);

        // Assert
        expect(reconstructedMessage.content, equals(originalMessage.content));
        expect(reconstructedMessage.isUser, equals(originalMessage.isUser));
        expect(reconstructedMessage.id, equals(originalMessage.id));
        expect(reconstructedMessage.timestamp, equals(originalMessage.timestamp));
      });

      test('should handle malformed JSON gracefully', () {
        // Arrange
        final malformedJson = {
          'content': 'Test message',
          // Missing required fields
        };

        // Act & Assert
        expect(() => ChatMessage.fromJson(malformedJson), throwsA(isA<TypeError>()));
      });
    });

    group('Equality and Comparison Tests', () {
      test('should compare messages correctly by content and type', () async {
        // Arrange
        final message1 = ChatMessage.user('Same content');
        await Future.delayed(Duration(milliseconds: 2));
        final message2 = ChatMessage.user('Same content');
        final message3 = ChatMessage.ai('Same content');
        final message4 = ChatMessage.user('Different content');

        // Assert
        expect(message1.content, equals(message2.content));
        expect(message1.isUser, equals(message2.isUser));
        
        expect(message1.isUser, isNot(equals(message3.isUser)));
        expect(message1.content, isNot(equals(message4.content)));
        
        // IDs should be different even for same content
        expect(message1.id, isNot(equals(message2.id)));
      });

      test('should handle timestamp comparison correctly', () async {
        // Arrange
        final message1 = ChatMessage.user('Test 1');
        // Small delay to ensure different timestamps
        await Future.delayed(Duration(milliseconds: 1));
        final message2 = ChatMessage.user('Test 2');

        // Assert
        expect(message1.timestamp.isBefore(message2.timestamp) ||
               message1.timestamp.isAtSameMomentAs(message2.timestamp), isTrue);
      });

      test('should implement equality correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'content': 'Test message',
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String(),
        };
        final message1 = ChatMessage.fromJson(json);
        final message2 = ChatMessage.fromJson(json);

        // Assert
        expect(message1, equals(message2));
        expect(message1.hashCode, equals(message2.hashCode));
      });
    });

    group('Edge Cases and Validation Tests', () {
      test('should handle null content gracefully', () {
        // Act & Assert
        expect(() => ChatMessage.user(null as dynamic), throwsA(isA<TypeError>()));
      });

      test('should handle extremely long content', () {
        // Arrange
        final extremelyLongContent = 'A' * 100000; // 100k characters

        // Act
        final message = ChatMessage.user(extremelyLongContent);

        // Assert
        expect(message.content, equals(extremelyLongContent));
        expect(message.content.length, equals(100000));
      });

      test('should handle content with only whitespace', () {
        // Arrange
        final whitespaceContent = '   \n\t   \n   ';

        // Act
        final message = ChatMessage.user(whitespaceContent);

        // Assert
        expect(message.content, equals(whitespaceContent));
      });

      test('should handle Unicode characters correctly', () {
        // Arrange
        final unicodeContent = '🍼 MPASI untuk bayi 👶 dengan emoji 😊 dan karakter khusus: ñáéíóú';

        // Act
        final message = ChatMessage.user(unicodeContent);
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(message.content, equals(unicodeContent));
        expect(geminiFormat['parts'][0]['text'], equals(unicodeContent));
      });

      test('should handle HTML-like content correctly', () {
        // Arrange
        final htmlContent = '<p>Ini adalah <strong>MPASI</strong> untuk bayi &lt;6 bulan&gt;</p>';

        // Act
        final message = ChatMessage.user(htmlContent);
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(message.content, equals(htmlContent));
        expect(geminiFormat['parts'][0]['text'], equals(htmlContent));
      });

      test('should handle JSON-like content correctly', () {
        // Arrange
        final jsonContent = '{"question": "Apa itu MPASI?", "category": "nutrition"}';

        // Act
        final message = ChatMessage.user(jsonContent);
        final geminiFormat = message.toGeminiFormat();

        // Assert
        expect(message.content, equals(jsonContent));
        expect(geminiFormat['parts'][0]['text'], equals(jsonContent));
      });
    });

    group('Performance Tests', () {
      test('should create messages efficiently', () {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        for (int i = 0; i < 1000; i++) {
          ChatMessage.user('Message $i');
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });

      test('should convert to Gemini format efficiently', () {
        // Arrange
        final messages = List.generate(1000, (i) => ChatMessage.user('Message $i'));
        final stopwatch = Stopwatch()..start();

        // Act
        for (final message in messages) {
          message.toGeminiFormat();
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });

      test('should handle JSON serialization efficiently', () {
        // Arrange
        final messages = List.generate(1000, (i) => ChatMessage.user('Message $i'));
        final stopwatch = Stopwatch()..start();

        // Act
        for (final message in messages) {
          final json = message.toJson();
          ChatMessage.fromJson(json);
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be reasonably fast
      });
    });
  });
}