import 'package:noteleaf/models/note.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class NoteViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.noteBox;
      _notes = box.values
          .where((note) => note.projectId == projectId)
          .toList();
      _notes.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load notes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Note?> createNote(
    String projectId,
    String title,
    String content,
  ) async {
    setLoading(true);
    try {
      final noteId = DateTime.now().millisecondsSinceEpoch.toString();
      final note = Note(
        id: noteId,
        projectId: projectId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      final box = await _hiveService.noteBox;
      await box.put(noteId, note);
      _notes.insert(0, note);
      notifyListeners();
      return note;
    } catch (e) {
      setErrorMessage('Failed to create note: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      note.lastModified = DateTime.now();
      final box = await _hiveService.noteBox;
      await box.put(note.id, note);
      
      // Move to top of list
      _notes.removeWhere((n) => n.id == note.id);
      _notes.insert(0, note);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    setLoading(true);
    try {
      final box = await _hiveService.noteBox;
      await box.delete(noteId);
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete note: $e');
    } finally {
      setLoading(false);
    }
  }
}

