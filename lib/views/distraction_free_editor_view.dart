import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteleaf/models/chapter.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';
import 'dart:async';

class DistractionFreeEditorView extends StatefulWidget {
  final Chapter chapter;
  final String initialContent;
  final Function(String) onContentChanged;

  const DistractionFreeEditorView({
    super.key,
    required this.chapter,
    required this.initialContent,
    required this.onContentChanged,
  });

  @override
  State<DistractionFreeEditorView> createState() => _DistractionFreeEditorViewState();
}

class _DistractionFreeEditorViewState extends State<DistractionFreeEditorView> {
  late TextEditingController _contentController;
  late ChapterViewModel _chapterViewModel;
  bool _showUI = true;
  Timer? _hideUITimer;
  Timer? _autosaveTimer;
  Timer? _writingSessionTimer;
  
  // Focus mode settings
  String _backgroundSound = 'none';
  int _sessionDuration = 0; // 0 means no timer
  int _remainingTime = 0;
  bool _isSessionActive = false;
  
  // Word count for session
  int _sessionStartWordCount = 0;
  int _currentWordCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
    _chapterViewModel = ChapterViewModel();
    _updateWordCount();
    _sessionStartWordCount = _currentWordCount;
    
    // Auto-hide UI after 3 seconds of inactivity
    _resetHideUITimer();
    
    // Auto-save every 30 seconds
    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveContent();
    });
    
    _contentController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _contentController.text;
    setState(() {
      _currentWordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  void _resetHideUITimer() {
    _hideUITimer?.cancel();
    setState(() {
      _showUI = true;
    });
    _hideUITimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUI = false;
        });
      }
    });
  }

  void _saveContent() {
    widget.chapter.content = _contentController.text;
    _chapterViewModel.updateChapter(widget.chapter);
    widget.onContentChanged(_contentController.text);
  }

  void _startWritingSession() {
    if (_sessionDuration > 0) {
      setState(() {
        _remainingTime = _sessionDuration * 60; // Convert minutes to seconds
        _isSessionActive = true;
        _sessionStartWordCount = _currentWordCount;
      });
      
      _writingSessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime--;
        });
        
        if (_remainingTime <= 0) {
          _endWritingSession();
        }
      });
    }
  }

  void _endWritingSession() {
    _writingSessionTimer?.cancel();
    setState(() {
      _isSessionActive = false;
    });
    
    final wordsWritten = _currentWordCount - _sessionStartWordCount;
    _showSessionSummary(wordsWritten);
  }

  void _showSessionSummary(int wordsWritten) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Writing Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text('Words written: $wordsWritten'),
            Text('Session duration: ${_sessionDuration} minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showFocusModeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Focus Mode Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _backgroundSound,
              decoration: const InputDecoration(labelText: 'Background Sound'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('None')),
                DropdownMenuItem(value: 'rain', child: Text('Rain')),
                DropdownMenuItem(value: 'coffee_shop', child: Text('Coffee Shop')),
                DropdownMenuItem(value: 'forest', child: Text('Forest')),
                DropdownMenuItem(value: 'ocean', child: Text('Ocean Waves')),
              ],
              onChanged: (value) {
                setState(() {
                  _backgroundSound = value ?? 'none';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Session Duration (minutes)',
                hintText: '0 for no timer',
              ),
              keyboardType: TextInputType.number,
              initialValue: _sessionDuration.toString(),
              onChanged: (value) {
                _sessionDuration = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_sessionDuration > 0) {
                _startWritingSession();
              }
            },
            child: const Text('Start Session'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideUITimer?.cancel();
    _autosaveTimer?.cancel();
    _writingSessionTimer?.cancel();
    _saveContent(); // Save before disposing
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetHideUITimer,
        onPanUpdate: (_) => _resetHideUITimer(),
        child: Stack(
          children: [
            // Main editor
            Padding(
              padding: const EdgeInsets.all(32),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Focus on your words...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textAlignVertical: TextAlignVertical.top,
                onTap: _resetHideUITimer,
              ),
            ),
            
            // Top UI bar
            if (_showUI)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        if (_isSessionActive) ...[
                          Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_remainingTime),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Text(
                          'Words: ${_currentWordCount - _sessionStartWordCount}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: _showFocusModeSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Background sound indicator
            if (_backgroundSound != 'none' && _showUI)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _backgroundSound.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

