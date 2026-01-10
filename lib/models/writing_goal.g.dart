// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WritingGoalAdapter extends TypeAdapter<WritingGoal> {
  @override
  final int typeId = 6;

  @override
  WritingGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WritingGoal(
      id: fields[0] as String,
      projectId: fields[1] as String,
      dailyWordGoal: fields[2] as int,
      totalWordGoal: fields[3] as int,
      deadline: fields[4] as DateTime,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WritingGoal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.dailyWordGoal)
      ..writeByte(3)
      ..write(obj.totalWordGoal)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WritingGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
