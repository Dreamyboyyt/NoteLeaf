import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noteleaf/viewmodels/project_viewmodel.dart';
import 'package:noteleaf/viewmodels/theme_viewmodel.dart';
import 'package:noteleaf/views/project_workspace_view.dart';
import 'package:noteleaf/views/settings_view.dart';
import 'package:noteleaf/views/stats_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late ProjectViewModel _projectViewModel;
  bool _showQuote = true;

  final List<String> _inspirationalQuotes = [
    "The first draft of anything is shit. - Ernest Hemingway",
    "You can't wait for inspiration. You have to go after it with a club. - Jack London",
    "There is nothing to writing. All you do is sit down at a typewriter and bleed. - Ernest Hemingway",
    "The scariest moment is always just before you start. - Stephen King",
    "A word after a word after a word is power. - Margaret Atwood",
    "Write what should not be forgotten. - Isabel Allende",
    "The secret to getting ahead is getting started. - Mark Twain",
    "You must stay drunk on writing so reality cannot destroy you. - Ray Bradbury",
  ];

  @override
  void initState() {
    super.initState();
    _projectViewModel = ProjectViewModel();
    _projectViewModel.loadProjects();
    _loadQuotePreference();
  }

  Future<void> _loadQuotePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final showQuote = prefs.getBool('show_inspirational_quotes') ?? true;
    setState(() {
      _showQuote = showQuote;
    });
    
    // Show inspirational quote on startup if enabled
    if (_showQuote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInspirationalQuote();
      });
    }
  }

  void _showInspirationalQuote() {
    final quote = (_inspirationalQuotes..shuffle()).first;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Inspiration'),
        content: Text(
          quote,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('show_inspirational_quotes', false);
              setState(() {
                _showQuote = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Don\'t show again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start Writing!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NoteLeaf'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsView(),
                  ),
                );
              },
            ),
            Consumer<ThemeViewModel>(
              builder: (context, themeViewModel, child) {
                return FloatingActionButton.small(
                  onPressed: themeViewModel.toggleTheme,
                  child: Icon(
                    themeViewModel.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Consumer<ProjectViewModel>(
          builder: (context, projectViewModel, child) {
            if (projectViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (projectViewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      projectViewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => projectViewModel.loadProjects(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (projectViewModel.projects.isEmpty) {
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
                      'Welcome to NoteLeaf',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your creative sanctuary for novel writing',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Create your first project to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: projectViewModel.projects.length,
              itemBuilder: (context, index) {
                final project = projectViewModel.projects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.book),
                    ),
                    title: Text(project.title),
                    subtitle: Text(
                      'Last modified: ${_formatDate(project.lastModified)}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'stats',
                          child: Row(
                            children: [
                              Icon(Icons.analytics),
                              SizedBox(width: 8),
                              Text('Statistics'),
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
                        if (value == 'stats') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatsView(
                                projectId: project.id,
                                projectTitle: project.title,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, project.id, project.title);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectWorkspaceView(
                            projectId: project.id,
                            projectTitle: project.title,
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateProjectDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Project'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateProjectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Project Title',
            hintText: 'Enter your novel title',
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
                _projectViewModel.createProject(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String projectId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _projectViewModel.deleteProject(projectId);
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

