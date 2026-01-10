import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/scene.dart';
import 'package:noteleaf/viewmodels/scene_viewmodel.dart';
import 'package:noteleaf/widgets/readability_stats_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SceneEditorView extends StatefulWidget {
  final Scene scene;

  const SceneEditorView({super.key, required this.scene});

  @override
  State<SceneEditorView> createState() => _SceneEditorViewState();
}

class _SceneEditorViewState extends State<SceneEditorView> {
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late SceneViewModel _sceneViewModel;
  bool _isMarkdownMode = false;
  bool _showPreview = false;
  bool _showReadabilityStats = false;
  
  // Live word and character count variables
  int _wordCount = 0;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.scene.content);
    _tagController = TextEditingController();
    _sceneViewModel = SceneViewModel();
    _updateCounts();
    
    // Listen to text changes for live count updates
    _contentController.addListener(_updateCounts);
  }

  void _updateCounts() {
    final text = _contentController.text;
    setState(() {
      _characterCount = text.length;
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveScene() {
    widget.scene.content = _contentController.text;
    _sceneViewModel.updateScene(widget.scene);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scene saved successfully!')),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !widget.scene.tags.contains(tag)) {
      setState(() {
        widget.scene.tags.add(tag);
      });
      _sceneViewModel.updateScene(widget.scene);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.scene.tags.remove(tag);
    });
    _sceneViewModel.updateScene(widget.scene);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sceneViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.scene.title),
          actions: [
            IconButton(
              icon: Icon(_isMarkdownMode ? Icons.code : Icons.text_fields),
              onPressed: () {
                setState(() {
                  _isMarkdownMode = !_isMarkdownMode;
                });
              },
              tooltip: _isMarkdownMode ? 'Switch to Text Mode' : 'Switch to Markdown Mode',
            ),
            if (_isMarkdownMode)
              IconButton(
                icon: Icon(_showPreview ? Icons.edit : Icons.preview),
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
                tooltip: _showPreview ? 'Edit Mode' : 'Preview Mode',
              ),
            IconButton(
              icon: Icon(_showReadabilityStats ? Icons.analytics_outlined : Icons.analytics),
              onPressed: () {
                setState(() {
                  _showReadabilityStats = !_showReadabilityStats;
                });
              },
              tooltip: 'Readability Statistics',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveScene,
              tooltip: 'Save Scene',
            ),
          ],
        ),
        body: Column(
          children: [
            // Scene info and stats bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Word and character count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCountChip('Words', _wordCount, Icons.article),
                      _buildCountChip('Characters', _characterCount, Icons.text_fields),
                      if (widget.scene.location.isNotEmpty)
                        _buildInfoChip('Location', widget.scene.location, Icons.location_on),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (widget.scene.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.scene.tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (_showReadabilityStats)
              ReadabilityStatsWidget(text: _contentController.text),
            Expanded(
              child: _isMarkdownMode && _showPreview
                  ? _buildMarkdownPreview()
                  : _buildTextEditor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(String label, int count, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $count'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $value'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: 'Write your scene...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Markdown(
        data: _contentController.text.isEmpty 
            ? 'Write your scene...' 
            : _contentController.text,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 16, height: 1.6),
          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

