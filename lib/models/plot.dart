import 'package:hive/hive.dart';

part 'plot.g.dart';

@HiveType(typeId: 3)
class Plot extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late String tags;

  Plot({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.tags,
  });
}


