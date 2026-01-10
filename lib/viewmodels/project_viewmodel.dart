import 'package:noteleaf/models/project.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ProjectViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    setLoading(true);
    try {
      final box = await _hiveService.projectBox;
      _projects = box.values.toList();
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load projects: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Project?> createProject(String title) async {
    setLoading(true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/projects');
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      final projectId = DateTime.now().millisecondsSinceEpoch.toString();
      final projectPath = '${projectsDir.path}/$projectId';
      final projectDir = Directory(projectPath);
      await projectDir.create();

      // Create subfolders
      await Directory('$projectPath/Chapters').create();
      await Directory('$projectPath/Characters').create();
      await Directory('$projectPath/Plot').create();
      await Directory('$projectPath/Themes').create();
      await Directory('$projectPath/Notes').create();
      await Directory('$projectPath/Assets').create();

      final project = Project(
        id: projectId,
        title: title,
        path: projectPath,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
      );

      final box = await _hiveService.projectBox;
      await box.put(projectId, project);
      _projects.add(project);
      notifyListeners();
      return project;
    } catch (e) {
      setErrorMessage('Failed to create project: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteProject(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.projectBox;
      final project = box.get(projectId);
      if (project != null) {
        // Delete project directory
        final projectDir = Directory(project.path);
        if (await projectDir.exists()) {
          await projectDir.delete(recursive: true);
        }
        
        // Remove from Hive
        await box.delete(projectId);
        _projects.removeWhere((p) => p.id == projectId);
        notifyListeners();
      }
    } catch (e) {
      setErrorMessage('Failed to delete project: $e');
    } finally {
      setLoading(false);
    }
  }
}

