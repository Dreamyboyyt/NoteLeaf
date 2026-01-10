import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/scene.dart';
import 'package:noteleaf/viewmodels/scene_viewmodel.dart';
import 'package:noteleaf/views/scene_editor_view.dart';

class SceneManagementView extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;

  const SceneManagementView({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<SceneManagementView> createState() => _SceneManagementViewState();
}

class _SceneManagementViewState extends State<SceneManagementView> {
  late SceneViewModel _sceneViewModel;

  @override
  void initState() {
    super.initState();
    _sceneViewModel = SceneViewModel();
    _sceneViewModel.loadScenes(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sceneViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scenes - ${widget.chapterTitle}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog,
            ),
          ],
        ),
        body: Consumer<SceneViewModel>(
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
                      onPressed: () => viewModel.loadScenes(widget.chapterId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.scenes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_creation,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No scenes yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Break your chapter into scenes for better organization',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.scenes.length,
              onReorder: (oldIndex, newIndex) {
                viewModel.reorderScenes(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final scene = viewModel.scenes[index];
                return _buildSceneCard(scene, index);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSceneDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSceneCard(Scene scene, int index) {
    final wordCount = scene.content.trim().isEmpty ? 0 : scene.content.trim().split(RegExp(r'\s+')).length;
    
    return Card(
      key: ValueKey(scene.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(
          scene.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scene.summary.isNotEmpty)
              Text(
                scene.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (scene.location.isNotEmpty) ...[
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    scene.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.article, size: 14, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  '$wordCount words',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (scene.characters.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.people, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    '${scene.characters.length}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
            if (scene.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: scene.tags.take(3).map((tag) => Chip(
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 10),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
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
            if (value == 'edit') {
              _editScene(scene);
            } else if (value == 'duplicate') {
              _duplicateScene(scene);
            } else if (value == 'delete') {
              _showDeleteDialog(scene);
            }
          },
        ),
        onTap: () => _editScene(scene),
      ),
    );
  }

  void _editScene(Scene scene) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SceneEditorView(scene: scene),
      ),
    ).then((_) {
      _sceneViewModel.loadScenes(widget.chapterId);
    });
  }

  void _duplicateScene(Scene scene) {
    _sceneViewModel.createScene(
      widget.chapterId,
      '${scene.title} (Copy)',
      scene.content,
      scene.summary,
      scene.location,
    );
  }

  void _showSceneDialog(BuildContext context, {Scene? scene}) {
    final titleController = TextEditingController(text: scene?.title ?? '');
    final summaryController = TextEditingController(text: scene?.summary ?? '');
    final locationController = TextEditingController(text: scene?.location ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scene == null ? 'Create Scene' : 'Edit Scene'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Scene Title',
                  hintText: 'Enter scene title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  hintText: 'Brief description of what happens',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where does this scene take place?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                if (scene == null) {
                  _sceneViewModel.createScene(
                    widget.chapterId,
                    titleController.text.trim(),
                    '',
                    summaryController.text.trim(),
                    locationController.text.trim(),
                  );
                } else {
                  scene.title = titleController.text.trim();
                  scene.summary = summaryController.text.trim();
                  scene.location = locationController.text.trim();
                  _sceneViewModel.updateScene(scene);
                }
                Navigator.pop(context);
              }
            },
            child: Text(scene == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Scene scene) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scene'),
        content: Text('Are you sure you want to delete "${scene.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sceneViewModel.deleteScene(scene.id);
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
        title: const Text('Scene Management Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Break your chapter into individual scenes'),
            SizedBox(height: 8),
            Text('• Drag and drop to reorder scenes'),
            SizedBox(height: 8),
            Text('• Add locations and character information'),
            SizedBox(height: 8),
            Text('• Use tags to categorize scenes'),
            SizedBox(height: 8),
            Text('• Tap a scene to edit its content'),
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

