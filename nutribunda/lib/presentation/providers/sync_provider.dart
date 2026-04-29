import 'package:flutter/foundation.dart';
import '../../core/services/sync_service.dart';
import '../../data/models/sync_response.dart';

/// Sync Provider
/// Manages sync state and provides UI feedback
/// Requirements: 3.5, 4.1, 7.4 - Sync state management with conflict handling
class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;

  SyncStatus _syncStatus = SyncStatus.idle;
  List<SyncConflict> _conflicts = [];
  SyncStatistics? _statistics;
  String? _errorMessage;

  SyncProvider({required SyncService syncService})
      : _syncService = syncService {
    _initializeSyncService();
  }

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  List<SyncConflict> get conflicts => _conflicts;
  SyncStatistics? get statistics => _statistics;
  String? get errorMessage => _errorMessage;
  bool get isSyncing => _syncStatus == SyncStatus.syncing;
  bool get hasConflicts => _conflicts.isNotEmpty;
  bool get isOffline => _syncStatus == SyncStatus.offline;

  /// Initialize sync service with callbacks
  void _initializeSyncService() {
    // Note: This would require modifying SyncService constructor
    // For now, we'll manually check status
    _loadStatistics();
  }

  /// Start background sync
  void startBackgroundSync({Duration? interval}) {
    _syncService.startBackgroundSync(
      interval: interval ?? const Duration(minutes: 15),
    );
    notifyListeners();
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncService.stopBackgroundSync();
    notifyListeners();
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    _syncStatus = SyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _syncService.syncDiaryEntries();
      
      if (success) {
        _syncStatus = SyncStatus.synced;
        _conflicts = [];
      } else {
        // Check if there are conflicts
        await _loadStatistics();
        if (_conflicts.isNotEmpty) {
          _syncStatus = SyncStatus.conflicts;
        } else {
          _syncStatus = SyncStatus.failed;
          _errorMessage = 'Sinkronisasi gagal. Silakan coba lagi.';
        }
      }
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    await _loadStatistics();
    notifyListeners();
  }

  /// Resolve a conflict
  Future<bool> resolveConflict({
    required String entryId,
    required String resolution,
    Map<String, dynamic>? clientEntry,
  }) async {
    try {
      final resolved = await _syncService.resolveConflict(
        entryId: entryId,
        resolution: resolution,
        clientEntry: clientEntry,
      );

      if (resolved != null) {
        // Remove resolved conflict from list
        _conflicts.removeWhere((c) => c.entryId == entryId);
        
        // If no more conflicts, update status
        if (_conflicts.isEmpty) {
          _syncStatus = SyncStatus.synced;
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Gagal menyelesaikan konflik: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Resolve all conflicts with a strategy
  /// strategy: "use_client" or "use_server"
  Future<void> resolveAllConflicts(String strategy) async {
    final conflictsCopy = List<SyncConflict>.from(_conflicts);
    
    for (final conflict in conflictsCopy) {
      await resolveConflict(
        entryId: conflict.entryId,
        resolution: strategy,
        clientEntry: strategy == 'use_client' ? conflict.clientEntry : null,
      );
    }
  }

  /// Retry failed sync entries
  Future<void> retryFailedSync() async {
    _syncStatus = SyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    try {
      await _syncService.retryFailedSync();
      _syncStatus = SyncStatus.synced;
    } catch (e) {
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'Gagal mencoba ulang sinkronisasi: ${e.toString()}';
    }

    await _loadStatistics();
    notifyListeners();
  }

  /// Load sync statistics
  Future<void> _loadStatistics() async {
    try {
      _statistics = await _syncService.getSyncStatistics();
      notifyListeners();
    } catch (e) {
      // Failed to load sync statistics - silently fail
    }
  }

  /// Check connectivity status
  Future<bool> checkConnectivity() async {
    final hasConnection = await _syncService.hasConnectivity();
    if (!hasConnection) {
      _syncStatus = SyncStatus.offline;
      notifyListeners();
    }
    return hasConnection;
  }

  /// Get sync status display text
  String getSyncStatusText() {
    switch (_syncStatus) {
      case SyncStatus.idle:
        return 'Belum disinkronkan';
      case SyncStatus.syncing:
        return 'Menyinkronkan...';
      case SyncStatus.synced:
        if (_statistics?.lastSyncTime != null) {
          final lastSync = _statistics!.lastSyncTime!;
          final now = DateTime.now();
          final difference = now.difference(lastSync);
          
          if (difference.inMinutes < 1) {
            return 'Baru saja disinkronkan';
          } else if (difference.inHours < 1) {
            return 'Disinkronkan ${difference.inMinutes} menit yang lalu';
          } else if (difference.inDays < 1) {
            return 'Disinkronkan ${difference.inHours} jam yang lalu';
          } else {
            return 'Disinkronkan ${difference.inDays} hari yang lalu';
          }
        }
        return 'Tersinkronkan';
      case SyncStatus.failed:
        return 'Sinkronisasi gagal';
      case SyncStatus.conflicts:
        return 'Ada ${_conflicts.length} konflik';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  /// Get sync status color
  /// Returns color code for UI display
  int getSyncStatusColor() {
    switch (_syncStatus) {
      case SyncStatus.idle:
        return 0xFF9E9E9E; // Grey
      case SyncStatus.syncing:
        return 0xFF2196F3; // Blue
      case SyncStatus.synced:
        return 0xFF4CAF50; // Green
      case SyncStatus.failed:
        return 0xFFF44336; // Red
      case SyncStatus.conflicts:
        return 0xFFFF9800; // Orange
      case SyncStatus.offline:
        return 0xFF757575; // Dark Grey
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
