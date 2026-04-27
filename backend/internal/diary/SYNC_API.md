# Diary Sync API Documentation

## Overview

The Diary Sync API provides bidirectional synchronization between client (mobile app) and server for food diary entries. It implements conflict detection and resolution to ensure data consistency across offline and online states.

## Sync Strategy

### Timestamp-Based Synchronization

The sync mechanism uses timestamps to track changes:
- `created_at`: When the entry was first created
- `updated_at`: When the entry was last modified
- `deleted_at`: When the entry was soft-deleted (null if active)

### Conflict Detection

Conflicts occur when:
1. **Update Conflict**: Both client and server have modified the same entry since last sync, and server's version is newer
2. **Delete Conflict**: Client tries to delete an entry that was modified on server after client's last sync

### Conflict Resolution

When conflicts are detected, the API returns conflict information and requires explicit resolution:
- `use_server`: Keep the server version and discard client changes
- `use_client`: Apply client changes and overwrite server version

## API Endpoints

### 1. Sync Diary Entries

**Endpoint**: `POST /api/diary/sync`

**Authentication**: Required (JWT Bearer token)

**Request Body**:
```json
{
  "last_sync_time": "2024-01-15T10:30:00Z",
  "entries": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "profile_type": "baby",
      "food_id": "660e8400-e29b-41d4-a716-446655440001",
      "custom_food_name": null,
      "serving_size": 100.0,
      "meal_time": "breakfast",
      "calories": 150.0,
      "protein": 5.0,
      "carbs": 20.0,
      "fat": 3.0,
      "entry_date": "2024-01-15",
      "updated_at": "2024-01-15T08:00:00Z"
    }
  ],
  "deleted_ids": [
    "770e8400-e29b-41d4-a716-446655440002"
  ]
}
```

**Request Fields**:
- `last_sync_time` (string, optional): RFC3339 timestamp of last successful sync. Empty string or omitted for first sync.
- `entries` (array): Diary entries created or modified on client since last sync
- `deleted_ids` (array): UUIDs of entries deleted on client since last sync

**Response**:
```json
{
  "entries": [
    {
      "id": "880e8400-e29b-41d4-a716-446655440003",
      "user_id": "990e8400-e29b-41d4-a716-446655440004",
      "profile_type": "mother",
      "food_id": "aa0e8400-e29b-41d4-a716-446655440005",
      "custom_food_name": null,
      "serving_size": 200.0,
      "meal_time": "lunch",
      "calories": 300.0,
      "protein": 10.0,
      "carbs": 40.0,
      "fat": 8.0,
      "entry_date": "2024-01-15T00:00:00Z",
      "created_at": "2024-01-15T12:00:00Z",
      "updated_at": "2024-01-15T12:30:00Z",
      "food": {
        "id": "aa0e8400-e29b-41d4-a716-446655440005",
        "name": "Nasi Putih",
        "category": "ibu",
        "calories_per_100g": 150.0,
        "protein_per_100g": 5.0,
        "carbs_per_100g": 20.0,
        "fat_per_100g": 4.0
      }
    }
  ],
  "deleted_ids": [
    "bb0e8400-e29b-41d4-a716-446655440006"
  ],
  "conflicts": [
    {
      "entry_id": "cc0e8400-e29b-41d4-a716-446655440007",
      "client_entry": {
        "id": "cc0e8400-e29b-41d4-a716-446655440007",
        "profile_type": "baby",
        "serving_size": 120.0,
        "meal_time": "breakfast",
        "calories": 180.0,
        "protein": 6.0,
        "carbs": 22.0,
        "fat": 4.0,
        "entry_date": "2024-01-15",
        "updated_at": "2024-01-15T08:00:00Z"
      },
      "server_entry": {
        "id": "cc0e8400-e29b-41d4-a716-446655440007",
        "user_id": "990e8400-e29b-41d4-a716-446655440004",
        "profile_type": "baby",
        "serving_size": 100.0,
        "meal_time": "breakfast",
        "calories": 150.0,
        "protein": 5.0,
        "carbs": 20.0,
        "fat": 3.0,
        "entry_date": "2024-01-15T00:00:00Z",
        "created_at": "2024-01-15T07:00:00Z",
        "updated_at": "2024-01-15T09:00:00Z"
      },
      "conflict_type": "update_conflict"
    }
  ]
}
```

