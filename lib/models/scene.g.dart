// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scene.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SceneAdapter extends TypeAdapter<Scene> {
  @override
  final int typeId = 8;

  @override
  Scene read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Scene(
      id: fields[0] as String,
      chapterId: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      order: fields[4] as int,
      summary: fields[5] as String,
      tags: (fields[6] as List).cast<String>(),
      location: fields[7] as String,
      characters: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Scene obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.characters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SceneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
