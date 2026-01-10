import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/plot.dart';
import 'package:noteleaf/viewmodels/plot_viewmodel.dart';

class PlotTab extends StatefulWidget {
  final String projectId;

  const PlotTab({super.key, required this.projectId});

  @override
  State<PlotTab> createState() => _PlotTabState();
}

class _PlotTabState extends State<PlotTab> {
  late PlotViewModel _plotViewModel;

  @override
  void initState() {
    super.initState();
    _plotViewModel = PlotViewModel();
    _plotViewModel.loadPlots(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _plotViewModel,
      child: Scaffold(
        body: Consumer<PlotViewModel>(
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
                      onPressed: () => viewModel.loadPlots(widget.projectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.plots.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No plot points yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create plot points to track your story\'s timeline and arcs',
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

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.plots.length,
              itemBuilder: (context, index) {
                final plot = viewModel.plots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.timeline),
                    ),
                    title: Text(plot.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plot.description.length > 50
                              ? '${plot.description.substring(0, 50)}...'
                              : plot.description,
                        ),
                        if (plot.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              spacing: 4,
                              children: plot.tags
                                  .split(',')
                                  .map((tag) => Chip(
                                        label: Text(
                                          tag.trim(),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ))
                                  .toList(),
                            ),
                          ),
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
                          _showPlotDialog(context, plot: plot);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, plot.id, plot.title);
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(plot.description),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showPlotDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showPlotDialog(BuildContext context, {Plot? plot}) {
    final titleController = TextEditingController(text: plot?.title ?? '');
    final descriptionController = TextEditingController(text: plot?.description ?? '');
    final tagsController = TextEditingController(text: plot?.tags ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plot == null ? 'Create Plot Point' : 'Edit Plot Point'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Plot point title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what happens in this plot point',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Comma-separated tags (e.g., climax, turning point)',
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
                if (plot == null) {
                  _plotViewModel.createPlot(
                    widget.projectId,
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                    tagsController.text.trim(),
                  );
                } else {
                  plot.title = titleController.text.trim();
                  plot.description = descriptionController.text.trim();
                  plot.tags = tagsController.text.trim();
                  _plotViewModel.updatePlot(plot);
                }
                Navigator.pop(context);
              }
            },
            child: Text(plot == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String plotId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plot Point'),
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _plotViewModel.deletePlot(plotId);
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

