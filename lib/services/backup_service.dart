import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<String?> createBackup(String projectPath, String projectTitle) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupsDir = Directory('${directory.path}/backups');
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = '${projectTitle}_backup_$timestamp.zip';
      final backupPath = '${backupsDir.path}/$backupFileName';

      final encoder = ZipFileEncoder();
      encoder.create(backupPath);
      encoder.addDirectory(Directory(projectPath));
      encoder.close();

      return backupPath;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> restoreBackup(String backupPath, String restoreDirectory) async {
    try {
      final bytes = File(backupPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('$restoreDirectory/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$restoreDirectory/$filename').create(recursive: true);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

