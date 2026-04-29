import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nutribunda/presentation/providers/quiz_provider.dart';
import 'package:nutribunda/core/services/quiz_service.dart';
import 'package:nutribunda/data/models/quiz_question.dart';
import 'package:nutribunda/core/errors/failures.dart';

import 'quiz_provider_test.mocks.dart';

@GenerateMocks([QuizService])
void main() {
  group('QuizProvider', () {
    late QuizProvider quizProvider;
    late MockQuizService mockQuizService;

    setUp(() {
      mockQuizService = MockQuizService();
      quizProvider = QuizProvider(quizService: mockQuizService);
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        // Assert
        expect(quizProvider.questions, isEmpty);
        expect(quizProvider.userAnswers, isEmpty);
        expect(quizProvider.currentQuestionIndex, 0);
        expect(quizProvider.quizResult, isNull);
        expect(quizProvider.highScores, isEmpty);
        expect(quizProvider.statistics, isNull);
        expect(quizProvider.isQuizActive, false);
        expect(quizProvider.isQuizCompleted, false);
        expect(quizProvider.currentQuestion, isNull);
        expect(quizProvider.totalQuestions, 0);
        expect(quizProvider.answeredQuestions, 0);
        expect(quizProvider.progress, 0);
      });
    });

    group('startQuiz', () {
      test('should start quiz successfully with questions', () async {
        // Arrange
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'What is the main nutrient in rice?',
            options: ['Protein', 'Carbohydrate', 'Fat', 'Vitamin'],
          ),
          const QuizQuestion(
            id: '2',
            question: 'How many calories in 100g banana?',
            options: ['50', '89', '120', '150'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        // Act
        await quizProvider.startQuiz(questionCount: 2);

        // Assert
        expect(quizProvider.questions, hasLength(2));
        expect(quizProvider.isQuizActive, true);
        expect(quizProvider.isQuizCompleted, false);
        expect(quizProvider.currentQuestion, isNotNull);
        expect(quizProvider.currentQuestion!.id, '1');
        expect(quizProvider.totalQuestions, 2);
        expect(quizProvider.isLoading, false);
        expect(quizProvider.hasError, false);
      });

      test('should handle empty questions list', () async {
        // Arrange
        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => []);

        // Act
        await quizProvider.startQuiz();

        // Assert
        expect(quizProvider.questions, isEmpty);
        expect(quizProvider.isQuizActive, false);
        expect(quizProvider.hasError, true);
        expect(quizProvider.errorMessage, contains('No quiz questions available'));
      });

      test('should handle service error', () async {
        // Arrange
        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenThrow(Exception('Network error'));

        // Act
        await quizProvider.startQuiz();

        // Assert
        expect(quizProvider.isQuizActive, false);
        expect(quizProvider.hasError, true);
        expect(quizProvider.errorMessage, contains('Failed to start quiz'));
      });

      test('should reset previous quiz state when starting new quiz', () async {
        // Arrange
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Test question',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        // Set some previous state
        quizProvider.answerQuestion('A'); // This won't work without questions, but sets up state

        // Act
        await quizProvider.startQuiz(questionCount: 1);

        // Assert
        expect(quizProvider.userAnswers, isEmpty);
        expect(quizProvider.currentQuestionIndex, 0);
        expect(quizProvider.quizResult, isNull);
        expect(quizProvider.isQuizCompleted, false);
      });
    });

    group('answerQuestion', () {
      setUp(() async {
        // Setup quiz with questions
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
          const QuizQuestion(
            id: '2',
            question: 'Question 2',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        await quizProvider.startQuiz(questionCount: 2);
      });

      test('should save answer and move to next question', () {
        // Act
        quizProvider.answerQuestion('B');

        // Assert
        expect(quizProvider.userAnswers['1'], 'B');
        expect(quizProvider.currentQuestionIndex, 1);
        expect(quizProvider.currentQuestion!.id, '2');
        expect(quizProvider.answeredQuestions, 1);
        expect(quizProvider.progress, 0.5); // 1/2 questions answered
      });

      test('should complete quiz when answering last question', () async {
        // Arrange
        final mockResult = QuizResult(
          score: 10,
          totalPoints: 20,
          results: [
            const QuestionResult(
              questionId: '1',
              question: 'Question 1',
              userAnswer: 'B',
              correctAnswer: 'B',
              isCorrect: true,
            ),
            const QuestionResult(
              questionId: '2',
              question: 'Question 2',
              userAnswer: 'A',
              correctAnswer: 'C',
              isCorrect: false,
            ),
          ],
        );

        when(mockQuizService.submitAnswers(any))
            .thenAnswer((_) async => mockResult);
        when(mockQuizService.isHighScore(any))
            .thenAnswer((_) async => false);

        // Act - Answer first question
        quizProvider.answerQuestion('B');
        // Answer last question
        quizProvider.answerQuestion('A');

        // Wait for async submission to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(quizProvider.userAnswers, hasLength(2));
        expect(quizProvider.isQuizActive, false);
        expect(quizProvider.isQuizCompleted, true);
        expect(quizProvider.quizResult, isNotNull);
        expect(quizProvider.quizResult!.score, 10);
      });

      test('should not answer when quiz is not active', () {
        // Arrange
        quizProvider.resetQuiz(); // Make quiz inactive

        // Act
        quizProvider.answerQuestion('A');

        // Assert
        expect(quizProvider.userAnswers, isEmpty);
        expect(quizProvider.currentQuestionIndex, 0);
      });
    });

    group('Navigation', () {
      setUp(() async {
        // Setup quiz with 3 questions
        final mockQuestions = List.generate(3, (index) => QuizQuestion(
          id: '${index + 1}',
          question: 'Question ${index + 1}',
          options: ['A', 'B', 'C', 'D'],
        ));

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        await quizProvider.startQuiz(questionCount: 3);
      });

      test('should go to previous question', () {
        // Arrange - Move to question 2
        quizProvider.answerQuestion('A');
        expect(quizProvider.currentQuestionIndex, 1);

        // Act
        quizProvider.previousQuestion();

        // Assert
        expect(quizProvider.currentQuestionIndex, 0);
        expect(quizProvider.currentQuestion!.id, '1');
      });

      test('should not go before first question', () {
        // Act
        quizProvider.previousQuestion();

        // Assert
        expect(quizProvider.currentQuestionIndex, 0);
      });

      test('should go to specific question', () {
        // Act
        quizProvider.goToQuestion(2);

        // Assert
        expect(quizProvider.currentQuestionIndex, 2);
        expect(quizProvider.currentQuestion!.id, '3');
      });

      test('should not go to invalid question index', () {
        // Act
        quizProvider.goToQuestion(5); // Out of bounds

        // Assert
        expect(quizProvider.currentQuestionIndex, 0); // Should stay at current
      });
    });

    group('High Scores', () {
      test('should load high scores successfully', () async {
        // Arrange
        final mockHighScores = [
          HighScore(
            score: 90,
            totalQuestions: 10,
            date: DateTime.now(),
          ),
          HighScore(
            score: 80,
            totalQuestions: 10,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        final mockStatistics = const QuizStatistics(
          totalGamesPlayed: 2,
          averageScore: 85.0,
          bestScore: 90,
          bestPercentage: 90.0,
        );

        when(mockQuizService.getHighScores())
            .thenAnswer((_) async => mockHighScores);
        when(mockQuizService.getQuizStatistics())
            .thenAnswer((_) async => mockStatistics);

        // Act
        await quizProvider.loadHighScores();

        // Assert
        expect(quizProvider.highScores, hasLength(2));
        expect(quizProvider.highScores[0].score, 90);
        expect(quizProvider.statistics, isNotNull);
        expect(quizProvider.statistics!.bestScore, 90);
      });

      test('should handle high scores loading error gracefully', () async {
        // Arrange
        when(mockQuizService.getHighScores())
            .thenThrow(Exception('Loading failed'));

        // Act
        await quizProvider.loadHighScores();

        // Assert - Should not set error state for high scores failure
        expect(quizProvider.hasError, false);
        expect(quizProvider.highScores, isEmpty);
      });

      test('should clear high scores', () async {
        // Arrange
        when(mockQuizService.clearHighScores()).thenAnswer((_) async {});
        when(mockQuizService.getHighScores()).thenAnswer((_) async => []);
        when(mockQuizService.getQuizStatistics()).thenAnswer((_) async => 
          const QuizStatistics(
            totalGamesPlayed: 0,
            averageScore: 0,
            bestScore: 0,
            bestPercentage: 0,
          ));

        // Act
        await quizProvider.clearHighScores();

        // Assert
        verify(mockQuizService.clearHighScores()).called(1);
        expect(quizProvider.highScores, isEmpty);
      });

      test('should handle clear high scores error', () async {
        // Arrange
        when(mockQuizService.clearHighScores())
            .thenThrow(Exception('Clear failed'));

        // Act
        await quizProvider.clearHighScores();

        // Assert
        expect(quizProvider.hasError, true);
        expect(quizProvider.errorMessage, contains('Failed to clear high scores'));
      });
    });

    group('Quiz Submission', () {
      test('should save high score when result qualifies', () async {
        // Arrange
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        final mockResult = QuizResult(
          score: 10,
          totalPoints: 10,
          results: [
            const QuestionResult(
              questionId: '1',
              question: 'Question 1',
              userAnswer: 'A',
              correctAnswer: 'A',
              isCorrect: true,
            ),
          ],
        );

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);
        when(mockQuizService.submitAnswers(any))
            .thenAnswer((_) async => mockResult);
        when(mockQuizService.isHighScore(10))
            .thenAnswer((_) async => true);
        when(mockQuizService.saveHighScore(10, 1))
            .thenAnswer((_) async {});
        when(mockQuizService.getHighScores())
            .thenAnswer((_) async => []);
        when(mockQuizService.getQuizStatistics())
            .thenAnswer((_) async => const QuizStatistics(
              totalGamesPlayed: 0,
              averageScore: 0,
              bestScore: 0,
              bestPercentage: 0,
            ));

        await quizProvider.startQuiz(questionCount: 1);

        // Act
        quizProvider.answerQuestion('A');

        // Wait for submission
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verify(mockQuizService.saveHighScore(10, 1)).called(1);
        verify(mockQuizService.getHighScores()).called(1); // Refresh high scores
      });

      test('should not save high score when result does not qualify', () async {
        // Arrange
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        final mockResult = QuizResult(
          score: 0,
          totalPoints: 10,
          results: [
            const QuestionResult(
              questionId: '1',
              question: 'Question 1',
              userAnswer: 'B',
              correctAnswer: 'A',
              isCorrect: false,
            ),
          ],
        );

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);
        when(mockQuizService.submitAnswers(any))
            .thenAnswer((_) async => mockResult);
        when(mockQuizService.isHighScore(0))
            .thenAnswer((_) async => false);

        await quizProvider.startQuiz(questionCount: 1);

        // Act
        quizProvider.answerQuestion('B');

        // Wait for submission
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verifyNever(mockQuizService.saveHighScore(any, any));
      });

      test('should handle submission error', () async {
        // Arrange
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);
        when(mockQuizService.submitAnswers(any))
            .thenThrow(Exception('Submission failed'));

        await quizProvider.startQuiz(questionCount: 1);

        // Act
        quizProvider.answerQuestion('A');

        // Wait for submission
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(quizProvider.hasError, true);
        expect(quizProvider.errorMessage, contains('Failed to submit quiz'));
      });
    });

    group('Utility Methods', () {
      setUp(() async {
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
          const QuizQuestion(
            id: '2',
            question: 'Question 2',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        await quizProvider.startQuiz(questionCount: 2);
      });

      test('should get answer for specific question', () {
        // Arrange
        quizProvider.answerQuestion('B');

        // Act & Assert
        expect(quizProvider.getAnswerForQuestion('1'), 'B');
        expect(quizProvider.getAnswerForQuestion('2'), isNull);
      });

      test('should check if question is answered', () {
        // Arrange
        quizProvider.answerQuestion('B');

        // Act & Assert
        expect(quizProvider.isQuestionAnswered('1'), true);
        expect(quizProvider.isQuestionAnswered('2'), false);
      });

      test('should calculate current score during quiz', () {
        // Arrange
        quizProvider.answerQuestion('B');

        // Act & Assert
        expect(quizProvider.getCurrentScore(), 10); // 1 answer * 10 points
      });

      test('should return actual score when quiz is completed', () async {
        // Arrange
        final mockResult = QuizResult(
          score: 15,
          totalPoints: 20,
          results: [],
        );

        when(mockQuizService.submitAnswers(any))
            .thenAnswer((_) async => mockResult);
        when(mockQuizService.isHighScore(any))
            .thenAnswer((_) async => false);

        quizProvider.answerQuestion('B');
        quizProvider.answerQuestion('A');

        // Wait for submission
        await Future.delayed(const Duration(milliseconds: 100));

        // Act & Assert
        expect(quizProvider.getCurrentScore(), 15); // Actual score from result
      });

      test('should check if current result is high score', () async {
        // Arrange
        final mockResult = QuizResult(
          score: 90,
          totalPoints: 100,
          results: [],
        );

        final mockHighScores = [
          HighScore(score: 80, totalQuestions: 10, date: DateTime.now()),
        ];

        when(mockQuizService.submitAnswers(any))
            .thenAnswer((_) async => mockResult);
        when(mockQuizService.isHighScore(any))
            .thenAnswer((_) async => true);
        when(mockQuizService.saveHighScore(any, any))
            .thenAnswer((_) async {});
        when(mockQuizService.getHighScores())
            .thenAnswer((_) async => mockHighScores);
        when(mockQuizService.getQuizStatistics())
            .thenAnswer((_) async => const QuizStatistics(
              totalGamesPlayed: 1,
              averageScore: 80,
              bestScore: 80,
              bestPercentage: 80,
            ));

        quizProvider.answerQuestion('B');
        quizProvider.answerQuestion('A');

        // Wait for submission
        await Future.delayed(const Duration(milliseconds: 100));

        // Load high scores to populate the list
        await quizProvider.loadHighScores();

        // Act & Assert
        expect(quizProvider.isCurrentResultHighScore, true);
      });
    });

    group('resetQuiz', () {
      test('should reset all quiz state', () async {
        // Arrange - Start a quiz and answer some questions
        final mockQuestions = [
          const QuizQuestion(
            id: '1',
            question: 'Question 1',
            options: ['A', 'B', 'C', 'D'],
          ),
        ];

        when(mockQuizService.getRandomQuestions(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockQuestions);

        await quizProvider.startQuiz(questionCount: 1);
        quizProvider.answerQuestion('A');

        // Act
        quizProvider.resetQuiz();

        // Assert
        expect(quizProvider.questions, isEmpty);
        expect(quizProvider.userAnswers, isEmpty);
        expect(quizProvider.currentQuestionIndex, 0);
        expect(quizProvider.quizResult, isNull);
        expect(quizProvider.isQuizActive, false);
        expect(quizProvider.isQuizCompleted, false);
        expect(quizProvider.hasError, false);
      });
    });
  });
}