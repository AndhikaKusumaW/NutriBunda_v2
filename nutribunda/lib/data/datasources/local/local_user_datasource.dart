import 'package:sqflite/sqflite.dart';
import '../../models/local/local_user_model.dart';
import 'database_helper.dart';

/// Local User Data Source
/// Handles CRUD operations for users in SQLite
class LocalUserDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert user
  Future<int> insertUser(LocalUserModel user) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user by local ID
  Future<LocalUserModel?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalUserModel.fromMap(maps.first);
  }

  /// Get user by server ID
  Future<LocalUserModel?> getUserByServerId(String serverId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalUserModel.fromMap(maps.first);
  }

  /// Get user by email
  Future<LocalUserModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalUserModel.fromMap(maps.first);
  }

  /// Get current user (assumes single user per device)
  Future<LocalUserModel?> getCurrentUser() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LocalUserModel.fromMap(maps.first);
  }

  /// Update user
  Future<int> updateUser(LocalUserModel user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete user
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clear all users
  Future<void> clearAllUsers() async {
    final db = await _dbHelper.database;
    await db.delete('users');
  }

  /// Check if user exists
  Future<bool> userExists(String email) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE email = ?',
      [email],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
