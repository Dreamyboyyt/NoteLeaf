import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 5)
class Note extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String content;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime lastModified;

  Note({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastModified,
  });
}

