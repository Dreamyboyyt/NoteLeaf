import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 2)
class Character extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String role;

  @HiveField(4)
  late String backstory;

  @HiveField(5)
  late String personalityTraits;

  Character({
    required this.id,
    required this.projectId,
    required this.name,
    required this.role,
    required this.backstory,
    required this.personalityTraits,
  });
}

