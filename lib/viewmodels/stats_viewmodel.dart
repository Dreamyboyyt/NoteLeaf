import 'package:noteleaf/models/writing_goal.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class StatsViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  WritingGoal? _writingGoal;
  int _totalWords = 0;
  int _todayWords = 0;
  final Map<String, int> _chapterWordCounts = {};

  WritingGoal? get writingGoal => _writingGoal;
  int get totalWords => _totalWords;
  int get todayWords => _todayWords;
  Map<String, int> get chapterWordCounts => _chapterWordCounts;

  double get progressPercentage {
    if (_writingGoal == null || _writingGoal!.totalWordGoal == 0) return 0.0;
    return (_totalWords / _writingGoal!.totalWordGoal).clamp(0.0, 1.0);
  }

  double get dailyProgressPercentage {
    if (_writingGoal == null || _writingGoal!.dailyWordGoal == 0) return 0.0;
    return (_todayWords / _writingGoal!.dailyWordGoal).clamp(0.0, 1.0);
  }

  Future<void> loadStats(String projectId) async {
    setLoading(true);
    try {
      // Load writing goal
      final goalBox = await _hiveService.writingGoalBox;
      _writingGoal = goalBox.values
          .where((goal) => goal.projectId == projectId)
          .firstOrNull;

      // Load chapters and calculate word counts
      final chapterBox = await _hiveService.chapterBox;
      final chapters = chapterBox.values
          .where((chapter) => chapter.projectId == projectId)
          .toList();

      _totalWords = 0;
      _chapterWordCounts.clear();

      for (final chapter in chapters) {
        final wordCount = _getWordCount(chapter.content);
        _chapterWordCounts[chapter.title] = wordCount;
        _totalWords += wordCount;
      }

      // Calculate today's words (simplified - in real app, track daily progress)
      _todayWords = _totalWords; // Placeholder

      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load statistics: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> setWritingGoal(
    String projectId,
    int dailyGoal,
    int totalGoal,
    DateTime deadline,
  ) async {
    try {
      final goalId = DateTime.now().millisecondsSinceEpoch.toString();
      final goal = WritingGoal(
        id: goalId,
        projectId: projectId,
        dailyWordGoal: dailyGoal,
        totalWordGoal: totalGoal,
        deadline: deadline,
        createdAt: DateTime.now(),
      );

      final box = await _hiveService.writingGoalBox;
      
      // Remove existing goal for this project
      final existingGoals = box.values
          .where((g) => g.projectId == projectId)
          .toList();
      for (final existingGoal in existingGoals) {
        await box.delete(existingGoal.id);
      }

      // Add new goal
      await box.put(goalId, goal);
      _writingGoal = goal;
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to set writing goal: $e');
    }
  }

  int _getWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

