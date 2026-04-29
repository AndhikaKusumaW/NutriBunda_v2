import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nutribunda/core/services/chat_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';
import 'package:nutribunda/data/models/chat_message.dart';

@GenerateMocks([Dio])
import 'chat_service_test.mocks.dart';

void main() {
  late ChatService chatService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    chatService = ChatService(dio: mockDio);
  });

  group('ChatService - sendMessage', () {
    test('should return AI response when API call is successful', () async {
      // Arrange
      final message = 'Apa itu MPASI?';
      final conversationHistory = <ChatMessage>[];
      
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'MPASI adalah Makanan Pendamping ASI...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await chatService.sendMessage(message, conversationHistory);

      // Assert
      expect(result, 'MPASI adalah Makanan Pendamping ASI...');
      verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).called(1);
    });

    test('should throw ChatException when API returns timeout', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.apiTimeout,
        )),
      );
    });

    test('should throw ChatException when API returns network error', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.networkError,
        )),
      );
    });

    test('should throw ChatException when API returns 429 rate limit', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 429,
          ),
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.rateLimitExceeded,
        )),
      );
    });

    test('should throw ChatException when API returns invalid response format', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [], // Empty candidates
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.invalidResponse,
        )),
      );
    });

    test('should include conversation history in API request', () async {
      // Arrange
      final message = 'Berapa porsi MPASI untuk bayi 6 bulan?';
      final conversationHistory = [
        ChatMessage.user('Apa itu MPASI?'),
        ChatMessage.ai('MPASI adalah Makanan Pendamping ASI...'),
      ];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Untuk bayi 6 bulan, porsi MPASI...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await chatService.sendMessage(message, conversationHistory);

      // Assert
      final captured = verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final requestData = captured[0] as Map<String, dynamic>;
      final contents = requestData['contents'] as List;
      
      // Should include system prompt + acknowledgment + history + current message
      expect(contents.length, greaterThan(2)); // At least system prompt + current message
    });

    test('should limit conversation history to last 10 messages', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = List.generate(
        20,
        (i) => i.isEven
            ? ChatMessage.user('User message $i')
            : ChatMessage.ai('AI message $i'),
      );

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Response'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await chatService.sendMessage(message, conversationHistory);

      // Assert
      final captured = verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final requestData = captured[0] as Map<String, dynamic>;
      final contents = requestData['contents'] as List;
      
      // System prompt (2) + last 10 history + current message = 13
      expect(contents.length, equals(13));
    });
  });

  group('ChatService - Error Messages', () {
    test('should return appropriate error message for network error', () {
      final error = ChatException(
        'Network error',
        ChatErrorType.networkError,
      );

      final message = ChatService.getErrorMessage(error);

      expect(message, contains('koneksi internet'));
    });

    test('should return appropriate error message for timeout', () {
      final error = ChatException(
        'Timeout',
        ChatErrorType.apiTimeout,
      );

      final message = ChatService.getErrorMessage(error);

      expect(message, contains('terlalu lama'));
    });

    test('should return appropriate error message for rate limit', () {
      final error = ChatException(
        'Rate limit',
        ChatErrorType.rateLimitExceeded,
      );

      final message = ChatService.getErrorMessage(error);

      expect(message, contains('Terlalu banyak permintaan'));
    });
  });

  group('ChatService - Disclaimer', () {
    test('should return disclaimer message', () {
      final disclaimer = ChatService.getDisclaimerMessage();

      expect(disclaimer, contains('DISCLAIMER'));
      expect(disclaimer, contains('konsultasi medis profesional'));
      expect(disclaimer, contains('MPASI'));
      expect(disclaimer, contains('Diet pemulihan ibu pasca-melahirkan'));
    });
  });

  group('ChatService - System Prompt', () {
    test('system prompt should contain required topics', () {
      expect(ChatService.systemPrompt, contains('MPASI'));
      expect(ChatService.systemPrompt, contains('bayi usia 6-24 bulan'));
      expect(ChatService.systemPrompt, contains('Diet pemulihan ibu pasca-melahirkan'));
      expect(ChatService.systemPrompt, contains('Bahasa Indonesia'));
      expect(ChatService.systemPrompt, contains('konsultasi medis profesional'));
    });
  });

  group('ChatService - Topic Limitation', () {
    test('should handle MPASI-related questions appropriately', () async {
      // Arrange
      final message = 'Kapan bayi boleh makan nasi?';
      final conversationHistory = <ChatMessage>[];
      
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Bayi dapat mulai makan nasi pada usia 6 bulan...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await chatService.sendMessage(message, conversationHistory);

      // Assert
      expect(result, contains('Bayi dapat mulai makan nasi'));
      
      // Verify system prompt is included in request
      final captured = verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final requestData = captured[0] as Map<String, dynamic>;
      final contents = requestData['contents'] as List;
      final systemMessage = contents.first['parts'][0]['text'] as String;
      
      expect(systemMessage, contains('TanyaBunda AI'));
      expect(systemMessage, contains('MPASI'));
    });

    test('should handle postpartum diet questions appropriately', () async {
      // Arrange
      final message = 'Makanan apa yang baik untuk ibu menyusui?';
      final conversationHistory = <ChatMessage>[];
      
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Ibu menyusui membutuhkan nutrisi yang cukup...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await chatService.sendMessage(message, conversationHistory);

      // Assert
      expect(result, contains('Ibu menyusui membutuhkan nutrisi'));
    });
  });

  group('ChatService - Response Validation', () {
    test('should handle empty response gracefully', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': ''}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.invalidResponse,
        )),
      );
    });

    test('should handle malformed JSON response', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'invalid_field': 'some text'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.invalidResponse,
        )),
      );
    });

    test('should handle response with blocked content', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'finishReason': 'SAFETY',
              'safetyRatings': [
                {
                  'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                  'probability': 'HIGH'
                }
              ]
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.invalidResponse,
        )),
      );
    });
  });

  group('ChatService - Conversation Context', () {
    test('should preserve conversation context across multiple messages', () async {
      // Arrange
      final conversationHistory = [
        ChatMessage.user('Apa itu MPASI?'),
        ChatMessage.ai('MPASI adalah Makanan Pendamping ASI untuk bayi usia 6-24 bulan.'),
        ChatMessage.user('Kapan mulai memberikan MPASI?'),
        ChatMessage.ai('MPASI dapat dimulai pada usia 6 bulan.'),
      ];
      final newMessage = 'Berapa kali sehari memberikannya?';

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Untuk bayi 6 bulan, berikan MPASI 2-3 kali sehari...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await chatService.sendMessage(newMessage, conversationHistory);

      // Assert
      final captured = verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final requestData = captured[0] as Map<String, dynamic>;
      final contents = requestData['contents'] as List;
      
      // Should include system prompt + acknowledgment + conversation history + current message
      expect(contents.length, greaterThan(4));
      
      // Verify conversation history is included
      bool foundUserMessage = false;
      bool foundAiMessage = false;
      
      for (final content in contents) {
        final parts = content['parts'] as List;
        final text = parts[0]['text'] as String;
        final role = content['role'] as String;
        
        if (role == 'user' && text.contains('Apa itu MPASI?')) {
          foundUserMessage = true;
        }
        if (role == 'model' && text.contains('MPASI adalah Makanan Pendamping ASI')) {
          foundAiMessage = true;
        }
      }
      
      expect(foundUserMessage, isTrue);
      expect(foundAiMessage, isTrue);
    });

    test('should handle conversation context with special characters', () async {
      // Arrange
      final conversationHistory = [
        ChatMessage.user('Bagaimana cara membuat bubur "halus" untuk bayi?'),
        ChatMessage.ai('Untuk membuat bubur halus, Anda dapat menggunakan blender...'),
      ];
      final newMessage = 'Apakah boleh menambahkan garam & gula?';

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Tidak disarankan menambahkan garam dan gula...'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await chatService.sendMessage(newMessage, conversationHistory);

      // Assert
      expect(result, contains('Tidak disarankan menambahkan garam'));
    });
  });

  group('ChatService - Error Handling Edge Cases', () {
    test('should handle 401 unauthorized error', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.apiKeyInvalid,
        )),
      );
    });

    test('should handle 403 forbidden error', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
          ),
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.apiKeyInvalid,
        )),
      );
    });

    test('should handle 500 server error', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ),
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.networkError,
        )),
      );
    });

    test('should handle connection timeout specifically', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.apiTimeout,
        )),
      );
    });

    test('should handle send timeout specifically', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.sendTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => chatService.sendMessage(message, conversationHistory),
        throwsA(isA<ChatException>().having(
          (e) => e.type,
          'type',
          ChatErrorType.apiTimeout,
        )),
      );
    });
  });

  group('ChatService - Request Configuration', () {
    test('should configure request with correct headers and parameters', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Response'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await chatService.sendMessage(message, conversationHistory);

      // Assert
      final captured = verify(mockDio.post(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final endpoint = captured[0] as String;
      final queryParams = captured[1] as Map<String, dynamic>;
      final requestData = captured[2] as Map<String, dynamic>;

      expect(endpoint, contains('gemini-pro:generateContent'));
      expect(queryParams, contains('key'));
      expect(requestData.keys, contains('contents'));
      expect(requestData.keys, contains('generationConfig'));
    });

    test('should include generation config in request', () async {
      // Arrange
      final message = 'Test message';
      final conversationHistory = <ChatMessage>[];

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Response'}
                ],
                'role': 'model',
              },
            }
          ],
        },
      );

      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await chatService.sendMessage(message, conversationHistory);

      // Assert
      final captured = verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
        data: captureAnyNamed('data'),
      )).captured;

      final requestData = captured[0] as Map<String, dynamic>;
      final generationConfig = requestData['generationConfig'] as Map<String, dynamic>;

      expect(generationConfig.keys, contains('temperature'));
      expect(generationConfig.keys, contains('maxOutputTokens'));
      expect(generationConfig['temperature'], isA<double>());
      expect(generationConfig['maxOutputTokens'], isA<int>());
    });
  });
}
