import 'package:equatable/equatable.dart';

/// Model untuk Quiz Question
/// Merepresentasikan pertanyaan kuis dari backend
/// Requirements: 10.1 - Quiz game dengan pertanyaan trivia pilihan ganda
class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  /// Create QuizQuestion from JSON response
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
    );
  }

  /// Convert QuizQuestion to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
    };
  }

  @override
  List<Object?> get props => [id, question, options];
}

/// Model untuk Quiz Answer Submission
/// Merepresentasikan jawaban yang dikirim ke backend
class QuizAnswerSubmission extends Equatable {
  final String questionId;
  final String answer; // 'A', 'B', 'C', 'D'

  const QuizAnswerSubmission({
    required this.questionId,
    required this.answer,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answer,
    };
  }

  @override
  List<Object?> get props => [questionId, answer];
}

/// Model untuk Quiz Result
/// Merepresentasikan hasil kuis dari backend
/// Requirements: 10.3, 10.4, 10.5 - Scoring, correct answers, explanations
class QuizResult extends Equatable {
  final int score;
  final int totalPoints;
  final List<QuestionResult> results;

  const QuizResult({
    required this.score,
    required this.totalPoints,
    required this.results,
  });

  /// Create QuizResult from JSON response
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] as int,
      totalPoints: json['total_points'] as int,
      results: (json['results'] as List)
          .map((result) => QuestionResult.fromJson(result))
          .toList(),
    );
  }

  /// Get percentage score
  double get percentage => totalPoints > 0 ? (score / totalPoints) * 100 : 0;

  @override
  List<Object?> get props => [score, totalPoints, results];
}

/// Model untuk Question Result
/// Merepresentasikan hasil untuk satu pertanyaan
class QuestionResult extends Equatable {
  final String questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? explanation;

  const QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.explanation,
  });

  /// Create QuestionResult from JSON
  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['question_id'] as String,
      question: json['question'] as String,
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      explanation: json['explanation'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        questionId,
        question,
        userAnswer,
        correctAnswer,
        isCorrect,
        explanation,
      ];
}

/// Model untuk High Score
/// Merepresentasikan skor tertinggi yang disimpan lokal
/// Requirements: 10.5, 10.6 - Save high score, display top 5 scores
class HighScore extends Equatable {
  final int score;
  final int totalQuestions;
  final DateTime date;

  const HighScore({
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  /// Create HighScore from JSON (SharedPreferences)
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'date': date.toIso8601String(),
    };
  }

  /// Get percentage score
  double get percentage => totalQuestions > 0 ? (score / (totalQuestions * 10)) * 100 : 0;

  @override
  List<Object?> get props => [score, totalQuestions, date];
}