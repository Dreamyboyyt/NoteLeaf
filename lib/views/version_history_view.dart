import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/version_snapshot.dart';
import 'package:noteleaf/viewmodels/version_history_viewmodel.dart';
import 'package:intl/intl.dart';

class VersionHistoryView extends StatefulWidget {
  final String entityId;
  final String entityType;
  final Function(String) onRestoreVersion;

  const VersionHistoryView({
    super.key,
    required this.entityId,
    required this.entityType,
    required this.onRestoreVersion,
  });

  @override
  State<VersionHistoryView> createState() => _VersionHistoryViewState();
}

class _VersionHistoryViewState extends State<VersionHistoryView> {
  late VersionHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VersionHistoryViewModel();
    _viewModel.loadSnapshots(widget.entityId, widget.entityType);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Version History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog,
            ),
          ],
        ),
        body: Consumer<VersionHistoryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadSnapshots(widget.entityId, widget.entityType),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.snapshots.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No version history yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Versions will be saved automatically as you write',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.snapshots.length,
              itemBuilder: (context, index) {
                final snapshot = viewModel.snapshots[index];
                return _buildSnapshotCard(snapshot, index == 0);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSnapshotCard(VersionSnapshot snapshot, bool isLatest) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLatest ? Icons.star : Icons.history,
                  color: isLatest ? Colors.amber : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    snapshot.description,
                    style: TextStyle(
                      fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.restore),
                          SizedBox(width: 8),
                          Text('Restore'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'preview',
                      child: Row(
                        children: [
                          Icon(Icons.preview),
                          SizedBox(width: 8),
                          Text('Preview'),
                        ],
                      ),
                    ),
                    if (!isLatest)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'restore') {
                      _showRestoreDialog(snapshot);
                    } else if (value == 'preview') {
                      _showPreviewDialog(snapshot);
                    } else if (value == 'delete') {
                      _showDeleteDialog(snapshot);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(snapshot.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.article, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${snapshot.wordCount} words',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              snapshot.content.length > 100
                  ? '${snapshot.content.substring(0, 100)}...'
                  : snapshot.content,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreDialog(VersionSnapshot snapshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Version'),
        content: Text(
          'Are you sure you want to restore to "${snapshot.description}"? '
          'This will replace the current content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onRestoreVersion(snapshot.content);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Version restored successfully!')),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(VersionSnapshot snapshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(snapshot.description),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(snapshot.content),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRestoreDialog(snapshot);
            },
            child: const Text('Restore This Version'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(VersionSnapshot snapshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Version'),
        content: Text('Are you sure you want to delete "${snapshot.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.deleteSnapshot(snapshot.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version History Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Versions are automatically saved as you write'),
            SizedBox(height: 8),
            Text('• Click "Preview" to see the full content of a version'),
            SizedBox(height: 8),
            Text('• Click "Restore" to revert to a previous version'),
            SizedBox(height: 8),
            Text('• The latest version is marked with a star'),
            SizedBox(height: 8),
            Text('• Up to 50 versions are kept per chapter/note'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

