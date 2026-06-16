import 'package:hive/hive.dart';

part 'creator_model.g.dart';

@HiveType(typeId: 0)
class Creator extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String language;

  @HiveField(4)
  final int quoteCount;

  @HiveField(5)
  final String? avatarAsset;

  @HiveField(6)
  bool isSelected;

  @HiveField(7)
  final String? youtubeUrl;

  @HiveField(8)
  final String? twitchUrl;

  @HiveField(9)
  final String? bio;

  Creator({
    required this.id,
    required this.name,
    required this.category,
    required this.language,
    required this.quoteCount,
    this.avatarAsset,
    this.isSelected = false,
    this.youtubeUrl,
    this.twitchUrl,
    this.bio,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      language: json['language'] as String,
      quoteCount: json['quote_count'] as int,
      avatarAsset: json['avatar_asset'] as String?,
      isSelected: false,
      youtubeUrl: json['youtube_url'] as String?,
      twitchUrl: json['twitch_url'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
