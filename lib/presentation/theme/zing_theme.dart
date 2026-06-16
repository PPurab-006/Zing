import 'package:flutter/material.dart';

class ZingTheme {
  // ─── Palette ───────────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color softGrey = Color(0xFF888888);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color cardGrey = Color(0xFF111111);
  static const Color dividerGrey = Color(0xFF2A2A2A);

  // ─── UI Font (fixed — clean, never changes) ────────────────────────────────
  static const String bodyFont = 'Inter';

  // ─── Quote Font (user's choice) ────────────────────────────────────────────
  // Default — overridden at runtime from UserPreferences
  static String displayFont = 'PlayfairDisplay';

  // ─── Available Quote Fonts ─────────────────────────────────────────────────
  static const List<ZingFont> quoteFonts = [
    ZingFont(id: 'PlayfairDisplay', label: 'Playfair', description: 'Elegant & dramatic'),
    ZingFont(id: 'Lora', label: 'Lora', description: 'Warm & literary'),
    ZingFont(id: 'DMSerifDisplay', label: 'DM Serif', description: 'Modern & clean'),
    ZingFont(id: 'CormorantGaramond', label: 'Cormorant', description: 'Refined & luxurious'),
    ZingFont(id: 'Fraunces', label: 'Fraunces', description: 'Quirky & expressive'),
    ZingFont(id: 'Inter', label: 'Inter', description: 'Minimal & neutral'),
    ZingFont(id: 'DMSans', label: 'DM Sans', description: 'Friendly & modern'),
    ZingFont(id: 'SpaceGrotesk', label: 'Space', description: 'Technical & sharp'),
  ];

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: white,
      colorScheme: const ColorScheme.dark(
        primary: white,
        secondary: softGrey,
        surface: cardGrey,
        onPrimary: black,
        onSecondary: white,
        onSurface: white,
      ),
      fontFamily: bodyFont,
      appBarTheme: const AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: displayFont,
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: white,
          height: 1.4,
        ),
        displayMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: softGrey,
          letterSpacing: 3.0,
        ),
        bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 16, color: white),
        bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 14, color: softGrey),
        labelSmall: TextStyle(fontFamily: bodyFont, fontSize: 11, color: softGrey, letterSpacing: 1.5),
      ),
      dividerColor: dividerGrey,
      cardTheme: const CardThemeData(color: cardGrey, elevation: 0, margin: EdgeInsets.zero),
      iconTheme: const IconThemeData(color: white, size: 20),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─── Dynamic text styles ───────────────────────────────────────────────────
  static TextStyle get quoteStyle => TextStyle(
    fontFamily: displayFont,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: white,
    height: 1.5,
    letterSpacing: 0.3,
  );

  static TextStyle get creatorNameStyle => TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: softGrey,
    letterSpacing: 3.0,
  );

  static TextStyle get categoryStyle => TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    color: softGrey,
    letterSpacing: 2.0,
  );
}

// ─── Font Model ───────────────────────────────────────────────────────────────
class ZingFont {
  final String id;
  final String label;
  final String description;

  const ZingFont({
    required this.id,
    required this.label,
    required this.description,
  });
}
