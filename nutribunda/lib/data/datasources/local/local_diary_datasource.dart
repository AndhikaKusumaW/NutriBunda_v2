import 'package:sqflite/sqflite.dart';
import '../../models/local/local_diary_entry.dart';
import 'database_helper.dart';

/// Local Diary Data Source
/// Handles CRUD operations for diary entries in SQLite
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5 - Food diary with offline support
class LocalDiaryDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert diary entry
  Future<int> insertDiaryEntry(LocalDiaryEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'diary_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get diary entry by local ID
  Future<LocalDiaryEntry?> getDiaryEntryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'diary_entries',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalDiaryEntry.fromMap(maps.first);
  }

  /// Get diary entries by date and profile type
  /// Requirements: 4.1, 4.2 - Dual profile support
  Future<List<LocalDiaryEntry>> getDiaryEntriesByDate({
    required int userId,
    required String profileType,
    required DateTime date,
  }) async {
    final db = await _dbHelper.database;
    final dateStr = _formatDate(date);

    final maps = await db.query(
      'diary_entries',
      where: 'user_id = ? AND profile_type = ? AND entry_date = ? AND deleted_at IS NULL',
      whereArgs: [userId, profileType, dateStr],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Get diary entries by date range
  Future<List<LocalDiaryEntry>> getDiaryEntriesByDateRange({
    required int userId,
    required String profileType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);

    final maps = await db.query(
      'diary_entries',
      where: 'user_id = ? AND profile_type = ? AND entry_date BETWEEN ? AND ? AND deleted_at IS NULL',
      whereArgs: [userId, profileType, startDateStr, endDateStr],
      orderBy: 'entry_date ASC, created_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Get diary entries by meal time
  /// Requirements: 4.4 - Meal time categorization
  Future<List<LocalDiaryEntry>> getDiaryEntriesByMealTime({
    required int userId,
    required String profileType,
    required DateTime date,
    required String mealTime,
  }) async {
    final db = await _dbHelper.database;
    final dateStr = _formatDate(date);

    final maps = await db.query(
      'diary_entries',
      where: 'user_id = ? AND profile_type = ? AND entry_date = ? AND meal_time = ? AND deleted_at IS NULL',
      whereArgs: [userId, profileType, dateStr, mealTime],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Update diary entry
  Future<int> updateDiaryEntry(LocalDiaryEntry entry) async {
    final db = await _dbHelper.database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Soft delete diary entry (mark as deleted for sync)
  /// Requirements: 4.5 - Delete with sync tracking
  Future<int> deleteDiaryEntry(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'diary_entries',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hard delete diary entry (remove from database)
  Future<int> hardDeleteDiaryEntry(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get pending sync entries
  Future<List<LocalDiaryEntry>> getPendingSyncEntries() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'diary_entries',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Get failed sync entries
  Future<List<LocalDiaryEntry>> getFailedSyncEntries() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'diary_entries',
      where: 'sync_status = ?',
      whereArgs: ['failed'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Get entries modified after a specific time
  /// Used for incremental sync
  Future<List<LocalDiaryEntry>> getEntriesModifiedAfter(DateTime timestamp) async {
    final db = await _dbHelper.database;
    final timestampStr = timestamp.toIso8601String();

    final maps = await db.query(
      'diary_entries',
      where: 'updated_at > ? AND sync_status IN (?, ?)',
      whereArgs: [timestampStr, 'pending', 'failed'],
      orderBy: 'updated_at ASC',
    );

    return maps.map((map) => LocalDiaryEntry.fromMap(map)).toList();
  }

  /// Get deleted entry IDs after a specific time
  /// Used for sync deletions
  Future<List<String>> getDeletedIdsAfter(DateTime timestamp) async {
    final db = await _dbHelper.database;
    final timestampStr = timestamp.toIso8601String();

    final maps = await db.query(
      'diary_entries',
      columns: ['server_id'],
      where: 'deleted_at IS NOT NULL AND deleted_at > ? AND server_id IS NOT NULL',
      whereArgs: [timestampStr],
    );

    return maps
        .map((map) => map['server_id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Update sync status for multiple entries
  Future<void> updateSyncStatus(List<int> ids, String status) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final id in ids) {
      batch.update(
        'diary_entries',
        {'sync_status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Insert or update entry from server
  /// Used during sync to apply server changes
  Future<int> insertOrUpdateFromServer(LocalDiaryEntry entry) async {
    final db = await _dbHelper.database;

    // Check if entry with server_id exists
    if (entry.serverId != null) {
      final existing = await db.query(
        'diary_entries',
        where: 'server_id = ?',
        whereArgs: [entry.serverId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing entry
        final existingId = existing.first['id'] as int;
        await db.update(
          'diary_entries',
          entry.copyWith(id: existingId, syncStatus: 'synced').toMap(),
          where: 'id = ?',
          whereArgs: [existingId],
        );
        return existingId;
      }
    }

    // Insert new entry
    return await db.insert(
      'diary_entries',
      entry.copyWith(syncStatus: 'synced').toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Calculate nutrition summary for a date
  /// Requirements: 4.3, 4.6 - Nutrition tracking and summary
  Future<Map<String, double>> calculateNutritionSummary({
    required int userId,
    required String profileType,
    required DateTime date,
  }) async {
    final db = await _dbHelper.database;
    final dateStr = _formatDate(date);

    final result = await db.rawQuery('''
      SELECT 
        SUM(calories) as total_calories,
        SUM(protein) as total_protein,
        SUM(carbs) as total_carbs,
        SUM(fat) as total_fat
      FROM diary_entries
      WHERE user_id = ? AND profile_type = ? AND entry_date = ? AND deleted_at IS NULL
    ''', [userId, profileType, dateStr]);

    if (result.isEmpty) {
      return {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
      };
    }

    final row = result.first;
    return {
      'calories': (row['total_calories'] as num?)?.toDouble() ?? 0.0,
      'protein': (row['total_protein'] as num?)?.toDouble() ?? 0.0,
      'carbs': (row['total_carbs'] as num?)?.toDouble() ?? 0.0,
      'fat': (row['total_fat'] as num?)?.toDouble() ?? 0.0,
    };
  }

  /// Get count of diary entries
  Future<int> getDiaryEntriesCount({
    required int userId,
    String? profileType,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'user_id = ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [userId];

    if (profileType != null) {
      whereClause += ' AND profile_type = ?';
      whereArgs.add(profileType);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE $whereClause',
      whereArgs,
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all diary entries for a user
  Future<void> clearAllDiaryEntries(int userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'diary_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
