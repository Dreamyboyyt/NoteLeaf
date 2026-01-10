import 'package:noteleaf/models/character.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class CharacterViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Character> _characters = [];

  List<Character> get characters => _characters;

  Future<void> loadCharacters(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.characterBox;
      _characters = box.values
          .where((character) => character.projectId == projectId)
          .toList();
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load characters: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Character?> createCharacter(
    String projectId,
    String name,
    String role,
    String backstory,
    String personalityTraits,
  ) async {
    setLoading(true);
    try {
      final characterId = DateTime.now().millisecondsSinceEpoch.toString();
      final character = Character(
        id: characterId,
        projectId: projectId,
        name: name,
        role: role,
        backstory: backstory,
        personalityTraits: personalityTraits,
      );

      final box = await _hiveService.characterBox;
      await box.put(characterId, character);
      _characters.add(character);
      notifyListeners();
      return character;
    } catch (e) {
      setErrorMessage('Failed to create character: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCharacter(Character character) async {
    try {
      final box = await _hiveService.characterBox;
      await box.put(character.id, character);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update character: $e');
    }
  }

  Future<void> deleteCharacter(String characterId) async {
    setLoading(true);
    try {
      final box = await _hiveService.characterBox;
      await box.delete(characterId);
      _characters.removeWhere((c) => c.id == characterId);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete character: $e');
    } finally {
      setLoading(false);
    }
  }
}