**Response Fields**:
- `entries`: New or updated entries from server since client's last sync
- `deleted_ids`: UUIDs of entries deleted on server since client's last sync
- `conflicts`: Array of conflicts that require resolution

**Status Codes**:
- `200 OK`: Sync successful
- `400 Bad Request`: Invalid request format
- `401 Unauthorized`: Missing or invalid JWT token
- `500 Internal Server Error`: Server error

### 2. Resolve Conflict

**Endpoint**: `POST /api/diary/resolve-conflict`

**Authentication**: Required (JWT Bearer token)

**Request Body (Use Server)**:
```json
{
  "entry_id": "cc0e8400-e29b-41d4-a716-446655440007",
  "resolution": "use_server"
}
```

**Request Body (Use Client)**:
```json
{
  "entry_id": "cc0e8400-e29b-41d4-a716-446655440007",
  "resolution": "use_client",
  "entry": {
    "id": "cc0e8400-e29b-41d4-a716-446655440007",
    "profile_type": "baby",
    "serving_size": 120.0,
    "meal_time": "breakfast",
    "calories": 180.0,
    "protein": 6.0,
    "carbs": 22.0,
    "fat": 4.0,
    "entry_date": "2024-01-15",
    "updated_at": "2024-01-15T08:00:00Z"
  }
}
```

**Request Fields**:
- `entry_id` (string, required): UUID of the conflicting entry
- `resolution` (string, required): Either "use_server" or "use_client"
- `entry` (object, required if resolution is "use_client"): Client's version of the entry

**Response**:
```json
{
  "id": "cc0e8400-e29b-41d4-a716-446655440007",
  "user_id": "990e8400-e29b-41d4-a716-446655440004",
  "profile_type": "baby",
  "serving_size": 120.0,
  "meal_time": "breakfast",
  "calories": 180.0,
  "protein": 6.0,
  "carbs": 22.0,
  "fat": 4.0,
  "entry_date": "2024-01-15T00:00:00Z",
  "created_at": "2024-01-15T07:00:00Z",
  "updated_at": "2024-01-15T10:45:00Z"
}
```

**Status Codes**:
- `200 OK`: Conflict resolved successfully
- `400 Bad Request`: Invalid request format or resolution type
- `401 Unauthorized`: Missing or invalid JWT token
- `404 Not Found`: Entry not found
- `500 Internal Server Error`: Server error

## Client Implementation Guide

### Initial Sync

On first app launch or after fresh install:

```dart
// First sync - no last_sync_time
final response = await syncDiaryEntries(
  lastSyncTime: null,
  entries: [],
  deletedIds: [],
);

// Store all entries from server to local database
for (var entry in response.entries) {
  await localDB.insertOrUpdate(entry);
}

// Store current time as last sync time
await storage.setLastSyncTime(DateTime.now().toIso8601String());
```

### Regular Sync

When app comes online or user triggers sync:

```dart
// Get last sync time from storage
final lastSyncTime = await storage.getLastSyncTime();

// Get local changes since last sync
final localEntries = await localDB.getEntriesModifiedAfter(lastSyncTime);
final deletedIds = await localDB.getDeletedIdsAfter(lastSyncTime);

// Perform sync
final response = await syncDiaryEntries(
  lastSyncTime: lastSyncTime,
  entries: localEntries,
  deletedIds: deletedIds,
);

// Apply server changes to local database
for (var entry in response.entries) {
  await localDB.insertOrUpdate(entry);
}

for (var deletedId in response.deletedIds) {
  await localDB.delete(deletedId);
}

// Handle conflicts
if (response.conflicts.isNotEmpty) {
  for (var conflict in response.conflicts) {
    // Show conflict resolution UI to user
    final resolution = await showConflictDialog(conflict);
    
    // Resolve conflict
    final resolved = await resolveConflict(
      entryId: conflict.entryId,
      resolution: resolution, // "use_server" or "use_client"
      entry: resolution == "use_client" ? conflict.clientEntry : null,
    );
    
    // Update local database with resolved entry
    await localDB.insertOrUpdate(resolved);
  }
}

// Update last sync time
await storage.setLastSyncTime(DateTime.now().toIso8601String());
```

