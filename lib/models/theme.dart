import 'package:hive/hive.dart';

part 'theme.g.dart';

@HiveType(typeId: 4)
class Theme extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String description;

  Theme({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
  });
}


