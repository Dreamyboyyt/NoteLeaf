import 'package:noteleaf/models/world_element.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class WorldBuildingViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<WorldElement> _worldElements = [];
  String _selectedType = 'all';

  List<WorldElement> get worldElements => _selectedType == 'all' 
      ? _worldElements 
      : _worldElements.where((e) => e.type == _selectedType).toList();

  String get selectedType => _selectedType;

  List<String> get availableTypes => [
    'all',
    'location',
    'lore',
    'magic_system',
    'timeline',
    'culture',
    'language',
    'religion',
    'organization',
    'technology',
  ];

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> loadWorldElements(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.worldElementBox;
      _worldElements = box.values
          .where((element) => element.projectId == projectId)
          .toList();
      _worldElements.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load world elements: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<WorldElement?> createElement(
    String projectId,
    String name,
    String type,
    String description,
    Map<String, String> customFields,
    List<String> tags,
  ) async {
    try {
      final elementId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      
      final element = WorldElement(
        id: elementId,
        projectId: projectId,
        name: name,
        type: type,
        description: description,
        customFields: customFields,
        tags: tags,
        relatedElements: [],
        createdAt: now,
        lastModified: now,
      );

      final box = await _hiveService.worldElementBox;
      await box.put(elementId, element);
      _worldElements.add(element);
      _worldElements.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return element;
    } catch (e) {
      setErrorMessage('Failed to create world element: $e');
      return null;
    }
  }

  Future<void> updateElement(WorldElement element) async {
    try {
      element.lastModified = DateTime.now();
      final box = await _hiveService.worldElementBox;
      await box.put(element.id, element);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update world element: $e');
    }
  }

  Future<void> deleteElement(String elementId) async {
    try {
      final box = await _hiveService.worldElementBox;
      await box.delete(elementId);
      _worldElements.removeWhere((e) => e.id == elementId);
      
      // Remove references from other elements
      for (final element in _worldElements) {
        if (element.relatedElements.contains(elementId)) {
          element.relatedElements.remove(elementId);
          await box.put(element.id, element);
        }
      }
      
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete world element: $e');
    }
  }

  Future<void> addRelatedElement(String elementId, String relatedElementId) async {
    try {
      final element = _worldElements.firstWhere((e) => e.id == elementId);
      if (!element.relatedElements.contains(relatedElementId)) {
        element.relatedElements.add(relatedElementId);
        await updateElement(element);
        
        // Add bidirectional relationship
        final relatedElement = _worldElements.firstWhere((e) => e.id == relatedElementId);
        if (!relatedElement.relatedElements.contains(elementId)) {
          relatedElement.relatedElements.add(elementId);
          await updateElement(relatedElement);
        }
      }
    } catch (e) {
      setErrorMessage('Failed to add relationship: $e');
    }
  }

  Future<void> removeRelatedElement(String elementId, String relatedElementId) async {
    try {
      final element = _worldElements.firstWhere((e) => e.id == elementId);
      element.relatedElements.remove(relatedElementId);
      await updateElement(element);
      
      // Remove bidirectional relationship
      final relatedElement = _worldElements.firstWhere((e) => e.id == relatedElementId);
      relatedElement.relatedElements.remove(elementId);
      await updateElement(relatedElement);
    } catch (e) {
      setErrorMessage('Failed to remove relationship: $e');
    }
  }

  List<WorldElement> getRelatedElements(String elementId) {
    final element = _worldElements.firstWhere((e) => e.id == elementId);
    return _worldElements
        .where((e) => element.relatedElements.contains(e.id))
        .toList();
  }

  List<WorldElement> searchElements(String query) {
    if (query.isEmpty) return worldElements;
    
    final lowercaseQuery = query.toLowerCase();
    return worldElements.where((element) =>
        element.name.toLowerCase().contains(lowercaseQuery) ||
        element.description.toLowerCase().contains(lowercaseQuery) ||
        element.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Map<String, String> getDefaultFieldsForType(String type) {
    switch (type) {
      case 'location':
        return {
          'climate': '',
          'population': '',
          'government': '',
          'notable_features': '',
        };
      case 'magic_system':
        return {
          'source': '',
          'limitations': '',
          'cost': '',
          'practitioners': '',
        };
      case 'timeline':
        return {
          'start_date': '',
          'end_date': '',
          'key_events': '',
          'significance': '',
        };
      case 'culture':
        return {
          'values': '',
          'traditions': '',
          'social_structure': '',
          'beliefs': '',
        };
      case 'language':
        return {
          'speakers': '',
          'writing_system': '',
          'grammar_notes': '',
          'sample_phrases': '',
        };
      case 'religion':
        return {
          'deities': '',
          'beliefs': '',
          'practices': '',
          'followers': '',
        };
      case 'organization':
        return {
          'purpose': '',
          'structure': '',
          'members': '',
          'influence': '',
        };
      case 'technology':
        return {
          'function': '',
          'availability': '',
          'requirements': '',
          'impact': '',
        };
      default:
        return {};
    }
  }
}

