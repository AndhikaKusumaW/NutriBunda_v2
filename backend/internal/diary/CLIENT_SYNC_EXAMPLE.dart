// Example Flutter client implementation for diary sync
// This file demonstrates how to implement offline-first sync in the Flutter app

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================================================
// Models
// ============================================================================

class DiaryEntry {
  final String id;
  final String profileType;
  final String? foodId;
  final String? customFoodName;
  final double servingSize;
  final String mealTime;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime entryDate;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool pendingSync;

  DiaryEntry({
    required this.id,
    required this.profileType,
    this.foodId,
    this.customFoodName,
    required this.servingSize,
    required this.mealTime,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.entryDate,
    required this.updatedAt,
    this.deletedAt,
    this.pendingSync = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'profile_type': profileType,
    'food_id': foodId,
    'custom_food_name': customFoodName,
    'serving_size': servingSize,
    'meal_time': mealTime,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'entry_date': entryDate.toIso8601String().split('T')[0],
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'],
    profileType: json['profile_type'],
    foodId: json['food_id'],
    customFoodName: json['custom_food_name'],
    servingSize: json['serving_size'].toDouble(),
    mealTime: json['meal_time'],
    calories: json['calories'].toDouble(),
    protein: json['protein'].toDouble(),
    carbs: json['carbs'].toDouble(),
    fat: json['fat'].toDouble(),
    entryDate: DateTime.parse(json['entry_date']),
    updatedAt: DateTime.parse(json['updated_at']),
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
  );
}

class SyncConflict {
  final String entryId;
  final DiaryEntry clientEntry;
  final DiaryEntry serverEntry;
  final String conflictType;

  SyncConflict({
    required this.entryId,
    required this.clientEntry,
    required this.serverEntry,
    required this.conflictType,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
    entryId: json['entry_id'],
    clientEntry: DiaryEntry.fromJson(json['client_entry']),
    serverEntry: DiaryEntry.fromJson(json['server_entry']),
    conflictType: json['conflict_type'],
  );
}

// ============================================================================
// Local Database Service
// ============================================================================

class LocalDiaryDatabase {
  final Database db;

  LocalDiaryDatabase(this.db);

  static Future<LocalDiaryDatabase> initialize() async {
    final db = await openDatabase(
      'nutribunda.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_entries (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            profile_type TEXT NOT NULL,
            food_id TEXT,
            custom_food_name TEXT,
            serving_size REAL NOT NULL,
            meal_time TEXT NOT NULL,
            calories REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            entry_date TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT,
            pending_sync INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return LocalDiaryDatabase(db);
  }

  Future<void> insertOrUpdate(DiaryEntry entry) async {
    await db.insert(
      'diary_entries',
      {
        'id': entry.id,
        'profile_type': entry.profileType,
        'food_id': entry.foodId,
        'custom_food_name': entry.customFoodName,
        'serving_size': entry.servingSize,
        'meal_time': entry.mealTime,
        'calories': entry.calories,
        'protein': entry.protein,
        'carbs': entry.carbs,
        'fat': entry.fat,
        'entry_date': entry.entryDate.toIso8601String().split('T')[0],
        'updated_at': entry.updatedAt.toIso8601String(),
        'deleted_at': entry.deletedAt?.toIso8601String(),
        'pending_sync': entry.pendingSync ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getPendingEntries() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'pending_sync = ? AND deleted_at IS NULL',
      whereArgs: [1],
    );
    return maps.map((map) => _entryFromMap(map)).toList();
  }

  Future<List<String>> getPendingDeletedIds() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      columns: ['id'],
      where: 'pending_sync = ? AND deleted_at IS NOT NULL',
      whereArgs: [1],
    );
    return maps.map((map) => map['id'] as String).toList();
  }

