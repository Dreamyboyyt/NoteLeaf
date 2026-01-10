// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'world_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorldElementAdapter extends TypeAdapter<WorldElement> {
  @override
  final int typeId = 9;

  @override
  WorldElement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorldElement(
      id: fields[0] as String,
      projectId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as String,
      description: fields[4] as String,
      customFields: (fields[5] as Map).cast<String, String>(),
      tags: (fields[6] as List).cast<String>(),
      relatedElements: (fields[7] as List).cast<String>(),
      createdAt: fields[8] as DateTime,
      lastModified: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorldElement obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.customFields)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.relatedElements)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorldElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
