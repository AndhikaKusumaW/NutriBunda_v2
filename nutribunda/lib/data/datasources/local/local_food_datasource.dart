import 'package:sqflite/sqflite.dart';
import '../../models/local/local_food_model.dart';
import 'database_helper.dart';

/// Local Food Data Source
/// Handles CRUD operations for foods in SQLite
/// Requirements: 3.2, 3.3 - Local food database with search functionality
class LocalFoodDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert food into local database
  Future<int> insertFood(LocalFoodModel food) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple foods (batch operation)
  Future<void> insertFoods(List<LocalFoodModel> foods) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final food in foods) {
      batch.insert(
        'foods',
        food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get food by local ID
  Future<LocalFoodModel?> getFoodById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalFoodModel.fromMap(maps.first);
  }

  /// Get food by server ID
  Future<LocalFoodModel?> getFoodByServerId(String serverId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'foods',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalFoodModel.fromMap(maps.first);
  }

  /// Search foods by name
  /// Requirements: 3.2 - Search functionality
  Future<List<LocalFoodModel>> searchFoods({
    required String query,
    String? category,
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = 'name LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];

    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final maps = await db.query(
      'foods',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
      limit: limit,
    );

    return maps.map((map) => LocalFoodModel.fromMap(map)).toList();
  }

  /// Get all foods by category
  Future<List<LocalFoodModel>> getFoodsByCategory(String category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'foods',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );

    return maps.map((map) => LocalFoodModel.fromMap(map)).toList();
  }

  /// Get all foods
  Future<List<LocalFoodModel>> getAllFoods() async {
    final db = await _dbHelper.database;
    final maps = await db.query('foods', orderBy: 'name ASC');
    return maps.map((map) => LocalFoodModel.fromMap(map)).toList();
  }

  /// Update food
  Future<int> updateFood(LocalFoodModel food) async {
    final db = await _dbHelper.database;
    return await db.update(
      'foods',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  /// Delete food by local ID
  Future<int> deleteFood(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete food by server ID
  Future<int> deleteFoodByServerId(String serverId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'foods',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
  }

  /// Delete multiple foods by server IDs (for sync)
  Future<void> deleteFoodsByServerIds(List<String> serverIds) async {
    if (serverIds.isEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final serverId in serverIds) {
      batch.delete(
        'foods',
        where: 'server_id = ?',
        whereArgs: [serverId],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get count of foods
  Future<int> getFoodsCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM foods');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all foods
  Future<void> clearAllFoods() async {
    final db = await _dbHelper.database;
    await db.delete('foods');
  }

  /// Update last sync time for foods
  Future<void> updateLastSyncTime(DateTime syncTime) async {
    final db = await _dbHelper.database;
    await db.insert(
      'sync_metadata',
      {
        'table_name': 'foods',
        'last_sync_at': syncTime.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get last sync time for foods
  Future<DateTime?> getLastSyncTime() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sync_metadata',
      where: 'table_name = ?',
      whereArgs: ['foods'],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DateTime.parse(maps.first['last_sync_at'] as String);
  }
}
