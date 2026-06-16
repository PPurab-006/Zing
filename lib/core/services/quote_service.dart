import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/preferences_model.dart';

class QuoteService {
  final DatabaseService _db;

  QuoteService(this._db);

  Future<Quote?> getCurrentQuote() async {
    final prefs = _db.getPreferences();
    if (_isRefreshDue(prefs)) return await refreshQuote(prefs);
    if (prefs.currentQuoteId != null) {
      return _findQuoteById(prefs.currentQuoteId!, prefs.selectedCreatorIds);
    }
    return await refreshQuote(prefs);
  }

  Future<Quote?> refreshQuote(UserPreferences prefs) async {
    final quote = _db.getRandomQuote(
      prefs.selectedCreatorIds,
      filterProfanity: prefs.profanityFilter,
    );
    if (quote == null) return null;
    await _db.markQuoteAsShown(quote);
    prefs.currentQuoteId = quote.id;
    prefs.lastQuoteRefresh = DateTime.now();
    await _db.savePreferences(prefs);
    return quote;
  }

  Future<Quote?> nextQuote() async {
    final prefs = _db.getPreferences();
    return await refreshQuote(prefs);
  }

  bool _isRefreshDue(UserPreferences prefs) {
    if (prefs.lastQuoteRefresh == null) return true;
    if (prefs.currentQuoteId == null) return true;
    final interval = _intervalForFrequency(prefs.quotesPerDay);
    final nextRefresh = prefs.lastQuoteRefresh!.add(interval);
    return DateTime.now().isAfter(nextRefresh);
  }

  Duration _intervalForFrequency(int quotesPerDay) {
    final hoursInterval = 24 / quotesPerDay;
    final minutes = (hoursInterval * 60).round();
    return Duration(minutes: minutes);
  }

  DateTime nextRefreshTime() {
    final prefs = _db.getPreferences();
    if (prefs.lastQuoteRefresh == null) return DateTime.now();
    return prefs.lastQuoteRefresh!
        .add(_intervalForFrequency(prefs.quotesPerDay));
  }

  Future<void> toggleFavourite(Quote quote) async {
    await _db.toggleFavourite(quote);
  }

  List<Quote> getFavourites() {
    final prefs = _db.getPreferences();
    return _db.getFavourites(prefs.selectedCreatorIds);
  }

  Quote? _findQuoteById(String id, List<String> creatorIds) {
    for (final creatorId in creatorIds) {
      final boxName = 'quotes_$creatorId';
      try {
        final box = _db.getQuoteBox(boxName);
        final quote = box?.get(id);
        if (quote != null) return quote;
      } catch (e) {
        debugPrint('Could not find quote $id in $boxName');
      }
    }
    return null;
  }
}
