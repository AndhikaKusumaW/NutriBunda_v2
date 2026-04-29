import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:nutribunda/data/datasources/local/database_helper.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      await dbHelper.deleteDatabase();
    });

    test('should create database successfully', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create all required tables', () async {
      final db = await dbHelper.database;
      
      // Query sqlite_master to get all tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      // Verify all required tables exist
      expect(tableNames, contains('users'));
      expect(tableNames, contains('foods'));
      expect(tableNames, contains('recipes'));
      expect(tableNames, contains('diary_entries'));
      expect(tableNames, contains('favorite_recipes'));
      expect(tableNames, contains('quiz_questions'));
      expect(tableNames, contains('notifications'));
      expect(tableNames, contains('sync_metadata'));
    });

    test('should create indexes on foods table', () async {
      final db = await dbHelper.database;
      
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='foods'"
      );
      
      final indexNames = indexes.map((i) => i['name'] as String).toList();
      
      expect(indexNames, contains('idx_foods_name'));
      expect(indexNames, contains('idx_foods_category'));
    });

    test('should create indexes on diary_entries table', () async {
      final db = await dbHelper.database;
      
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='diary_entries'"
      );
      
      final indexNames = indexes.map((i) => i['name'] as String).toList();
      
      expect(indexNames, contains('idx_diary_user_date'));
      expect(indexNames, contains('idx_diary_profile_type'));
      expect(indexNames, contains('idx_diary_sync_status'));
    });

    test('should clear all data', () async {
      final db = await dbHelper.database;
      
      // Insert test data
      await db.insert('users', {
        'email': 'test@example.com',
        'full_name': 'Test User',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Verify data exists
      var users = await db.query('users');
      expect(users.length, 1);
      
      // Clear all data
      await dbHelper.clearAllData();
      
      // Verify data is cleared
      users = await db.query('users');
      expect(users.length, 0);
    });
  });
}
