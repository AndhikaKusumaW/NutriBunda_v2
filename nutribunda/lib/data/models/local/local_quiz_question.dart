import 'package:equatable/equatable.dart';
import '../quiz_question.dart';

/// Local Quiz Question Model with sync tracking
class LocalQuizQuestion extends Equatable {
  final int? id; // Local SQLite ID
  final String? serverId; // Server UUID
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String? explanation;
  final DateTime createdAt;
  final String syncStatus; // 'synced', 'pending', 'failed'

  const LocalQuizQuestion({
    this.id,
    this.serverId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    this.explanation,
    required this.createdAt,
    this.syncStatus = 'synced',
  });

  /// Create from backend data (when syncing from server)
  /// Note: Backend stores individual options, but API returns options as list
  factory LocalQuizQuestion.fromBackendData({
    required String serverId,
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    required DateTime createdAt,
  }) {
    return LocalQuizQuestion(
      serverId: serverId,
      question: question,
      optionA: optionA,
      optionB: optionB,
      optionC: optionC,
      optionD: optionD,
      correctAnswer: correctAnswer,
      explanation: explanation,
      createdAt: createdAt,
      syncStatus: 'synced',
    );
  }

  /// Convert to QuizQuestion (for API/UI)
  QuizQuestion toQuizQuestion() {
    return QuizQuestion(
      id: serverId ?? '',
      question: question,
      options: [optionA, optionB, optionC, optionD],
    );
  }

  /// Create from SQLite map
  factory LocalQuizQuestion.fromMap(Map<String, dynamic> map) {
    return LocalQuizQuestion(
      id: map['id'] as int?,
      serverId: map['server_id'] as String?,
      question: map['question'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      optionD: map['option_d'] as String,
      correctAnswer: map['correct_answer'] as String,
      explanation: map['explanation'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      syncStatus: map['sync_status'] as String? ?? 'synced',
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'server_id': serverId,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'created_at': createdAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  /// Get all options as a list
  List<String> get options => [optionA, optionB, optionC, optionD];

  /// Copy with updated fields
  LocalQuizQuestion copyWith({
    int? id,
    String? serverId,
    String? question,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctAnswer,
    String? explanation,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return LocalQuizQuestion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      question: question ?? this.question,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverId,
        question,
        optionA,
        optionB,
        optionC,
        optionD,
        correctAnswer,
        explanation,
        createdAt,
        syncStatus,
      ];
}
