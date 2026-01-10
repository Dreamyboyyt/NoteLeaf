import 'package:hive/hive.dart';

part 'version_snapshot.g.dart';

@HiveType(typeId: 7)
class VersionSnapshot extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String entityId; // Chapter ID, Note ID, etc.

  @HiveField(2)
  late String entityType; // 'chapter', 'note', etc.

  @HiveField(3)
  late String content;

  @HiveField(4)
  late DateTime timestamp;

  @HiveField(5)
  late String description; // User-provided description or auto-generated

  @HiveField(6)
  late int wordCount;

  VersionSnapshot({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.content,
    required this.timestamp,
    required this.description,
    required this.wordCount,
  });
}

