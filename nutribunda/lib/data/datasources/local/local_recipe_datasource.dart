import 'package:sqflite/sqflite.dart';
import '../../models/local/local_recipe_model.dart';
import 'database_helper.dart';

/// Local Recipe Data Source
/// Handles CRUD operations for recipes in SQLite
/// Requirements: 6.1, 6.4, 7.1, 7.4 - Recipe storage and favorites
class LocalRecipeDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert recipe
  Future<int> insertRecipe(LocalRecipeModel recipe) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'recipes',
      recipe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple recipes (batch operation)
  Future<void> insertRecipes(List<LocalRecipeModel> recipes) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final recipe in recipes) {
      batch.insert(
        'recipes',
        recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get recipe by local ID
  Future<LocalRecipeModel?> getRecipeById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalRecipeModel.fromMap(maps.first);
  }

  /// Get recipe by server ID
  Future<LocalRecipeModel?> getRecipeByServerId(String serverId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalRecipeModel.fromMap(maps.first);
  }

  /// Get all recipes by category
  Future<List<LocalRecipeModel>> getRecipesByCategory(String category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'recipes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );

    return maps.map((map) => LocalRecipeModel.fromMap(map)).toList();
  }

  /// Get random recipe
  /// Requirements: 6.1 - Random recipe for shake-to-recipe
  Future<LocalRecipeModel?> getRandomRecipe({String? category}) async {
    final db = await _dbHelper.database;
    
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    }

    final maps = await db.query(
      'recipes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalRecipeModel.fromMap(maps.first);
  }

  /// Get all recipes
  Future<List<LocalRecipeModel>> getAllRecipes() async {
    final db = await _dbHelper.database;
    final maps = await db.query('recipes', orderBy: 'name ASC');
    return maps.map((map) => LocalRecipeModel.fromMap(map)).toList();
  }

  /// Update recipe
  Future<int> updateRecipe(LocalRecipeModel recipe) async {
    final db = await _dbHelper.database;
    return await db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  /// Delete recipe
  Future<int> deleteRecipe(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get count of recipes
  Future<int> getRecipesCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM recipes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all recipes
  Future<void> clearAllRecipes() async {
    final db = await _dbHelper.database;
    await db.delete('recipes');
  }
}

/// Local Favorite Recipe Data Source
/// Handles favorite recipes operations
/// Requirements: 7.1, 7.2, 7.3, 7.4 - Favorite recipes management
class LocalFavoriteRecipeDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add recipe to favorites
  Future<int> addFavorite({
    required int userId,
    required int recipeId,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'favorite_recipes',
      {
        'user_id': userId,
        'recipe_id': recipeId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove recipe from favorites (soft delete)
  Future<int> removeFavorite({
    required int userId,
    required int recipeId,
  }) async {
    final db = await _dbHelper.database;
    return await db.update(
      'favorite_recipes',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      },
      where: 'user_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
  }

  /// Hard delete favorite
  Future<int> hardDeleteFavorite({
    required int userId,
    required int recipeId,
  }) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'favorite_recipes',
      where: 'user_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
  }

  /// Check if recipe is favorite
  Future<bool> isFavorite({
    required int userId,
    required int recipeId,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM favorite_recipes 
      WHERE user_id = ? AND recipe_id = ? AND deleted_at IS NULL
    ''', [userId, recipeId]);
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Get all favorite recipes for a user
  /// Requirements: 7.2 - Display favorite recipes
  Future<List<LocalRecipeModel>> getFavoriteRecipes(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT r.* 
      FROM recipes r
      INNER JOIN favorite_recipes f ON r.id = f.recipe_id
      WHERE f.user_id = ? AND f.deleted_at IS NULL
      ORDER BY f.created_at DESC
    ''', [userId]);

    return maps.map((map) => LocalRecipeModel.fromMap(map)).toList();
  }

  /// Get pending sync favorites
  Future<List<Map<String, dynamic>>> getPendingSyncFavorites() async {
    final db = await _dbHelper.database;
    return await db.query(
      'favorite_recipes',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  /// Get count of favorite recipes
  Future<int> getFavoritesCount(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM favorite_recipes 
      WHERE user_id = ? AND deleted_at IS NULL
    ''', [userId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all favorites for a user
  Future<void> clearAllFavorites(int userId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorite_recipes',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
