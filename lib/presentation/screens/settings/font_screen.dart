import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/font_service.dart';
import '../../theme/zing_theme.dart';

class FontScreen extends ConsumerWidget {
  const FontScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(quoteFontProvider);
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: top + 24),

          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const Spacer(),
                Text('QUOTE FONT',
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ZingTheme.softGrey,
                      letterSpacing: 3.0,
                    )),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Live Preview ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREVIEW',
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 10,
                      color: ZingTheme.softGrey,
                      letterSpacing: 2.5,
                    )),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Text(
                    '"Technoblade never dies."',
                    key: ValueKey(currentFont),
                    style: TextStyle(
                      fontFamily: currentFont,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    ZingTheme.quoteFonts
                        .firstWhere((f) => f.id == currentFont,
                            orElse: () => ZingTheme.quoteFonts.first)
                        .description,
                    key: ValueKey('desc_$currentFont'),
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 12,
                      color: ZingTheme.softGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(height: 1, color: ZingTheme.dividerGrey),
          ),

          const SizedBox(height: 8),

          // ── Font List ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(32, 8, 32, bottom + 32),
              itemCount: ZingTheme.quoteFonts.length,
              itemBuilder: (context, i) {
                final font = ZingTheme.quoteFonts[i];
                final isActive = font.id == currentFont;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(quoteFontProvider.notifier).setFont(font.id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : ZingTheme.darkGrey,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive ? Colors.white : ZingTheme.dividerGrey,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Font sample
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                font.label,
                                style: TextStyle(
                                  fontFamily: font.id,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: isActive
                                      ? Colors.black
                                      : Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                font.description,
                                style: TextStyle(
                                  fontFamily: ZingTheme.bodyFont,
                                  fontSize: 12,
                                  color: isActive
                                      ? Colors.black54
                                      : ZingTheme.softGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sample text in that font
                        Text(
                          'Aa Bb',
                          style: TextStyle(
                            fontFamily: font.id,
                            fontSize: 16,
                            color: isActive
                                ? Colors.black38
                                : ZingTheme.dividerGrey,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Check
                        AnimatedOpacity(
                          opacity: isActive ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Note
          Padding(
            padding: EdgeInsets.fromLTRB(32, 0, 32, bottom + 16),
            child: Text(
              'Applies inside Zing only. Widgets use your system font.',
              style: TextStyle(
                fontFamily: ZingTheme.bodyFont,
                fontSize: 11,
                color: ZingTheme.dividerGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
