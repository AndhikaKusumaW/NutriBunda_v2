import 'package:flutter/foundation.dart';
import '../../core/services/quiz_service.dart';
import '../../data/models/quiz_question.dart';
import '../../core/errors/failures.dart';
import 'base_provider.dart';

/// Provider untuk mengelola state quiz game
/// Requirements: 10.1-10.7 - Complete quiz game with scoring and high scores
class QuizProvider extends BaseProvider {
  final QuizService _quizService;

  QuizProvider({required QuizService quizService}) : _quizService = quizService;

  // Quiz session state
  List<QuizQuestion> _questions = [];
  Map<String, String> _userAnswers = {}; // questionId -> answer (A/B/C/D)
  int _currentQuestionIndex = 0;
  QuizResult? _quizResult;
  
  // High scores state
  List<HighScore> _highScores = [];
  QuizStatistics? _statistics;

  // Quiz session state
  bool _isQuizActive = false;
  bool _isQuizCompleted = false;

  // Getters
  List<QuizQuestion> get questions => _questions;
  Map<String, String> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizResult? get quizResult => _quizResult;
  List<HighScore> get highScores => _highScores;
  QuizStatistics? get statistics => _statistics;
  bool get isQuizActive => _isQuizActive;
  bool get isQuizCompleted => _isQuizCompleted;

  // Current question getter
  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  // Progress getters
  int get totalQuestions => _questions.length;
  int get answeredQuestions => _userAnswers.length;
  double get progress => totalQuestions > 0 ? answeredQuestions / totalQuestions : 0;

  /// Start a new quiz session
  /// Requirements: 10.2 - Select 10 random questions from available question pool
  Future<void> startQuiz({int questionCount = 10}) async {
    try {
      setLoading(true);
      clearError();

      // Reset quiz state
      _questions = [];
      _userAnswers = {};
      _currentQuestionIndex = 0;
      _quizResult = null;
      _isQuizActive = false;
      _isQuizCompleted = false;

      // Fetch random questions
      _questions = await _quizService.getRandomQuestions(limit: questionCount);
      
      if (_questions.isEmpty) {
        setFailure(ServerFailure(message: 'No quiz questions available. Please try again later.'));
        return;
      }

      _isQuizActive = true;
      notifyListeners();
    } catch (e) {
      setFailure(ServerFailure(message: 'Failed to start quiz: ${e.toString()}'));
    } finally {
      setLoading(false);
    }
  }

  /// Answer current question and move to next
  /// Requirements: 10.3 - Add 10 points for correct answers
  void answerQuestion(String answer) {
    if (!_isQuizActive || currentQuestion == null) return;

    // Save answer
    _userAnswers[currentQuestion!.id] = answer;

    // Move to next question or complete quiz
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      // All questions answered, submit quiz
      _submitQuiz();
    }

    notifyListeners();
  }

  /// Go to previous question (if allowed)
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Submit quiz and get results
  /// Requirements: 10.4, 10.5 - Show correct answers, save high score
  Future<void> _submitQuiz() async {
    try {
      setLoading(true);

      // Prepare answers for submission
      final submissions = _userAnswers.entries
          .map((entry) => QuizAnswerSubmission(
                questionId: entry.key,
                answer: entry.value,
              ))
          .toList();

      // Submit to backend
      _quizResult = await _quizService.submitAnswers(submissions);

      // Save high score if applicable
      if (_quizResult != null) {
        final isNewHighScore = await _quizService.isHighScore(_quizResult!.score);
        if (isNewHighScore) {
          await _quizService.saveHighScore(_quizResult!.score, _questions.length);
          await loadHighScores(); // Refresh high scores
        }
      }

      _isQuizActive = false;
      _isQuizCompleted = true;
      notifyListeners();
    } catch (e) {
      setFailure(ServerFailure(message: 'Failed to submit quiz: ${e.toString()}'));
    } finally {
      setLoading(false);
    }
  }

  /// Load high scores from local storage
  /// Requirements: 10.6 - Display local scoreboard with top 5 high scores
  Future<void> loadHighScores() async {
    try {
      _highScores = await _quizService.getHighScores();
      _statistics = await _quizService.getQuizStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading high scores: $e');
      // Don't set error for high scores loading failure
    }
  }

  /// Reset quiz to initial state
  void resetQuiz() {
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _quizResult = null;
    _isQuizActive = false;
    _isQuizCompleted = false;
    clearError();
    notifyListeners();
  }

  /// Clear all high scores (for testing/reset)
  Future<void> clearHighScores() async {
    try {
      await _quizService.clearHighScores();
      await loadHighScores();
    } catch (e) {
      setFailure(ServerFailure(message: 'Failed to clear high scores: ${e.toString()}'));
    }
  }

  /// Get answer for specific question
  String? getAnswerForQuestion(String questionId) {
    return _userAnswers[questionId];
  }

  /// Check if question is answered
  bool isQuestionAnswered(String questionId) {
    return _userAnswers.containsKey(questionId);
  }

  /// Get current score (during quiz)
  int getCurrentScore() {
    if (_quizResult != null) {
      return _quizResult!.score;
    }
    
    // Calculate temporary score based on answered questions
    // This is just for display, actual scoring is done by backend
    return _userAnswers.length * 10; // Assuming all answers are correct for display
  }

  /// Check if current quiz result is a high score
  bool get isCurrentResultHighScore {
    if (_quizResult == null || _highScores.isEmpty) return false;
    
    if (_highScores.length < 5) return true;
    
    return _quizResult!.score > _highScores.last.score;
  }
}