import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/chapter.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';
import 'package:noteleaf/views/distraction_free_editor_view.dart';
import 'package:noteleaf/views/version_history_view.dart';
import 'package:noteleaf/widgets/readability_stats_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChapterEditorView extends StatefulWidget {
  final Chapter chapter;

  const ChapterEditorView({super.key, required this.chapter});

  @override
  State<ChapterEditorView> createState() => _ChapterEditorViewState();
}

class _ChapterEditorViewState extends State<ChapterEditorView> {
  late TextEditingController _contentController;
  late ChapterViewModel _chapterViewModel;
  bool _isMarkdownMode = false;
  bool _showPreview = false;
  bool _showReadabilityStats = false;
  
  // Live word and character count variables
  int _wordCount = 0;
  int _characterCount = 0;
  int _characterCountNoSpaces = 0;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.chapter.content);
    _chapterViewModel = ChapterViewModel();
    _updateCounts();
    
    // Listen to text changes for live count updates
    _contentController.addListener(_updateCounts);
  }

  void _updateCounts() {
    final text = _contentController.text;
    setState(() {
      _characterCount = text.length;
      _characterCountNoSpaces = text.replaceAll(' ', '').length;
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveChapter() {
    widget.chapter.content = _contentController.text;
    _chapterViewModel.updateChapter(widget.chapter);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chapter saved successfully!')),
    );
  }

  void _openDistractionFreeMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DistractionFreeEditorView(
          chapter: widget.chapter,
          initialContent: _contentController.text,
          onContentChanged: (content) {
            _contentController.text = content;
            widget.chapter.content = content;
            _chapterViewModel.updateChapter(widget.chapter);
          },
        ),
      ),
    );
  }

  void _openVersionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VersionHistoryView(
          entityId: widget.chapter.id,
          entityType: 'chapter',
          onRestoreVersion: (content) {
            setState(() {
              _contentController.text = content;
              widget.chapter.content = content;
              _chapterViewModel.updateChapter(widget.chapter);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chapterViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapter.title),
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
              icon: const Icon(Icons.history),
              onPressed: _openVersionHistory,
              tooltip: 'Version History',
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _openDistractionFreeMode,
              tooltip: 'Distraction-Free Mode',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChapter,
              tooltip: 'Save Chapter',
            ),
          ],
        ),
        body: Column(
          children: [
            // Live word and character count bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCountChip('Words', _wordCount, Icons.article),
                    const SizedBox(width: 8),
                    _buildCountChip('Chars', _characterCount, Icons.text_fields),
                    const SizedBox(width: 8),
                    _buildCountChip('No Space', _characterCountNoSpaces, Icons.space_bar_outlined),
                  ],
                ),
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

  Widget _buildTextEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: 'Start writing your chapter...',
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
            ? 'Start writing your chapter...' 
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