### Offline-First Strategy

1. **Create Entry Offline**:
   - Generate UUID on client
   - Save to local SQLite with current timestamp
   - Mark as "pending sync"

2. **Update Entry Offline**:
   - Update local SQLite
   - Update `updated_at` timestamp
   - Mark as "pending sync"

3. **Delete Entry Offline**:
   - Soft delete in local SQLite (set `deleted_at`)
   - Mark as "pending sync"

4. **Sync When Online**:
   - Send all pending changes to server
   - Apply server changes to local database
   - Resolve conflicts if any
   - Clear "pending sync" flags

## Conflict Resolution Best Practices

### Update Conflicts

When both client and server have modified the same entry:

1. **Show Both Versions**: Display client and server versions side-by-side
2. **Highlight Differences**: Show which fields differ
3. **User Choice**: Let user choose which version to keep
4. **Merge Option**: Optionally allow user to manually merge changes

### Delete Conflicts

When client tries to delete an entry that was modified on server:

1. **Show Server Version**: Display the updated server entry
2. **Confirm Deletion**: Ask user if they still want to delete
3. **Keep Option**: Allow user to keep the server version

## Error Handling

### Network Errors

```dart
try {
  final response = await syncDiaryEntries(...);
} on NetworkException {
  // Queue sync for retry when network is available
  await syncQueue.add(syncRequest);
}
```

### Conflict Errors

```dart
if (response.conflicts.isNotEmpty) {
  // Store conflicts for later resolution
  await conflictStore.saveConflicts(response.conflicts);
  
  // Notify user
  showNotification("Sync conflicts need resolution");
}
```

### Server Errors

```dart
try {
  final response = await syncDiaryEntries(...);
} on ServerException catch (e) {
  if (e.statusCode == 500) {
    // Retry with exponential backoff
    await retryWithBackoff(() => syncDiaryEntries(...));
  }
}
```

## Performance Considerations

### Batch Size

For large datasets, consider batching sync requests:

```dart
const BATCH_SIZE = 100;

final allEntries = await localDB.getPendingEntries();
for (var i = 0; i < allEntries.length; i += BATCH_SIZE) {
  final batch = allEntries.sublist(
    i, 
    min(i + BATCH_SIZE, allEntries.length)
  );
  
  await syncDiaryEntries(
    lastSyncTime: lastSyncTime,
    entries: batch,
    deletedIds: [],
  );
}
```

### Incremental Sync

Only sync data that has changed:

```dart
// Track last sync time per profile type
final babyLastSync = await storage.getLastSyncTime('baby');
final motherLastSync = await storage.getLastSyncTime('mother');

// Sync only changed data
final babyEntries = await localDB.getEntriesModifiedAfter(
  babyLastSync, 
  profileType: 'baby'
);
```

## Testing

Run sync tests:

```bash
cd backend
go test ./internal/diary -v -run TestSync
```

Expected output:
```
=== RUN   TestSyncDiaryEntries_NewEntriesFromClient
--- PASS: TestSyncDiaryEntries_NewEntriesFromClient (0.01s)
=== RUN   TestSyncDiaryEntries_UpdateConflict
--- PASS: TestSyncDiaryEntries_UpdateConflict (0.01s)
=== RUN   TestSyncDiaryEntries_ClientHasNewerVersion
--- PASS: TestSyncDiaryEntries_ClientHasNewerVersion (0.01s)
...
PASS
```
