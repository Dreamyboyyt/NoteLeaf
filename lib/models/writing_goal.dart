import 'package:hive/hive.dart';

part 'writing_goal.g.dart';

@HiveType(typeId: 6)
class WritingGoal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String projectId;

  @HiveField(2)
  late int dailyWordGoal;

  @HiveField(3)
  late int totalWordGoal;

  @HiveField(4)
  late DateTime deadline;

  @HiveField(5)
  late DateTime createdAt;

  WritingGoal({
    required this.id,
    required this.projectId,
    required this.dailyWordGoal,
    required this.totalWordGoal,
    required this.deadline,
    required this.createdAt,
  });
}

