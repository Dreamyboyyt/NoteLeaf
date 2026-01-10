import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteleaf/models/chapter.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
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
  bool _showSettingsBar = true;
  Timer? _hideUITimer;
  Timer? _autosaveTimer;
  Timer? _writingSessionTimer;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedMusicPath;
  String? _selectedMusicName;
  bool _isMusicPlaying = false;
  
  // Focus mode settings
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

  Future<void> _pickMusic() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedMusicPath = result.files.single.path;
          _selectedMusicName = result.files.single.name;
        });
        
        // Auto-play the selected music
        await _audioPlayer.play(DeviceFileSource(_selectedMusicPath!));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        setState(() {
          _isMusicPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking music: $e')),
        );
      }
    }
  }

  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isMusicPlaying = false;
      });
    } else if (_selectedMusicPath != null) {
      await _audioPlayer.resume();
      setState(() {
        _isMusicPlaying = true;
      });
    }
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
    setState(() {
      _isMusicPlaying = false;
      _selectedMusicPath = null;
      _selectedMusicName = null;
    });
  }

  void _showFocusModeSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Focus Mode Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Background Music Section
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.music_note),
              title: Text(_selectedMusicName ?? 'No music selected'),
              subtitle: const Text('Background music'),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: () {
                  Navigator.pop(context);
                  _pickMusic();
                },
              ),
            ),
            if (_selectedMusicPath != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleMusic();
                    },
                    icon: Icon(_isMusicPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isMusicPlaying ? 'Pause' : 'Play'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _stopMusic();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Session Duration
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Session Duration (minutes)',
                hintText: '0 for no timer',
                prefixIcon: Icon(Icons.timer),
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
    _audioPlayer.dispose();
    _saveContent(); // Save before disposing
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate top padding based on settings bar visibility
    final topBarHeight = _showSettingsBar ? 80.0 : 0.0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetHideUITimer,
        onPanUpdate: (_) => _resetHideUITimer(),
        child: Stack(
          children: [
            // Main editor with proper top padding
            Positioned.fill(
              top: topBarHeight,
              child: Padding(
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
            ),
            
            // Top UI bar with toggle button
            if (_showUI && _showSettingsBar)
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
                        IconButton(
                          icon: Icon(
                            _showSettingsBar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSettingsBar = !_showSettingsBar;
                            });
                          },
                          tooltip: _showSettingsBar ? 'Hide bar' : 'Show bar',
                        ),
                        const Spacer(),
                        if (_isSessionActive) ...[
                          const Icon(Icons.timer, color: Colors.white, size: 16),
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
                        if (_selectedMusicPath != null)
                          IconButton(
                            icon: Icon(
                              _isMusicPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _toggleMusic,
                            tooltip: _isMusicPlaying ? 'Pause music' : 'Play music',
                          ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: _showFocusModeSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Toggle button when bar is hidden
            if (_showUI && !_showSettingsBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _showSettingsBar = !_showSettingsBar;
                          });
                        },
                        tooltip: 'Show bar',
                      ),
                    ),
                  ),
                ),
              ),
            
            // Music indicator
            if (_selectedMusicPath != null && _showUI)
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
                      Icon(
                        _isMusicPlaying ? Icons.music_note : Icons.music_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedMusicName ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

