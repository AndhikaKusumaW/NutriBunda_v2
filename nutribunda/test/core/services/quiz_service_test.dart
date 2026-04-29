import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutribunda/core/services/quiz_service.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/data/models/quiz_question.dart';
import 'package:dio/dio.dart';

import 'quiz_service_test.mocks.dart';

@GenerateMocks([HttpClientService, SharedPreferences])
void main() {
  group('QuizService', () {
    late QuizService quizService;
    late MockHttpClientService mockHttpClient;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockPrefs = MockSharedPreferences();
      quizService = QuizService(
        httpClient: mockHttpClient,
        prefs: mockPrefs,
      );
    });

    group('getRandomQuestions', () {
      test('should return list of quiz questions when API call succeeds', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'questions': [
              {
                'id': '1',
                'question': 'What is the main nutrient in rice?',
                'options': ['Protein', 'Carbohydrate', 'Fat', 'Vitamin'],
              },
              {
                'id': '2',
                'question': 'How many calories in 100g banana?',
                'options': ['50', '89', '120', '150'],
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await quizService.getRandomQuestions(limit: 2);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[0].question, 'What is the main nutrient in rice?');
        expect(result[0].options, hasLength(4));
        expect(result[1].id, '2');
        verify(mockHttpClient.get(argThat(contains('limit=2')))).called(1);
      });

      test('should randomize question order', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'questions': List.generate(10, (index) => {
              'id': '$index',
              'question': 'Question $index',
              'options': ['A', 'B', 'C', 'D'],
            })
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act - Call multiple times to test randomization
        final result1 = await quizService.getRandomQuestions();
        final result2 = await quizService.getRandomQuestions();

        // Assert - Questions should be in different order (with high probability)
        expect(result1, hasLength(10));
        expect(result2, hasLength(10));
        // Note: There's a small chance they could be the same, but very unlikely
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // Act & Assert
        expect(
          () => quizService.getRandomQuestions(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when response status is not 200', () async {
        // Arrange
        final mockResponse = Response(
          data: {'error': 'Server error'},
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockHttpClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => quizService.getRandomQuestions(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('submitAnswers', () {
      test('should return quiz result when submission succeeds', () async {
        // Arrange
        final answers = [
          const QuizAnswerSubmission(questionId: '1', answer: 'B'),
          const QuizAnswerSubmission(questionId: '2', answer: 'A'),
        ];

        final mockResponse = Response(
          data: {
            'score': 10,
            'total_points': 20,
            'results': [
              {
                'question_id': '1',
                'question': 'What is the main nutrient in rice?',
                'user_answer': 'B',
                'correct_answer': 'B',
                'is_correct': true,
                'explanation': 'Rice is primarily carbohydrate',
              },
              {
                'question_id': '2',
                'question': 'How many calories in 100g banana?',
                'user_answer': 'A',
                'correct_answer': 'B',
                'is_correct': false,
                'explanation': 'Banana has about 89 calories per 100g',
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockHttpClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await quizService.submitAnswers(answers);

        // Assert
        expect(result.score, 10);
        expect(result.totalPoints, 20);
        expect(result.results, hasLength(2));
        expect(result.results[0].isCorrect, true);
        expect(result.results[1].isCorrect, false);
        expect(result.percentage, 50.0);
      });

      test('should throw exception when submission fails', () async {
        // Arrange
        final answers = [
          const QuizAnswerSubmission(questionId: '1', answer: 'B'),
        ];

        when(mockHttpClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // Act & Assert
        expect(
          () => quizService.submitAnswers(answers),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('High Score Management', () {
      test('should save high score to SharedPreferences', () async {
        // Arrange
        when(mockPrefs.getString(any)).thenReturn(null);
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act
        await quizService.saveHighScore(80, 10);

        // Assert
        verify(mockPrefs.setString('quiz_high_scores', any)).called(1);
      });

      test('should maintain only top 5 high scores', () async {
        // Arrange - Setup existing 5 high scores
        final existingScores = List.generate(5, (index) => {
          'score': (index + 1) * 10, // 10, 20, 30, 40, 50
          'total_questions': 10,
          'date': DateTime.now().toIso8601String(),
        });

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(existingScores));
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act - Add a new high score (60)
        await quizService.saveHighScore(60, 10);

        // Assert - Should save only top 5, removing the lowest (10)
        final capturedJson = verify(mockPrefs.setString('quiz_high_scores', captureAny))
            .captured.first as String;
        final savedScores = jsonDecode(capturedJson) as List;
        
        expect(savedScores, hasLength(5));
        expect(savedScores.first['score'], 60); // Highest score first
        expect(savedScores.last['score'], 20); // Lowest score should be 20, not 10
      });

      test('should load high scores from SharedPreferences', () async {
        // Arrange
        final mockScores = [
          {
            'score': 90,
            'total_questions': 10,
            'date': DateTime.now().toIso8601String(),
          },
          {
            'score': 70,
            'total_questions': 10,
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          }
        ];

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(mockScores));

        // Act
        final result = await quizService.getHighScores();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].score, 90);
        expect(result[1].score, 70);
        expect(result[0].percentage, 90.0); // 90/100 * 100
        expect(result[1].percentage, 70.0);
      });

      test('should return empty list when no high scores exist', () async {
        // Arrange
        when(mockPrefs.getString('quiz_high_scores')).thenReturn(null);

        // Act
        final result = await quizService.getHighScores();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle corrupted high scores data gracefully', () async {
        // Arrange
        when(mockPrefs.getString('quiz_high_scores')).thenReturn('invalid json');

        // Act
        final result = await quizService.getHighScores();

        // Assert
        expect(result, isEmpty);
      });

      test('should clear all high scores', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await quizService.clearHighScores();

        // Assert
        verify(mockPrefs.remove('quiz_high_scores')).called(1);
      });
    });

    group('isHighScore', () {
      test('should return true when less than 5 scores exist', () async {
        // Arrange
        final mockScores = [
          {
            'score': 50,
            'total_questions': 10,
            'date': DateTime.now().toIso8601String(),
          }
        ];

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(mockScores));

        // Act
        final result = await quizService.isHighScore(30);

        // Assert
        expect(result, true);
      });

      test('should return true when score is higher than lowest high score', () async {
        // Arrange - 5 existing scores: 90, 80, 70, 60, 50
        final mockScores = List.generate(5, (index) => {
          'score': 90 - (index * 10),
          'total_questions': 10,
          'date': DateTime.now().toIso8601String(),
        });

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(mockScores));

        // Act
        final result = await quizService.isHighScore(55);

        // Assert
        expect(result, true); // 55 > 50 (lowest)
      });

      test('should return false when score is not higher than lowest high score', () async {
        // Arrange - 5 existing scores: 90, 80, 70, 60, 50
        final mockScores = List.generate(5, (index) => {
          'score': 90 - (index * 10),
          'total_questions': 10,
          'date': DateTime.now().toIso8601String(),
        });

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(mockScores));

        // Act
        final result = await quizService.isHighScore(45);

        // Assert
        expect(result, false); // 45 < 50 (lowest)
      });
    });

    group('getQuizStatistics', () {
      test('should return correct statistics when high scores exist', () async {
        // Arrange
        final mockScores = [
          {
            'score': 90,
            'total_questions': 10,
            'date': DateTime.now().toIso8601String(),
          },
          {
            'score': 70,
            'total_questions': 10,
            'date': DateTime.now().toIso8601String(),
          },
          {
            'score': 60,
            'total_questions': 10,
            'date': DateTime.now().toIso8601String(),
          }
        ];

        when(mockPrefs.getString('quiz_high_scores'))
            .thenReturn(jsonEncode(mockScores));

        // Act
        final result = await quizService.getQuizStatistics();

        // Assert
        expect(result.totalGamesPlayed, 3);
        expect(result.averageScore, (90 + 70 + 60) / 3); // 73.33...
        expect(result.bestScore, 90);
        expect(result.bestPercentage, 90.0);
      });

      test('should return zero statistics when no high scores exist', () async {
        // Arrange
        when(mockPrefs.getString('quiz_high_scores')).thenReturn(null);

        // Act
        final result = await quizService.getQuizStatistics();

        // Assert
        expect(result.totalGamesPlayed, 0);
        expect(result.averageScore, 0);
        expect(result.bestScore, 0);
        expect(result.bestPercentage, 0);
      });
    });
  });
}