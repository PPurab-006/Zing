// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuoteSourceAdapter extends TypeAdapter<QuoteSource> {
  @override
  final int typeId = 1;

  @override
  QuoteSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuoteSource(
      videoTitle: fields[0] as String,
      youtubeUrl: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuoteSource obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.videoTitle)
      ..writeByte(1)
      ..write(obj.youtubeUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuoteAdapter extends TypeAdapter<Quote> {
  @override
  final int typeId = 2;

  @override
  Quote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quote(
      id: fields[0] as String,
      text: fields[1] as String,
      creatorId: fields[2] as String,
      creatorName: fields[3] as String,
      category: fields[4] as String,
      tags: (fields[5] as List).cast<String>(),
      language: fields[6] as String,
      source: fields[7] as QuoteSource?,
      isFavourited: fields[8] as bool,
      lastShown: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Quote obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.creatorId)
      ..writeByte(3)
      ..write(obj.creatorName)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.isFavourited)
      ..writeByte(9)
      ..write(obj.lastShown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
