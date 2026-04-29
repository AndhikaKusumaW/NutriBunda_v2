import 'package:sqflite/sqflite.dart';
import '../../models/local/local_quiz_question.dart';
import 'database_helper.dart';

/// Local Quiz Data Source
/// Handles CRUD operations for quiz questions in SQLite
/// Requirements: 10.1, 10.2, 10.7 - Quiz game with cached questions
class LocalQuizDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert quiz question
  Future<int> insertQuizQuestion(LocalQuizQuestion question) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'quiz_questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple quiz questions (batch operation)
  Future<void> insertQuizQuestions(List<LocalQuizQuestion> questions) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final question in questions) {
      batch.insert(
        'quiz_questions',
        question.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get quiz question by local ID
  Future<LocalQuizQuestion?> getQuizQuestionById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'quiz_questions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalQuizQuestion.fromMap(maps.first);
  }

  /// Get random quiz questions
  /// Requirements: 10.2 - Random selection of 10 questions
  Future<List<LocalQuizQuestion>> getRandomQuizQuestions({int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'quiz_questions',
      orderBy: 'RANDOM()',
      limit: limit,
    );

    return maps.map((map) => LocalQuizQuestion.fromMap(map)).toList();
  }

  /// Get all quiz questions
  Future<List<LocalQuizQuestion>> getAllQuizQuestions() async {
    final db = await _dbHelper.database;
    final maps = await db.query('quiz_questions');
    return maps.map((map) => LocalQuizQuestion.fromMap(map)).toList();
  }

  /// Update quiz question
  Future<int> updateQuizQuestion(LocalQuizQuestion question) async {
    final db = await _dbHelper.database;
    return await db.update(
      'quiz_questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  /// Delete quiz question
  Future<int> deleteQuizQuestion(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'quiz_questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get count of quiz questions
  Future<int> getQuizQuestionsCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quiz_questions');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all quiz questions
  Future<void> clearAllQuizQuestions() async {
    final db = await _dbHelper.database;
    await db.delete('quiz_questions');
  }

  /// Update last sync time for quiz questions
  Future<void> updateLastSyncTime(DateTime syncTime) async {
    final db = await _dbHelper.database;
    await db.insert(
      'sync_metadata',
      {
        'table_name': 'quiz_questions',
        'last_sync_at': syncTime.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get last sync time for quiz questions
  Future<DateTime?> getLastSyncTime() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sync_metadata',
      where: 'table_name = ?',
      whereArgs: ['quiz_questions'],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DateTime.parse(maps.first['last_sync_at'] as String);
  }
}
