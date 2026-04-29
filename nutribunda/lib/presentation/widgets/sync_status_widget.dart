import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../../core/services/sync_service.dart';

/// Sync Status Widget
/// Displays sync status and provides manual sync trigger
/// Requirements: 3.5, 4.1, 7.4 - Sync status indicator for user feedback
class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;

  const SyncStatusWidget({
    Key? key,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildStatusIcon(syncProvider.syncStatus),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Sinkronisasi',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            syncProvider.getSyncStatusText(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Color(syncProvider.getSyncStatusColor()),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!syncProvider.isSyncing)
                      IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: () => syncProvider.syncNow(),
                        tooltip: 'Sinkronkan sekarang',
                      ),
                  ],
                ),
                if (showDetails && syncProvider.statistics != null) ...[
                  const Divider(height: 24),
                  _buildStatistics(context, syncProvider),
                ],
                if (syncProvider.hasConflicts) ...[
                  const Divider(height: 24),
                  _buildConflictsSection(context, syncProvider),
                ],
                if (syncProvider.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    syncProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case SyncStatus.idle:
        icon = Icons.cloud_off;
        color = Colors.grey;
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case SyncStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case SyncStatus.conflicts:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 32);
  }

  Widget _buildStatistics(BuildContext context, SyncProvider syncProvider) {
    final stats = syncProvider.statistics!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              'Pending',
              stats.pendingCount.toString(),
              Colors.orange,
            ),
            _buildStatItem(
              context,
              'Gagal',
              stats.failedCount.toString(),
              Colors.red,
            ),
          ],
        ),
        if (stats.failedCount > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => syncProvider.retryFailedSync(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Ulang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildConflictsSection(BuildContext context, SyncProvider syncProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konflik Sinkronisasi',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Ada ${syncProvider.conflicts.length} entri yang berkonflik. '
          'Pilih versi yang ingin digunakan:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showConflictResolutionDialog(
                context,
                syncProvider,
              ),
              child: const Text('Lihat Konflik'),
            ),
            OutlinedButton(
              onPressed: () => _showBulkResolutionDialog(
                context,
                syncProvider,
              ),
              child: const Text('Selesaikan Semua'),
            ),
          ],
        ),
      ],
    );
  }

  void _showConflictResolutionDialog(
    BuildContext context,
    SyncProvider syncProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConflictResolutionDialog(
        conflicts: syncProvider.conflicts,
        onResolve: (entryId, resolution, clientEntry) {
          syncProvider.resolveConflict(
            entryId: entryId,
            resolution: resolution,
            clientEntry: clientEntry,
          );
        },
      ),
    );
  }

  void _showBulkResolutionDialog(
    BuildContext context,
    SyncProvider syncProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Semua Konflik'),
        content: const Text(
          'Pilih strategi untuk menyelesaikan semua konflik:',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              syncProvider.resolveAllConflicts('use_server');
            },
            child: const Text('Gunakan Versi Server'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              syncProvider.resolveAllConflicts('use_client');
            },
            child: const Text('Gunakan Versi Lokal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}

/// Conflict Resolution Dialog
/// Shows detailed conflict information and resolution options
class ConflictResolutionDialog extends StatefulWidget {
  final List<dynamic> conflicts;
  final Function(String, String, Map<String, dynamic>?) onResolve;

  const ConflictResolutionDialog({
    Key? key,
    required this.conflicts,
    required this.onResolve,
  }) : super(key: key);

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.conflicts.isEmpty) {
      return AlertDialog(
        title: const Text('Tidak Ada Konflik'),
        content: const Text('Semua konflik telah diselesaikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      );
    }

    final conflict = widget.conflicts[_currentIndex];

    return AlertDialog(
      title: Text('Konflik ${_currentIndex + 1} dari ${widget.conflicts.length}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tipe: ${conflict.conflictType}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Versi Lokal:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(conflict.clientEntry.toString()),
            const SizedBox(height: 16),
            const Text(
              'Versi Server:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(conflict.serverEntry.toString()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onResolve(
              conflict.entryId,
              'use_client',
              conflict.clientEntry,
            );
            _moveToNext();
          },
          child: const Text('Gunakan Lokal'),
        ),
        TextButton(
          onPressed: () {
            widget.onResolve(
              conflict.entryId,
              'use_server',
              null,
            );
            _moveToNext();
          },
          child: const Text('Gunakan Server'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  void _moveToNext() {
    if (_currentIndex < widget.conflicts.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }
}
