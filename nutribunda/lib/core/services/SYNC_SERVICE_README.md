# Sync Service Documentation

## Overview

The Sync Service provides bidirectional synchronization between the local SQLite database and the backend server for diary entries. It implements conflict detection and resolution to ensure data consistency across offline and online states.

## Features

- **Bidirectional Sync**: Syncs data from client to server and server to client
- **Conflict Detection**: Detects update and delete conflicts using timestamps
- **Conflict Resolution**: Provides strategies to resolve conflicts (use_client, use_server)
- **Background Sync**: Automatically syncs when connectivity is restored
- **Connectivity Monitoring**: Monitors network status and triggers sync on reconnection
- **Retry Mechanism**: Retries failed sync operations
- **Sync Status Tracking**: Tracks pending, synced, and failed entries

## Architecture

```
┌─────────────────────┐
│   SyncProvider      │  ← UI State Management
│   (ChangeNotifier)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   SyncService       │  ← Core Sync Logic
│                     │
│  - syncDiaryEntries │
│  - resolveConflict  │
│  - retryFailedSync  │
└──────────┬──────────┘
           │
           ├──────────────────┬──────────────────┐
           ▼                  ▼                  ▼
┌──────────────────┐  ┌──────────────┐  ┌──────────────┐
│ HttpClientService│  │LocalDiaryData│  │SecureStorage │
│                  │  │Source        │  │Service       │
└──────────────────┘  └──────────────┘  └──────────────┘
```

## Usage

### 1. Initialize Sync Service

```dart
final syncService = SyncService(
  httpClient: httpClientService,
  localDiary: localDiaryDataSource,
  storage: secureStorageService,
  onSyncStatusChanged: (status) {
    print('Sync status: $status');
  },
  onConflictsDetected: (conflicts) {
    print('Conflicts detected: ${conflicts.length}');
  },
);
```

### 2. Start Background Sync

```dart
// Start background sync with 15-minute interval
syncService.startBackgroundSync();

// Or with custom interval
syncService.startBackgroundSync(
  interval: Duration(minutes: 30),
);
```

### 3. Manual Sync

```dart
// Trigger manual sync
final success = await syncService.syncDiaryEntries();

if (success) {
  print('Sync completed successfully');
} else {
  print('Sync failed or has conflicts');
}
```

### 4. Handle Conflicts

```dart
// Resolve conflict using server version
await syncService.resolveConflict(
  entryId: conflictId,
  resolution: 'use_server',
);

// Resolve conflict using client version
await syncService.resolveConflict(
  entryId: conflictId,
  resolution: 'use_client',
  clientEntry: {
    'id': entryId,
    'profile_type': 'baby',
    'serving_size': 120.0,
    // ... other fields
  },
);
```

### 5. Using SyncProvider (Recommended)

```dart
// In your widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => SyncProvider(syncService: syncService),
    ),
  ],
  child: MyApp(),
)

// In your widget
Consumer<SyncProvider>(
  builder: (context, syncProvider, child) {
    return Column(
      children: [
        Text('Status: ${syncProvider.getSyncStatusText()}'),
        if (syncProvider.hasConflicts)
          Text('Conflicts: ${syncProvider.conflicts.length}'),
        ElevatedButton(
          onPressed: syncProvider.syncNow,
          child: Text('Sync Now'),
        ),
      ],
    );
  },
)
```

## Sync Flow

### Initial Sync (First Time)

1. App starts with empty local database
2. User logs in
3. Sync service sends empty sync request with no `last_sync_time`
4. Server returns all user's diary entries
5. Local database is populated with server data
6. `last_sync_time` is stored

### Regular Sync

1. User creates/updates/deletes entries offline
2. Entries are marked as `sync_status: 'pending'`
3. When connectivity is restored, sync is triggered
4. Sync service:
   - Gets `last_sync_time` from storage
   - Gets pending local changes
   - Sends sync request to server
   - Receives server changes and conflicts
   - Applies server changes to local database
   - Handles conflicts if any
   - Updates `last_sync_time`

### Conflict Resolution

When conflicts are detected:

1. **Update Conflict**: Both client and server modified the same entry
   - Show both versions to user
   - User chooses which version to keep
   - Chosen version is applied

2. **Delete Conflict**: Client deleted entry that was modified on server
   - Show server's updated version
   - User confirms deletion or keeps server version

## Sync Status

The service tracks the following sync statuses:

- `idle`: No sync has been performed yet
- `syncing`: Sync is currently in progress
- `synced`: Last sync completed successfully
- `failed`: Last sync failed due to error
- `conflicts`: Sync completed but has unresolved conflicts
- `offline`: Device is offline

## Entry Sync Status

Each diary entry has a `sync_status` field:

- `pending`: Entry needs to be synced to server
- `synced`: Entry is synchronized with server
- `failed`: Last sync attempt failed for this entry

## Connectivity Monitoring

The service uses `connectivity_plus` package to monitor network status:

```dart
// Automatically syncs when connectivity is restored
_connectivity.onConnectivityChanged.listen((results) {
  if (hasConnection(results)) {
    syncDiaryEntries();
  }
});
```

## Error Handling

### Network Errors

