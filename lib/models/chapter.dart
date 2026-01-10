import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String content;

  @HiveField(4)
  late int order;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime lastModified;

  Chapter({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.order,
    required this.createdAt,
    required this.lastModified,
  });
}

