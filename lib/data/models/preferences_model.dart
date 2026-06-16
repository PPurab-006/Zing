import 'package:hive/hive.dart';

part 'preferences_model.g.dart';

@HiveType(typeId: 3)
class UserPreferences extends HiveObject {
  @HiveField(0)
  List<String> selectedCreatorIds;

  @HiveField(1)
  int quotesPerDay;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  bool widgetEnabled;

  @HiveField(4)
  bool onboardingComplete;

  @HiveField(5)
  DateTime? lastQuoteRefresh;

  @HiveField(6)
  String? currentQuoteId;

  @HiveField(7)
  String quoteFont;

  @HiveField(8)
  bool profanityFilter; // When true, hides quotes tagged with profanity

  UserPreferences({
    this.selectedCreatorIds = const [],
    this.quotesPerDay = 2,
    this.notificationsEnabled = true,
    this.widgetEnabled = true,
    this.onboardingComplete = false,
    this.lastQuoteRefresh,
    this.currentQuoteId,
    this.quoteFont = 'PlayfairDisplay',
    this.profanityFilter = false,
  });
}
