import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';
import 'package:noteleaf/views/chapter_editor_view.dart';
import 'package:noteleaf/views/scene_management_view.dart';

class ChaptersTab extends StatefulWidget {
  final String projectId;

  const ChaptersTab({super.key, required this.projectId});

  @override
  State<ChaptersTab> createState() => _ChaptersTabState();
}

class _ChaptersTabState extends State<ChaptersTab> {
  late ChapterViewModel _chapterViewModel;

  @override
  void initState() {
    super.initState();
    _chapterViewModel = ChapterViewModel();
    _chapterViewModel.loadChapters(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chapterViewModel,
      child: Scaffold(
        body: Consumer<ChapterViewModel>(
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
                      onPressed: () => viewModel.loadChapters(widget.projectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.chapters.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No chapters yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first chapter to start writing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.chapters.length,
              onReorder: viewModel.reorderChapters,
              itemBuilder: (context, index) {
                final chapter = viewModel.chapters[index];
                return Card(
                  key: ValueKey(chapter.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(chapter.title),
                    subtitle: Text(
                      'Last modified: ${_formatDate(chapter.lastModified)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'scenes',
                              child: Row(
                                children: [
                                  Icon(Icons.movie),
                                  SizedBox(width: 8),
                                  Text('Manage Scenes'),
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
                            if (value == 'scenes') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SceneManagementView(
                                    chapterId: chapter.id,
                                    chapterTitle: chapter.title,
                                  ),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, chapter.id, chapter.title);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: _chapterViewModel,
                            child: ChapterEditorView(chapter: chapter),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateChapterDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateChapterDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Chapter'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Chapter Title',
            hintText: 'Enter chapter title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _chapterViewModel.createChapter(widget.projectId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String chapterId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _chapterViewModel.deleteChapter(chapterId);
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
}

