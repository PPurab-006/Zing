import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/font_service.dart';
import '../../presentation/theme/zing_theme.dart';

class FontPicker extends ConsumerWidget {
  const FontPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(quoteFontProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live preview — updates as you scroll through fonts
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            '"Technoblade never dies."',
            key: ValueKey(currentFont),
            style: TextStyle(
              fontFamily: currentFont,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Horizontal scrollable font cards
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ZingTheme.quoteFonts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final font = ZingTheme.quoteFonts[i];
              final isActive = font.id == currentFont;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(quoteFontProvider.notifier).setFont(font.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 90,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : ZingTheme.darkGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? Colors.white : ZingTheme.dividerGrey,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aa',
                        style: TextStyle(
                          fontFamily: font.id,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: isActive ? Colors.black : Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        font.label,
                        style: TextStyle(
                          fontFamily: ZingTheme.bodyFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.black54 : ZingTheme.softGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Applies inside Zing only. Widgets and notifications use your system font.',
          style: TextStyle(
            fontFamily: ZingTheme.bodyFont,
            fontSize: 11,
            color: ZingTheme.dividerGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
