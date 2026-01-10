import 'package:noteleaf/models/scene.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class SceneViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Scene> _scenes = [];

  List<Scene> get scenes => _scenes;

  Future<void> loadScenes(String chapterId) async {
    setLoading(true);
    try {
      final box = await _hiveService.sceneBox;
      _scenes = box.values
          .where((scene) => scene.chapterId == chapterId)
          .toList();
      _scenes.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load scenes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Scene?> createScene(
    String chapterId,
    String title,
    String content,
    String summary,
    String location,
  ) async {
    setLoading(true);
    try {
      final sceneId = DateTime.now().millisecondsSinceEpoch.toString();
      final order = _scenes.length;
      
      final scene = Scene(
        id: sceneId,
        chapterId: chapterId,
        title: title,
        content: content,
        order: order,
        summary: summary,
        tags: [],
        location: location,
        characters: [],
      );

      final box = await _hiveService.sceneBox;
      await box.put(sceneId, scene);
      _scenes.add(scene);
      _scenes.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return scene;
    } catch (e) {
      setErrorMessage('Failed to create scene: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateScene(Scene scene) async {
    try {
      final box = await _hiveService.sceneBox;
      await box.put(scene.id, scene);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update scene: $e');
    }
  }

  Future<void> deleteScene(String sceneId) async {
    setLoading(true);
    try {
      final box = await _hiveService.sceneBox;
      await box.delete(sceneId);
      _scenes.removeWhere((s) => s.id == sceneId);
      
      // Reorder remaining scenes
      for (int i = 0; i < _scenes.length; i++) {
        _scenes[i].order = i;
        await box.put(_scenes[i].id, _scenes[i]);
      }
      
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete scene: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> reorderScenes(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final scene = _scenes.removeAt(oldIndex);
      _scenes.insert(newIndex, scene);
      
      // Update order for all scenes
      final box = await _hiveService.sceneBox;
      for (int i = 0; i < _scenes.length; i++) {
        _scenes[i].order = i;
        await box.put(_scenes[i].id, _scenes[i]);
      }
      
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to reorder scenes: $e');
    }
  }

  Future<void> addTagToScene(String sceneId, String tag) async {
    try {
      final scene = _scenes.firstWhere((s) => s.id == sceneId);
      if (!scene.tags.contains(tag)) {
        scene.tags.add(tag);
        await updateScene(scene);
      }
    } catch (e) {
      setErrorMessage('Failed to add tag: $e');
    }
  }

  Future<void> removeTagFromScene(String sceneId, String tag) async {
    try {
      final scene = _scenes.firstWhere((s) => s.id == sceneId);
      scene.tags.remove(tag);
      await updateScene(scene);
    } catch (e) {
      setErrorMessage('Failed to remove tag: $e');
    }
  }

  Future<void> addCharacterToScene(String sceneId, String characterId) async {
    try {
      final scene = _scenes.firstWhere((s) => s.id == sceneId);
      if (!scene.characters.contains(characterId)) {
        scene.characters.add(characterId);
        await updateScene(scene);
      }
    } catch (e) {
      setErrorMessage('Failed to add character: $e');
    }
  }

  Future<void> removeCharacterFromScene(String sceneId, String characterId) async {
    try {
      final scene = _scenes.firstWhere((s) => s.id == sceneId);
      scene.characters.remove(characterId);
      await updateScene(scene);
    } catch (e) {
      setErrorMessage('Failed to remove character: $e');
    }
  }
}

