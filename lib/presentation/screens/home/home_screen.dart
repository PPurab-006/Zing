import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/quote_service.dart';
import '../../../core/services/font_service.dart';
import '../../../data/models/quote_model.dart';
import '../../theme/zing_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final _db = DatabaseService();
  late final QuoteService _quoteService;

  Quote? _currentQuote;
  bool _loading = true;

  late AnimationController _quoteEntryController;
  late Animation<double> _quoteFade;
  late Animation<Offset> _quoteSlide;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _quoteService = QuoteService(_db);
    _setupAnimations();
    _loadQuote();
  }

  void _setupAnimations() {
    _quoteEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _quoteFade = CurvedAnimation(
      parent: _quoteEntryController,
      curve: Curves.easeOut,
    );
    _quoteSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _quoteEntryController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadQuote({bool isRefresh = false}) async {
    if (isRefresh) await _quoteEntryController.reverse();
    final quote = isRefresh
        ? await _quoteService.nextQuote()
        : await _quoteService.getCurrentQuote();
    setState(() {
      _currentQuote = quote;
      _loading = false;
    });
    _quoteEntryController.forward(from: 0);
  }

  Future<void> _toggleFavourite() async {
    if (_currentQuote == null) return;
    HapticFeedback.lightImpact();
    await _quoteService.toggleFavourite(_currentQuote!);
    setState(() {});
  }

  Future<void> _openSource() async {
    final url = _currentQuote?.source?.youtubeUrl;
    if (url == null) return;
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) =>
      setState(() => _dragOffset += d.delta.dx);

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (_dragOffset.abs() > 80) _loadQuote(isRefresh: true);
    setState(() => _dragOffset = 0);
  }

  @override
  void dispose() {
    _quoteEntryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final quoteFont = ref.watch(quoteFontProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: EdgeInsets.fromLTRB(32, top + 24, 32, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ──────────────────────────────────────────────────
              const _TopBar(),

              const Spacer(flex: 2),

              // ── Quote ────────────────────────────────────────────────────
              if (!_loading && _currentQuote != null)
                FadeTransition(
                  opacity: _quoteFade,
                  child: SlideTransition(
                    position: _quoteSlide,
                    child: Transform.translate(
                      offset: Offset(_dragOffset * 0.04, 0),
                      child: _QuoteCard(
                        quote: _currentQuote!,
                        quoteFont: quoteFont,
                        onFavourite: _toggleFavourite,
                        onSource: _currentQuote!.source != null
                            ? _openSource
                            : null,
                      ),
                    ),
                  ),
                ),

              if (_loading) const Expanded(child: SizedBox.shrink()),

              const Spacer(flex: 3),

              // ── Swipe Hint ────────────────────────────────────────────────
              _SwipeHint(dragOffset: _dragOffset),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ZING',
          style: TextStyle(
            fontFamily: ZingTheme.bodyFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 6.0,
          ),
        ),
      ],
    );
  }
}

// ── Quote Card ────────────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final String quoteFont;
  final VoidCallback onFavourite;
  final VoidCallback? onSource;

  const _QuoteCard({
    required this.quote,
    required this.quoteFont,
    required this.onFavourite,
    this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote text
        Text(
          '"${quote.text}"',
          style: ZingTheme.quoteStyle.copyWith(fontFamily: quoteFont),
        ),

        const SizedBox(height: 28),

        // Creator name + favourite row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 24, height: 1, color: ZingTheme.softGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                quote.creatorName.toUpperCase(),
                style: ZingTheme.creatorNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _ActionButton(
              icon: quote.isFavourited
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              semanticLabel:
                  quote.isFavourited ? 'Unfavourite' : 'Favourite',
              onTap: onFavourite,
              active: quote.isFavourited,
            ),
          ],
        ),

        // Tags
        if (quote.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: quote.tags
                .take(3)
                .map((tag) => _Tag(label: tag))
                .toList(),
          ),
        ],

        // ── RED WATCH BUTTON ─────────────────────────────────────────────
        if (onSource != null) ...[
          const SizedBox(height: 28),
          _WatchButton(onTap: onSource!),
        ],
      ],
    );
  }
}

// ── Watch Button ──────────────────────────────────────────────────────────────

class _WatchButton extends StatefulWidget {
  final VoidCallback onTap;
  const _WatchButton({required this.onTap});

  @override
  State<_WatchButton> createState() => _WatchButtonState();
}

class _WatchButtonState extends State<_WatchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935), // Zing Red
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'WATCH',
                style: TextStyle(
                  fontFamily: ZingTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.active = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              color: widget.active ? Colors.white : ZingTheme.softGrey,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: ZingTheme.dividerGrey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label.toUpperCase(), style: ZingTheme.categoryStyle),
    );
  }
}

// ── Swipe Hint ────────────────────────────────────────────────────────────────

class _SwipeHint extends StatelessWidget {
  final double dragOffset;
  const _SwipeHint({required this.dragOffset});

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (dragOffset.abs() / 120)).clamp(0.0, 1.0);
    return AnimatedOpacity(
      opacity: opacity * 0.4,
      duration: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 10),
          const SizedBox(width: 8),
          Text(
            'SWIPE FOR NEXT',
            style: TextStyle(
              fontFamily: ZingTheme.bodyFont,
              fontSize: 10,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 10),
        ],
      ),
    );
  }
}
