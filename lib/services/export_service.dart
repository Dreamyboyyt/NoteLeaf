import 'dart:io';
import 'package:noteleaf/models/chapter.dart';
import 'package:noteleaf/models/project.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  static final HiveService _hiveService = HiveService();

  static Future<String?> exportProject(
    Project project,
    String format, {
    List<String>? selectedChapterIds,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/exports');
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${project.title}_export_$timestamp.$format';
      final filePath = '${exportsDir.path}/$fileName';

      final chapterBox = await _hiveService.chapterBox;
      List<Chapter> chapters = chapterBox.values
          .where((chapter) => chapter.projectId == project.id)
          .toList();
      
      chapters.sort((a, b) => a.order.compareTo(b.order));

      if (selectedChapterIds != null) {
        chapters = chapters
            .where((chapter) => selectedChapterIds.contains(chapter.id))
            .toList();
      }

      switch (format) {
        case 'txt':
          return await _exportToTxt(filePath, project, chapters);
        case 'md':
          return await _exportToMarkdown(filePath, project, chapters);
        case 'csv':
          return await _exportToCsv(filePath, project, chapters);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String> _exportToTxt(
    String filePath,
    Project project,
    List<Chapter> chapters,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln(project.title.toUpperCase());
    buffer.writeln('=' * project.title.length);
    buffer.writeln();

    for (final chapter in chapters) {
      buffer.writeln(chapter.title);
      buffer.writeln('-' * chapter.title.length);
      buffer.writeln();
      buffer.writeln(chapter.content);
      buffer.writeln();
      buffer.writeln();
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  static Future<String> _exportToMarkdown(
    String filePath,
    Project project,
    List<Chapter> chapters,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('# ${project.title}');
    buffer.writeln();

    for (final chapter in chapters) {
      buffer.writeln('## ${chapter.title}');
      buffer.writeln();
      buffer.writeln(chapter.content);
      buffer.writeln();
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  static Future<String> _exportToCsv(
    String filePath,
    Project project,
    List<Chapter> chapters,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('Chapter Order,Chapter Title,Word Count,Content');

    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      final wordCount = _getWordCount(chapter.content);
      final escapedContent = chapter.content.replaceAll('"', '""');
      buffer.writeln('${i + 1},"${chapter.title}",$wordCount,"$escapedContent"');
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    return filePath;
  }

  static int _getWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}

