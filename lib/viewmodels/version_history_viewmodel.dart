import 'package:noteleaf/models/version_snapshot.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class VersionHistoryViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<VersionSnapshot> _snapshots = [];

  List<VersionSnapshot> get snapshots => _snapshots;

  Future<void> loadSnapshots(String entityId, String entityType) async {
    setLoading(true);
    try {
      final box = await _hiveService.versionSnapshotBox;
      _snapshots = box.values
          .where((snapshot) => 
              snapshot.entityId == entityId && 
              snapshot.entityType == entityType)
          .toList();
      _snapshots.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load version history: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<VersionSnapshot?> createSnapshot(
    String entityId,
    String entityType,
    String content,
    String description,
  ) async {
    try {
      final snapshotId = DateTime.now().millisecondsSinceEpoch.toString();
      final wordCount = content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
      
      final snapshot = VersionSnapshot(
        id: snapshotId,
        entityId: entityId,
        entityType: entityType,
        content: content,
        timestamp: DateTime.now(),
        description: description,
        wordCount: wordCount,
      );

      final box = await _hiveService.versionSnapshotBox;
      await box.put(snapshotId, snapshot);
      _snapshots.insert(0, snapshot);
      
      // Keep only the last 50 snapshots per entity to avoid storage bloat
      await _cleanupOldSnapshots(entityId, entityType);
      
      notifyListeners();
      return snapshot;
    } catch (e) {
      setErrorMessage('Failed to create snapshot: $e');
      return null;
    }
  }

  Future<void> deleteSnapshot(String snapshotId) async {
    try {
      final box = await _hiveService.versionSnapshotBox;
      await box.delete(snapshotId);
      _snapshots.removeWhere((s) => s.id == snapshotId);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete snapshot: $e');
    }
  }

  Future<void> _cleanupOldSnapshots(String entityId, String entityType) async {
    try {
      final entitySnapshots = _snapshots
          .where((s) => s.entityId == entityId && s.entityType == entityType)
          .toList();
      
      if (entitySnapshots.length > 50) {
        final box = await _hiveService.versionSnapshotBox;
        final snapshotsToDelete = entitySnapshots.skip(50).toList();
        
        for (final snapshot in snapshotsToDelete) {
          await box.delete(snapshot.id);
          _snapshots.removeWhere((s) => s.id == snapshot.id);
        }
      }
    } catch (e) {
      // Silent cleanup failure
    }
  }

  Future<void> createAutoSnapshot(
    String entityId,
    String entityType,
    String content,
  ) async {
    final now = DateTime.now();
    final description = 'Auto-save ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    await createSnapshot(entityId, entityType, content, description);
  }
}

