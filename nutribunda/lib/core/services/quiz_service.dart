import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'http_client_service.dart';
import '../../data/models/quiz_question.dart';

/// Service untuk mengelola quiz functionality
/// Requirements: 10.1-10.7 - Complete quiz game implementation
class QuizService {
  final HttpClientService _httpClient;
  final SharedPreferences _prefs;

  static const String _highScoresKey = 'quiz_high_scores';
  static const int _maxHighScores = 5; // Requirement 10.6: top 5 high scores

  QuizService({
    required HttpClientService httpClient,
    required SharedPreferences prefs,
  })  : _httpClient = httpClient,
        _prefs = prefs;

  /// Fetch random quiz questions from backend
  /// Requirements: 10.2 - Select 10 random questions from available question pool
  Future<List<QuizQuestion>> getRandomQuestions({int limit = 10}) async {
    try {
      final response = await _httpClient.get(
        '${ApiConstants.quizQuestions}?limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final questionsJson = data['questions'] as List;
        
        final questions = questionsJson
            .map((json) => QuizQuestion.fromJson(json))
            .toList();

        // Additional randomization to ensure different order each session
        // Requirements: 10.7 - Ensure question order different from previous session
        questions.shuffle(Random());
        
        return questions;
      } else {
        throw Exception('Failed to fetch quiz questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quiz questions: $e');
    }
  }

  /// Submit quiz answers and get results
  /// Requirements: 10.3, 10.4 - Add 10 points for correct answers, show correct answers
  Future<QuizResult> submitAnswers(List<QuizAnswerSubmission> answers) async {
    try {
      final requestData = {
        'answers': answers.map((answer) => answer.toJson()).toList(),
      };

      final response = await _httpClient.post(
        ApiConstants.quizSubmit,
        data: requestData,
      );

      if (response.statusCode == 200) {
        return QuizResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to submit quiz answers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting quiz answers: $e');
    }
  }

  /// Save high score to local storage
  /// Requirements: 10.5 - Save high score to local storage
  Future<void> saveHighScore(int score, int totalQuestions) async {
    try {
      final newScore = HighScore(
        score: score,
        totalQuestions: totalQuestions,
        date: DateTime.now(),
      );

      final highScores = await getHighScores();
      highScores.add(newScore);

      // Sort by score (descending) and keep only top 5
      highScores.sort((a, b) => b.score.compareTo(a.score));
      final topScores = highScores.take(_maxHighScores).toList();

      // Save to SharedPreferences
      final scoresJson = topScores.map((score) => score.toJson()).toList();
      await _prefs.setString(_highScoresKey, jsonEncode(scoresJson));
    } catch (e) {
      throw Exception('Error saving high score: $e');
    }
  }

  /// Get high scores from local storage
  /// Requirements: 10.6 - Display local scoreboard with top 5 high scores
  Future<List<HighScore>> getHighScores() async {
    try {
      final scoresString = _prefs.getString(_highScoresKey);
      if (scoresString == null) {
        return [];
      }

      final scoresJson = jsonDecode(scoresString) as List;
      return scoresJson
          .map((json) => HighScore.fromJson(json))
          .toList();
    } catch (e) {
      // If there's an error reading scores, return empty list
      return [];
    }
  }

  /// Clear all high scores (for testing or reset functionality)
  Future<void> clearHighScores() async {
    await _prefs.remove(_highScoresKey);
  }

  /// Check if a score qualifies as a high score
  Future<bool> isHighScore(int score) async {
    final highScores = await getHighScores();
    
    // If we have less than 5 scores, it's automatically a high score
    if (highScores.length < _maxHighScores) {
      return true;
    }

    // Check if score is higher than the lowest high score
    final lowestHighScore = highScores.last.score;
    return score > lowestHighScore;
  }

  /// Get quiz statistics
  Future<QuizStatistics> getQuizStatistics() async {
    final highScores = await getHighScores();
    
    if (highScores.isEmpty) {
      return const QuizStatistics(
        totalGamesPlayed: 0,
        averageScore: 0,
        bestScore: 0,
        bestPercentage: 0,
      );
    }

    final totalGames = highScores.length;
    final totalScore = highScores.fold<int>(0, (sum, score) => sum + score.score);
    final averageScore = totalScore / totalGames;
    final bestScore = highScores.first.score;
    final bestPercentage = highScores.first.percentage;

    return QuizStatistics(
      totalGamesPlayed: totalGames,
      averageScore: averageScore,
      bestScore: bestScore,
      bestPercentage: bestPercentage,
    );
  }
}

/// Model untuk quiz statistics
class QuizStatistics {
  final int totalGamesPlayed;
  final double averageScore;
  final int bestScore;
  final double bestPercentage;

  const QuizStatistics({
    required this.totalGamesPlayed,
    required this.averageScore,
    required this.bestScore,
    required this.bestPercentage,
  });
}