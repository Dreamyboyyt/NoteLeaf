import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/project.dart';
import 'package:noteleaf/services/export_service.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';

class ExportDialog extends StatefulWidget {
  final Project project;

  const ExportDialog({super.key, required this.project});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String _selectedFormat = 'txt';
  bool _exportAll = true;
  final Set<String> _selectedChapters = {};
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Project'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'txt', child: Text('Text (.txt)')),
                DropdownMenuItem(value: 'md', child: Text('Markdown (.md)')),
                DropdownMenuItem(value: 'csv', child: Text('CSV (.csv)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFormat = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Chapters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Export all chapters'),
              value: _exportAll,
              onChanged: (value) {
                setState(() {
                  _exportAll = value;
                  if (value) {
                    _selectedChapters.clear();
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (!_exportAll) ...[
              const SizedBox(height: 8),
              Text(
                'Select chapters to export:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: Consumer<ChapterViewModel>(
                  builder: (context, viewModel, child) {
                    return ListView.builder(
                      itemCount: viewModel.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = viewModel.chapters[index];
                        return CheckboxListTile(
                          title: Text(chapter.title),
                          value: _selectedChapters.contains(chapter.id),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChapters.add(chapter.id);
                              } else {
                                _selectedChapters.remove(chapter.id);
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportProject,
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _exportProject() async {
    if (!_exportAll && _selectedChapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one chapter to export'),
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await ExportService.exportProject(
        widget.project,
        _selectedFormat,
        selectedChapterIds: _exportAll ? null : _selectedChapters.toList(),
      );

      if (filePath != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project exported successfully to $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export project'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

