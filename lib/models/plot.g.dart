// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlotAdapter extends TypeAdapter<Plot> {
  @override
  final int typeId = 3;

  @override
  Plot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plot(
      id: fields[0] as String,
      projectId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      tags: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Plot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
