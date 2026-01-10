import 'package:hive/hive.dart';

part 'world_element.g.dart';

@HiveType(typeId: 9)
class WorldElement extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String type; // 'location', 'lore', 'magic_system', 'timeline', 'culture', 'language'

  @HiveField(4)
  late String description;

  @HiveField(5)
  late Map<String, String> customFields; // Flexible metadata

  @HiveField(6)
  late List<String> tags;

  @HiveField(7)
  late List<String> relatedElements; // IDs of related world elements

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime lastModified;

  WorldElement({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.description,
    required this.customFields,
    required this.tags,
    required this.relatedElements,
    required this.createdAt,
    required this.lastModified,
  });
}

