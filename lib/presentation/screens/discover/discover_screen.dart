import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/font_service.dart';
import '../../../data/models/quote_model.dart';
import '../../theme/zing_theme.dart';
import '../creator/creator_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();

  Quote? _quote;
  bool _revealed = false;
  bool _loading = true;
  String? _selectedTag;

  late AnimationController _revealController;
  late Animation<double> _revealFade;
  late Animation<double> _quoteFade;

  // Interest filter tags
  final List<String> _tags = [
    'All', 'iconic', 'funny', 'emotional',
    'motivational', 'gaming', 'community', 'deep',
  ];

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _revealFade = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOut,
    );
    _quoteFade = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOut,
    );
    _loadQuote();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loading = true;
      _revealed = false;
    });
    _revealController.reset();

    // Get all creators not in selected list — discover pool
    final prefs = _db.getPreferences();
    final allCreators = _db.getAllCreators();

    // Open all creator boxes for discover
    await _db.openSelectedCreatorBoxes(
      allCreators.map((c) => c.id).toList(),
    );

    final quote = _db.getRandomQuote(
      allCreators.map((c) => c.id).toList(),
      filterProfanity: prefs.profanityFilter,
      tagFilter: _selectedTag == 'All' ? null : _selectedTag,
    );

    setState(() {
      _quote = quote;
      _loading = false;
    });

    _revealController.forward();
  }

  void _reveal() {
    if (_revealed) return;
    HapticFeedback.mediumImpact();
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final quoteFont = ref.watch(quoteFontProvider);

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
                Text(
                  'DISCOVER',
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 6.0,
                  ),
                ),
                const Spacer(),
                // Refresh button
                GestureDetector(
                  onTap: _loadQuote,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44, height: 44,
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: ZingTheme.softGrey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Who said this?',
              style: TextStyle(
                fontFamily: ZingTheme.bodyFont,
                fontSize: 12,
                color: ZingTheme.softGrey,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Interest Filter Tags ───────────────────────────────────────
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              itemCount: _tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tag = _tags[i];
                final isActive = (_selectedTag == null && tag == 'All') ||
                    _selectedTag == tag;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedTag = tag == 'All' ? null : tag;
                    });
                    _loadQuote();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? Colors.white
                            : ZingTheme.dividerGrey,
                      ),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: TextStyle(
                        fontFamily: ZingTheme.bodyFont,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isActive ? Colors.black : ZingTheme.softGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(flex: 2),

          // ── Quote Area ─────────────────────────────────────────────────
          if (!_loading && _quote != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _quoteFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote text
                    Text(
                      '"${_quote!.text}"',
                      style: ZingTheme.quoteStyle.copyWith(
                        fontFamily: quoteFont,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Creator reveal
                    GestureDetector(
                      onTap: _revealed
                          ? () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => CreatorScreen(
                                    creatorId: _quote!.creatorId,
                                    creatorName: _quote!.creatorName,
                                  ),
                                  transitionsBuilder: (_, anim, __, child) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOut)),
                                    child: child,
                                  ),
                                  transitionDuration:
                                      const Duration(milliseconds: 350),
                                ),
                              )
                          : _reveal,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: _revealed
                              ? Colors.white
                              : ZingTheme.darkGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _revealed
                                ? Colors.white
                                : ZingTheme.dividerGrey,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _revealed
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _quote!.creatorName.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: ZingTheme.bodyFont,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap to know more →',
                                          style: TextStyle(
                                            fontFamily: ZingTheme.bodyFont,
                                            fontSize: 11,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'TAP TO REVEAL',
                                      style: TextStyle(
                                        fontFamily: ZingTheme.bodyFont,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: ZingTheme.softGrey,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                            ),
                            Icon(
                              _revealed
                                  ? Icons.arrow_forward_ios_rounded
                                  : Icons.visibility_rounded,
                              color: _revealed
                                  ? Colors.black38
                                  : ZingTheme.softGrey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Spacer(flex: 3),

          // ── Next Quote Button ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(32, 0, 32, bottom + 24),
            child: GestureDetector(
              onTap: _loadQuote,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: ZingTheme.darkGrey,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZingTheme.dividerGrey),
                ),
                alignment: Alignment.center,
                child: Text(
                  'NEXT QUOTE',
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ZingTheme.softGrey,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
