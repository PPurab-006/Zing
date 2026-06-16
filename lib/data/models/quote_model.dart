import 'package:hive/hive.dart';

part 'quote_model.g.dart';

@HiveType(typeId: 1)
class QuoteSource extends HiveObject {
  @HiveField(0)
  final String videoTitle;

  @HiveField(1)
  final String youtubeUrl;

  QuoteSource({
    required this.videoTitle,
    required this.youtubeUrl,
  });

  factory QuoteSource.fromJson(Map<String, dynamic> json) {
    return QuoteSource(
      videoTitle: json['video_title'] as String,
      youtubeUrl: json['youtube_url'] as String,
    );
  }
}

@HiveType(typeId: 2)
class Quote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String creatorId;

  @HiveField(3)
  final String creatorName;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final QuoteSource? source;

  @HiveField(8)
  bool isFavourited;

  @HiveField(9)
  DateTime? lastShown;

  Quote({
    required this.id,
    required this.text,
    required this.creatorId,
    required this.creatorName,
    required this.category,
    required this.tags,
    required this.language,
    this.source,
    this.isFavourited = false,
    this.lastShown,
  });

  factory Quote.fromJson(Map<String, dynamic> json, String creatorId, String creatorName, String category) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      creatorId: creatorId,
      creatorName: creatorName,
      category: category,
      tags: List<String>.from(json['tags'] ?? []),
      language: json['language'] as String? ?? 'en',
      source: json['source'] != null
          ? QuoteSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
    );
  }
}
