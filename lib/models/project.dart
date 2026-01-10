import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String path;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime lastModified;

  Project({
    required this.id,
    required this.title,
    required this.path,
    required this.createdAt,
    required this.lastModified,
  });
}

