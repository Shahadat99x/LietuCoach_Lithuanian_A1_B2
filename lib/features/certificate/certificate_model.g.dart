// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CertificateModelAdapter extends TypeAdapter<CertificateModel> {
  @override
  final int typeId = 4;

  @override
  CertificateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CertificateModel(
      id: fields[0] as String,
      level: fields[1] as String,
      issuedAt: fields[2] as DateTime,
      filePath: fields[3] as String,
      learnerName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CertificateModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.issuedAt)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.learnerName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
