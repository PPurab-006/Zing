import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../../presentation/theme/zing_theme.dart';

// Global font state — when this changes, quote text rebuilds everywhere
final quoteFontProvider = StateNotifierProvider<FontNotifier, String>((ref) {
  final prefs = DatabaseService().getPreferences();
  return FontNotifier(prefs.quoteFont);
});

class FontNotifier extends StateNotifier<String> {
  FontNotifier(String initial) : super(initial) {
    // Sync theme on init
    ZingTheme.displayFont = initial;
  }

  Future<void> setFont(String fontId) async {
    ZingTheme.displayFont = fontId;
    state = fontId;

    // Persist
    final db = DatabaseService();
    final prefs = db.getPreferences();
    prefs.quoteFont = fontId;
    await db.savePreferences(prefs);
  }
}
