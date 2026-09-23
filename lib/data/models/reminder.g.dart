// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 1;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      place: fields[2] as Place,
      initialDistance: fields[3] as double,
      isTracking: fields[4] as bool,
      isArrived: fields[5] as bool,
      notes: fields[6] as String?,
      isAcknowledged: fields[7] as bool? ?? false,
      isAlarm: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.place)
      ..writeByte(3)
      ..write(obj.initialDistance)
      ..writeByte(4)
      ..write(obj.isTracking)
      ..writeByte(5)
      ..write(obj.isArrived)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isAcknowledged)
      ..writeByte(8)
      ..write(obj.isAlarm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
