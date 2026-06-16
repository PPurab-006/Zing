// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 3;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      selectedCreatorIds: (fields[0] as List).cast<String>(),
      quotesPerDay: fields[1] as int,
      notificationsEnabled: fields[2] as bool,
      widgetEnabled: fields[3] as bool,
      onboardingComplete: fields[4] as bool,
      lastQuoteRefresh: fields[5] as DateTime?,
      currentQuoteId: fields[6] as String?,
      quoteFont: fields[7] as String,
      profanityFilter: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.selectedCreatorIds)
      ..writeByte(1)
      ..write(obj.quotesPerDay)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.widgetEnabled)
      ..writeByte(4)
      ..write(obj.onboardingComplete)
      ..writeByte(5)
      ..write(obj.lastQuoteRefresh)
      ..writeByte(6)
      ..write(obj.currentQuoteId)
      ..writeByte(7)
      ..write(obj.quoteFont)
      ..writeByte(8)
      ..write(obj.profanityFilter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
