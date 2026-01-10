import 'package:hive/hive.dart';

part 'scene.g.dart';

@HiveType(typeId: 8)
class Scene extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String chapterId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String content;

  @HiveField(4)
  late int order;

  @HiveField(5)
  late String summary;

  @HiveField(6)
  late List<String> tags;

  @HiveField(7)
  late String location;

  @HiveField(8)
  late List<String> characters; // Character IDs present in this scene

  Scene({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.content,
    required this.order,
    required this.summary,
    required this.tags,
    required this.location,
    required this.characters,
  });
}

