import 'diary_entry.dart';

/// Sync Response Model
/// Represents the response from sync operation
/// Requirements: 3.5, 4.1, 7.4 - Sync response with conflicts
class SyncResponse {
  final List<DiaryEntry> entries; // New/updated entries from server
  final List<String> deletedIds; // IDs deleted on server
  final List<SyncConflict> conflicts; // Conflicts that need resolution

  const SyncResponse({
    required this.entries,
    required this.deletedIds,
    required this.conflicts,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedIds: (json['deleted_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      conflicts: (json['conflicts'] as List<dynamic>)
          .map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'deleted_ids': deletedIds,
      'conflicts': conflicts.map((e) => e.toJson()).toList(),
    };
  }
}

/// Sync Conflict Model
/// Represents a conflict between client and server versions
class SyncConflict {
  final String entryId;
  final Map<String, dynamic> clientEntry;
  final DiaryEntry serverEntry;
  final String conflictType; // "update_conflict", "delete_conflict"

  const SyncConflict({
    required this.entryId,
    required this.clientEntry,
    required this.serverEntry,
    required this.conflictType,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      entryId: json['entry_id'] as String,
      clientEntry: json['client_entry'] as Map<String, dynamic>,
      serverEntry: DiaryEntry.fromJson(json['server_entry'] as Map<String, dynamic>),
      conflictType: json['conflict_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'client_entry': clientEntry,
      'server_entry': serverEntry.toJson(),
      'conflict_type': conflictType,
    };
  }

  /// Check if this is an update conflict
  bool get isUpdateConflict => conflictType == 'update_conflict';

  /// Check if this is a delete conflict
  bool get isDeleteConflict => conflictType == 'delete_conflict';
}

/// Conflict Resolution Request Model
class ConflictResolutionRequest {
  final String entryId;
  final String resolution; // "use_client" or "use_server"
  final Map<String, dynamic>? entry; // Required if resolution is "use_client"

  const ConflictResolutionRequest({
    required this.entryId,
    required this.resolution,
    this.entry,
  });

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'resolution': resolution,
      if (entry != null) 'entry': entry,
    };
  }
}
