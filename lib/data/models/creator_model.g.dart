// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatorAdapter extends TypeAdapter<Creator> {
  @override
  final int typeId = 0;

  @override
  Creator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Creator(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      language: fields[3] as String,
      quoteCount: fields[4] as int,
      avatarAsset: fields[5] as String?,
      isSelected: fields[6] as bool,
      youtubeUrl: fields[7] as String?,
      twitchUrl: fields[8] as String?,
      bio: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Creator obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.quoteCount)
      ..writeByte(5)
      ..write(obj.avatarAsset)
      ..writeByte(6)
      ..write(obj.isSelected)
      ..writeByte(7)
      ..write(obj.youtubeUrl)
      ..writeByte(8)
      ..write(obj.twitchUrl)
      ..writeByte(9)
      ..write(obj.bio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
