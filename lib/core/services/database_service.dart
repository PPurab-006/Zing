import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/creator_model.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/preferences_model.dart';

class DatabaseService {
  static const String _creatorsBox = 'creators';
  static const String _preferencesBox = 'preferences';
  static const String _quotesBoxPrefix = 'quotes_';

  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // ─── Initialisation ────────────────────────────────────────────────────────

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CreatorAdapter());
    Hive.registerAdapter(QuoteSourceAdapter());
    Hive.registerAdapter(QuoteAdapter());
    Hive.registerAdapter(UserPreferencesAdapter());

    await Hive.openBox<Creator>(_creatorsBox);
    await Hive.openBox<UserPreferences>(_preferencesBox);

    await _seedCreatorsIfNeeded();

    // CRITICAL: Reopen quote boxes for previously selected creators on every launch
    // Without this relaunch shows black screen — boxes are closed between sessions
    final prefs = getPreferences();
    for (final id in prefs.selectedCreatorIds) {
      await _ensureQuoteBoxOpen(id);
    }
  }

  // ─── Creators ──────────────────────────────────────────────────────────────

  Future<void> _seedCreatorsIfNeeded() async {
    final box = Hive.box<Creator>(_creatorsBox);

    final String jsonStr = await rootBundle.loadString('assets/data/creators.json');
    final List<dynamic> jsonList = json.decode(jsonStr);

    for (final item in jsonList) {
      final newCreator = Creator.fromJson(item as Map<String, dynamic>);
      final existingCreator = box.get(newCreator.id);
      
      if (existingCreator != null) {
        newCreator.isSelected = existingCreator.isSelected;
      }
      
      await box.put(newCreator.id, newCreator);
    }
  }

  List<Creator> getAllCreators() {
    final box = Hive.box<Creator>(_creatorsBox);
    return box.values.toList();
  }

  List<Creator> getCreatorsByCategory(String category) {
    final box = Hive.box<Creator>(_creatorsBox);
    return box.values.where((c) => c.category == category).toList();
  }

  List<Creator> getSelectedCreators() {
    final box = Hive.box<Creator>(_creatorsBox);
    return box.values.where((c) => c.isSelected).toList();
  }

  Future<void> toggleCreatorSelection(String creatorId, bool selected) async {
    final box = Hive.box<Creator>(_creatorsBox);
    final creator = box.get(creatorId);
    if (creator != null) {
      creator.isSelected = selected;
      await creator.save();

      if (selected) {
        await _ensureQuoteBoxOpen(creatorId);
      }
    }

    // Sync preferences selectedCreatorIds
    final prefs = getPreferences();
    final ids = box.values.where((c) => c.isSelected).map((c) => c.id).toList();
    prefs.selectedCreatorIds = ids;
    await savePreferences(prefs);
  }

  // ─── Quotes ────────────────────────────────────────────────────────────────

  /// Opens the quote box and seeds from JSON if needed
  Future<void> _ensureQuoteBoxOpen(String creatorId) async {
    final boxName = '$_quotesBoxPrefix$creatorId';

    // Open box if not already open
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Quote>(boxName);
    }

    final box = Hive.box<Quote>(boxName);

    // Sync quotes from JSON while preserving states like isFavourited
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/data/quotes/$creatorId.json');
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      final List<dynamic> quotesList = jsonData['quotes'];
      final String creatorName = jsonData['creator_name'];
      final String category = jsonData['category'];

      for (final item in quotesList) {
        final newQuote = Quote.fromJson(
          item as Map<String, dynamic>,
          creatorId,
          creatorName,
          category,
        );
        
        final existingQuote = box.get(newQuote.id);
        if (existingQuote == null) {
          await box.put(newQuote.id, newQuote);
        } else {
          // If we want to support updating existing quotes, we could do it here.
          // Since Hive objects' fields are usually final in this app except state,
          // we only insert new quotes that aren't in the box yet.
        }
      }
    } catch (e) {
      debugPrint('Failed to load quotes for $creatorId: $e');
    }
  }

  Future<void> openSelectedCreatorBoxes(List<String> creatorIds) async {
    for (final id in creatorIds) {
      await _ensureQuoteBoxOpen(id);
    }
  }

  Quote? getRandomQuote(List<String> selectedCreatorIds,
      {bool filterProfanity = false, String? tagFilter}) {
    final List<Quote> pool = [];

    for (final id in selectedCreatorIds) {
      final boxName = '$_quotesBoxPrefix$id';
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<Quote>(boxName);
        final quotes = box.values.where((q) {
          if (filterProfanity && q.tags.contains('profanity')) return false;
          if (tagFilter != null && !q.tags.contains(tagFilter)) return false;
          return true;
        });
        pool.addAll(quotes);
      }
    }

    if (pool.isEmpty) return null;
    final unseen = pool.where((q) => q.lastShown == null).toList();
    final candidates = unseen.isNotEmpty ? unseen : pool;
    candidates.shuffle();
    return candidates.first;
  }

  Future<void> markQuoteAsShown(Quote quote) async {
    quote.lastShown = DateTime.now();
    await quote.save();
  }

  Future<void> toggleFavourite(Quote quote) async {
    quote.isFavourited = !quote.isFavourited;
    await quote.save();
  }

  Box<Quote>? getQuoteBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) return null;
    return Hive.box<Quote>(boxName);
  }

  List<Quote> getFavourites(List<String> selectedCreatorIds) {
    final List<Quote> favs = [];
    for (final id in selectedCreatorIds) {
      final boxName = '$_quotesBoxPrefix$id';
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<Quote>(boxName);
        favs.addAll(box.values.where((q) => q.isFavourited));
      }
    }
    return favs;
  }

  // ─── Preferences ───────────────────────────────────────────────────────────

  UserPreferences getPreferences() {
    final box = Hive.box<UserPreferences>(_preferencesBox);
    return box.get('prefs') ?? UserPreferences();
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    final box = Hive.box<UserPreferences>(_preferencesBox);
    await box.put('prefs', prefs);
  }
}