  Future<void> markAsSynced(String id) async {
    await db.update(
      'diary_entries',
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> softDelete(String id) async {
    await db.update(
      'diary_entries',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'pending_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  DiaryEntry _entryFromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      profileType: map['profile_type'],
      foodId: map['food_id'],
      customFoodName: map['custom_food_name'],
      servingSize: map['serving_size'],
      mealTime: map['meal_time'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      entryDate: DateTime.parse(map['entry_date']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      pendingSync: map['pending_sync'] == 1,
    );
  }
}

// ============================================================================
// Sync Service
// ============================================================================

class DiarySyncService {
  final String baseUrl;
  final LocalDiaryDatabase localDb;
  final FlutterSecureStorage storage;

  DiarySyncService({
    required this.baseUrl,
    required this.localDb,
    required this.storage,
  });

  Future<String?> _getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<String?> _getLastSyncTime() async {
    return await storage.read(key: 'last_sync_time');
  }

  Future<void> _setLastSyncTime(String time) async {
    await storage.write(key: 'last_sync_time', value: time);
  }

  /// Perform full sync with server
  Future<SyncResult> sync() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final lastSyncTime = await _getLastSyncTime();
      
      // Get pending changes from local database
      final pendingEntries = await localDb.getPendingEntries();
      final pendingDeletedIds = await localDb.getPendingDeletedIds();

      // Prepare sync request
      final requestBody = {
        'last_sync_time': lastSyncTime ?? '',
        'entries': pendingEntries.map((e) => e.toJson()).toList(),
        'deleted_ids': pendingDeletedIds,
      };

      // Send sync request
      final response = await http.post(
        Uri.parse('$baseUrl/api/diary/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Sync failed: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);

      // Process server entries
      final serverEntries = (responseData['entries'] as List)
          .map((e) => DiaryEntry.fromJson(e))
          .toList();

      for (var entry in serverEntries) {
        await localDb.insertOrUpdate(entry);
      }

      // Process server deletions
      final serverDeletedIds = (responseData['deleted_ids'] as List)
          .map((id) => id as String)
          .toList();

      for (var id in serverDeletedIds) {
        await localDb.delete(id);
      }

      // Mark synced entries as no longer pending
      for (var entry in pendingEntries) {
        await localDb.markAsSynced(entry.id);
      }

      // Process conflicts
      final conflicts = (responseData['conflicts'] as List)
          .map((c) => SyncConflict.fromJson(c))
          .toList();

      // Update last sync time
      await _setLastSyncTime(DateTime.now().toIso8601String());

      return SyncResult(
        success: true,
        conflicts: conflicts,
        syncedCount: pendingEntries.length + pendingDeletedIds.length,
        receivedCount: serverEntries.length + serverDeletedIds.length,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Resolve a sync conflict
  Future<DiaryEntry?> resolveConflict({
    required String entryId,
    required String resolution, // 'use_server' or 'use_client'
    DiaryEntry? clientEntry,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final requestBody = {
        'entry_id': entryId,
        'resolution': resolution,
        if (clientEntry != null) 'entry': clientEntry.toJson(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/diary/resolve-conflict'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('Conflict resolution failed: ${response.statusCode}');
      }

      final resolvedEntry = DiaryEntry.fromJson(jsonDecode(response.body));
      
      // Update local database
      await localDb.insertOrUpdate(resolvedEntry);
      await localDb.markAsSynced(resolvedEntry.id);

      return resolvedEntry;
    } catch (e) {
      print('Error resolving conflict: $e');
      return null;
    }
  }

  /// Create entry offline
  Future<DiaryEntry> createEntryOffline({
    required String profileType,
    String? foodId,
    String? customFoodName,
    required double servingSize,
    required String mealTime,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required DateTime entryDate,
  }) async {
    final entry = DiaryEntry(
      id: _generateUuid(),
      profileType: profileType,
      foodId: foodId,
      customFoodName: customFoodName,
      servingSize: servingSize,
      mealTime: mealTime,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      entryDate: entryDate,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    await localDb.insertOrUpdate(entry);
    return entry;
  }

  /// Update entry offline
  Future<void> updateEntryOffline(DiaryEntry entry) async {
    final updatedEntry = DiaryEntry(
      id: entry.id,
      profileType: entry.profileType,
      foodId: entry.foodId,
      customFoodName: entry.customFoodName,
      servingSize: entry.servingSize,
      mealTime: entry.mealTime,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      entryDate: entry.entryDate,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );

    await localDb.insertOrUpdate(updatedEntry);
  }

  /// Delete entry offline
  Future<void> deleteEntryOffline(String id) async {
    await localDb.softDelete(id);
  }

  String _generateUuid() {
    // Use uuid package in production
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// ============================================================================
// Sync Result
// ============================================================================

class SyncResult {
  final bool success;
  final List<SyncConflict> conflicts;
  final int syncedCount;
  final int receivedCount;
  final String? error;

  SyncResult({
    required this.success,
    this.conflicts = const [],
    this.syncedCount = 0,
    this.receivedCount = 0,
    this.error,
  });

  bool get hasConflicts => conflicts.isNotEmpty;
}

// ============================================================================
// Usage Example
// ============================================================================

void main() async {
  // Initialize services
  final localDb = await LocalDiaryDatabase.initialize();
  final storage = FlutterSecureStorage();
  final syncService = DiarySyncService(
    baseUrl: 'http://localhost:8080',
    localDb: localDb,
    storage: storage,
  );

  // Create entry offline
  final entry = await syncService.createEntryOffline(
    profileType: 'baby',
    servingSize: 100,
    mealTime: 'breakfast',
    calories: 150,
    protein: 5,
    carbs: 20,
    fat: 3,
    entryDate: DateTime.now(),
  );
  print('Created entry offline: ${entry.id}');

  // Sync when online
  final result = await syncService.sync();
  if (result.success) {
    print('Sync successful!');
    print('Synced ${result.syncedCount} entries');
    print('Received ${result.receivedCount} entries');

    if (result.hasConflicts) {
      print('Found ${result.conflicts.length} conflicts');
      
      // Handle conflicts
      for (var conflict in result.conflicts) {
        print('Conflict for entry ${conflict.entryId}');
        print('Type: ${conflict.conflictType}');
        
        // Show conflict resolution UI to user
        // For this example, we'll use server version
        final resolved = await syncService.resolveConflict(
          entryId: conflict.entryId,
          resolution: 'use_server',
        );
        
        if (resolved != null) {
          print('Conflict resolved: ${resolved.id}');
        }
      }
    }
  } else {
    print('Sync failed: ${result.error}');
  }
}