```dart
try {
  await syncService.syncDiaryEntries();
} catch (e) {
  // Entries are marked as 'failed'
  // Can retry later with retryFailedSync()
}
```

### Conflict Errors

```dart
// Conflicts are returned in sync response
// UI should prompt user for resolution
if (syncResponse.conflicts.isNotEmpty) {
  // Show conflict resolution dialog
  showConflictDialog(syncResponse.conflicts);
}
```

## Best Practices

### 1. Start Background Sync on App Start

```dart
void main() {
  // Initialize services
  final syncService = SyncService(...);
  
  // Start background sync
  syncService.startBackgroundSync();
  
  runApp(MyApp());
}
```

### 2. Stop Background Sync on Logout

```dart
void logout() {
  syncService.stopBackgroundSync();
  // Clear local data
  // Navigate to login
}
```

### 3. Show Sync Status in UI

```dart
// Use SyncStatusWidget
SyncStatusWidget(showDetails: true)

// Or custom implementation
Consumer<SyncProvider>(
  builder: (context, sync, _) {
    return ListTile(
      leading: Icon(
        sync.isSyncing ? Icons.sync : Icons.cloud_done,
        color: Color(sync.getSyncStatusColor()),
      ),
      title: Text(sync.getSyncStatusText()),
      trailing: IconButton(
        icon: Icon(Icons.refresh),
        onPressed: sync.syncNow,
      ),
    );
  },
)
```

### 4. Handle Conflicts Gracefully

```dart
// Show conflict resolution dialog
if (syncProvider.hasConflicts) {
  showDialog(
    context: context,
    builder: (_) => ConflictResolutionDialog(
      conflicts: syncProvider.conflicts,
      onResolve: syncProvider.resolveConflict,
    ),
  );
}
```

### 5. Retry Failed Syncs

```dart
// Show retry button when there are failed entries
if (syncProvider.statistics?.failedCount > 0) {
  ElevatedButton(
    onPressed: syncProvider.retryFailedSync,
    child: Text('Retry Failed (${syncProvider.statistics!.failedCount})'),
  );
}
```

## Testing

### Unit Tests

```dart
test('syncDiaryEntries should sync pending entries', () async {
  // Arrange
  final mockHttpClient = MockHttpClientService();
  final mockLocalDiary = MockLocalDiaryDataSource();
  final syncService = SyncService(
    httpClient: mockHttpClient,
    localDiary: mockLocalDiary,
    storage: mockStorage,
  );

  // Act
  final result = await syncService.syncDiaryEntries();

  // Assert
  expect(result, true);
  verify(mockHttpClient.post('/api/diary/sync', data: any)).called(1);
});
```

### Integration Tests

```dart
testWidgets('sync status widget shows correct status', (tester) async {
  // Arrange
  final syncProvider = SyncProvider(syncService: mockSyncService);

  // Act
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: syncProvider,
      child: MaterialApp(
        home: Scaffold(
          body: SyncStatusWidget(),
        ),
      ),
    ),
  );

  // Assert
  expect(find.text('Status Sinkronisasi'), findsOneWidget);
});
```

## Performance Considerations

### 1. Batch Size

For large datasets, consider batching sync requests:

```dart
const BATCH_SIZE = 100;
final allEntries = await localDiary.getPendingSyncEntries();

for (var i = 0; i < allEntries.length; i += BATCH_SIZE) {
  final batch = allEntries.sublist(
    i,
    min(i + BATCH_SIZE, allEntries.length),
  );
  await syncBatch(batch);
}
```

### 2. Incremental Sync

Only sync data that has changed since last sync:

```dart
final lastSyncTime = await storage.getLastSyncTime();
final modifiedEntries = await localDiary.getEntriesModifiedAfter(
  DateTime.parse(lastSyncTime),
);
```

### 3. Background Sync Interval

Adjust sync interval based on app usage:

```dart
// Frequent sync for active users
syncService.startBackgroundSync(interval: Duration(minutes: 5));

// Less frequent for battery saving
syncService.startBackgroundSync(interval: Duration(hours: 1));
```

## Troubleshooting

### Sync Not Triggering

1. Check connectivity monitoring is started
2. Verify network permissions in AndroidManifest.xml / Info.plist
3. Check if sync is already in progress (`_isSyncing` flag)

### Conflicts Not Resolving

1. Verify conflict resolution request format
2. Check server logs for resolution errors
3. Ensure entry IDs match between client and server

### Failed Entries Accumulating

1. Check network connectivity
2. Verify server endpoint is accessible
3. Review error logs for specific failures
4. Use `retryFailedSync()` to retry

## Requirements Mapping

- **Requirement 3.5**: Sync local database with server when online
- **Requirement 4.1**: Support dual profile (baby/mother) sync
- **Requirement 7.4**: Display favorite recipes from local storage when offline

## Related Files

- `lib/core/services/sync_service.dart` - Core sync logic
- `lib/presentation/providers/sync_provider.dart` - UI state management
- `lib/presentation/widgets/sync_status_widget.dart` - Sync status UI
- `lib/data/models/sync_request.dart` - Sync request models
- `lib/data/models/sync_response.dart` - Sync response models
- `backend/internal/diary/service.go` - Server-side sync implementation
- `backend/internal/diary/SYNC_API.md` - Server API documentation
