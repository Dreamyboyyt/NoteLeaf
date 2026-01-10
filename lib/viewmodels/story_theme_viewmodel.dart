import 'package:noteleaf/models/theme.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class StoryThemeViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Theme> _themes = [];

  List<Theme> get themes => _themes;

  Future<void> loadThemes(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.themeBox;
      _themes = box.values
          .where((theme) => theme.projectId == projectId)
          .toList();
      _themes.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load themes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Theme?> createTheme(
    String projectId,
    String title,
    String description,
  ) async {
    setLoading(true);
    try {
      final themeId = DateTime.now().millisecondsSinceEpoch.toString();
      final theme = Theme(
        id: themeId,
        projectId: projectId,
        title: title,
        description: description,
      );

      final box = await _hiveService.themeBox;
      await box.put(themeId, theme);
      _themes.add(theme);
      _themes.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
      return theme;
    } catch (e) {
      setErrorMessage('Failed to create theme: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateTheme(Theme theme) async {
    try {
      final box = await _hiveService.themeBox;
      await box.put(theme.id, theme);
      _themes.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update theme: $e');
    }
  }

  Future<void> deleteTheme(String themeId) async {
    setLoading(true);
    try {
      final box = await _hiveService.themeBox;
      await box.delete(themeId);
      _themes.removeWhere((t) => t.id == themeId);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete theme: $e');
    } finally {
      setLoading(false);
    }
  }
}

