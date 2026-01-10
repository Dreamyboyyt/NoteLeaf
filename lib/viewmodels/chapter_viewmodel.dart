import 'package:noteleaf/models/chapter.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class ChapterViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Chapter> _chapters = [];
  bool _markdownEnabled = false;

  List<Chapter> get chapters => _chapters;
  bool get markdownEnabled => _markdownEnabled;

  void toggleMarkdown() {
    _markdownEnabled = !_markdownEnabled;
    notifyListeners();
  }

  Future<void> loadChapters(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.chapterBox;
      _chapters = box.values
          .where((chapter) => chapter.projectId == projectId)
          .toList();
      _chapters.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load chapters: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Chapter?> createChapter(String projectId, String title) async {
    setLoading(true);
    try {
      final chapterId = DateTime.now().millisecondsSinceEpoch.toString();
      final chapter = Chapter(
        id: chapterId,
        projectId: projectId,
        title: title,
        content: '',
        order: _chapters.length,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      final box = await _hiveService.chapterBox;
      await box.put(chapterId, chapter);
      _chapters.add(chapter);
      notifyListeners();
      return chapter;
    } catch (e) {
      setErrorMessage('Failed to create chapter: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateChapter(Chapter chapter) async {
    try {
      chapter.lastModified = DateTime.now();
      final box = await _hiveService.chapterBox;
      await box.put(chapter.id, chapter);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update chapter: $e');
    }
  }

  Future<void> deleteChapter(String chapterId) async {
    setLoading(true);
    try {
      final box = await _hiveService.chapterBox;
      await box.delete(chapterId);
      _chapters.removeWhere((c) => c.id == chapterId);
      
      // Reorder remaining chapters
      for (int i = 0; i < _chapters.length; i++) {
        _chapters[i].order = i;
        await box.put(_chapters[i].id, _chapters[i]);
      }
      
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete chapter: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> reorderChapters(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final chapter = _chapters.removeAt(oldIndex);
    _chapters.insert(newIndex, chapter);
    
    // Update order for all chapters
    for (int i = 0; i < _chapters.length; i++) {
      _chapters[i].order = i;
    }
    
    try {
      final box = await _hiveService.chapterBox;
      for (final chapter in _chapters) {
        await box.put(chapter.id, chapter);
      }
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to reorder chapters: $e');
    }
  }
}

