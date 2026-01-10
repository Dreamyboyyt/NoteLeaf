import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/theme.dart' as app_theme;
import 'package:noteleaf/viewmodels/story_theme_viewmodel.dart';

class ThemesTab extends StatefulWidget {
  final String projectId;

  const ThemesTab({super.key, required this.projectId});

  @override
  State<ThemesTab> createState() => _ThemesTabState();
}

class _ThemesTabState extends State<ThemesTab> {
  late StoryThemeViewModel _themeViewModel;

  @override
  void initState() {
    super.initState();
    _themeViewModel = StoryThemeViewModel();
    _themeViewModel.loadThemes(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _themeViewModel,
      child: Scaffold(
        body: Consumer<StoryThemeViewModel>(
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
                      onPressed: () => viewModel.loadThemes(widget.projectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.themes.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No themes yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Define the major and minor themes of your story',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.themes.length,
              itemBuilder: (context, index) {
                final theme = viewModel.themes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.palette),
                    ),
                    title: Text(theme.title),
                    subtitle: Text(
                      theme.description.length > 50
                          ? '${theme.description.substring(0, 50)}...'
                          : theme.description,
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
                          _showThemeDialog(context, theme: theme);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, theme.id, theme.title);
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(theme.description),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showThemeDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, {app_theme.Theme? theme}) {
    final titleController = TextEditingController(text: theme?.title ?? '');
    final descriptionController = TextEditingController(text: theme?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(theme == null ? 'Create Theme' : 'Edit Theme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Theme Title',
                  hintText: 'Love, Redemption, Coming of Age, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe how this theme manifests in your story',
                ),
                maxLines: 4,
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
                if (theme == null) {
                  _themeViewModel.createTheme(
                    widget.projectId,
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                  );
                } else {
                  theme.title = titleController.text.trim();
                  theme.description = descriptionController.text.trim();
                  _themeViewModel.updateTheme(theme);
                }
                Navigator.pop(context);
              }
            },
            child: Text(theme == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String themeId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Theme'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _themeViewModel.deleteTheme(themeId);
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

