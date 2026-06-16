import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/creator_model.dart';
import '../main/main_shell.dart';
import '../../theme/zing_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _categoryController = PageController();
  late AnimationController _entryController;
  late AnimationController _buttonController;

  final List<String> _categories = ['YouTubers', 'Streamers', 'Icons'];
  final List<String> _categoryIds = ['youtuber', 'streamer', 'public_figure'];
  int _currentCategory = 0;

  Map<String, List<Creator>> _creatorsByCategory = {};
  Set<String> _selectedIds = {};
  bool _loaded = false;

  // Entry animations
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _tabsFade;
  late Animation<double> _gridFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCreators();
  }

  void _setupAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _titleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _subtitleFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );

    _tabsFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _gridFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _entryController.forward();
  }

  Future<void> _loadCreators() async {
    final db = DatabaseService();
    final all = db.getAllCreators();

    final Map<String, List<Creator>> grouped = {
      'youtuber': [],
      'streamer': [],
      'public_figure': [],
    };

    for (final c in all) {
      grouped[c.category]?.add(c);
    }

    setState(() {
      _creatorsByCategory = grouped;
      _loaded = true;
    });
  }

  void _toggleCreator(Creator creator) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedIds.contains(creator.id)) {
        _selectedIds.remove(creator.id);
      } else {
        _selectedIds.add(creator.id);
      }
    });
  }

  Future<void> _finish() async {
    if (_selectedIds.isEmpty) return;

    HapticFeedback.mediumImpact();

    final db = DatabaseService();
    for (final id in _selectedIds) {
      await db.toggleCreatorSelection(id, true);
    }

    final prefs = db.getPreferences();
    prefs.onboardingComplete = true;
    prefs.selectedCreatorIds = _selectedIds.toList();
    await db.savePreferences(prefs);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _buttonController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: top + 48),

          // ── Title ──────────────────────────────────────────────────────────
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR PEOPLE.',
                      style: TextStyle(
                        fontFamily: 'ZingDisplay',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'Choose who zings with you.',
                        style: TextStyle(
                          fontFamily: 'ZingDisplay',
                          fontSize: 14,
                          color: ZingTheme.softGrey,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Category Tabs (Apple action button style) ──────────────────────
          FadeTransition(
            opacity: _tabsFade,
            child: _CategoryTabs(
              categories: _categories,
              current: _currentCategory,
              onTap: (i) {
                setState(() => _currentCategory = i);
                _categoryController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Creator Grid ───────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _gridFade,
              child: !_loaded
                  ? const SizedBox.shrink()
                  : PageView.builder(
                      controller: _categoryController,
                      onPageChanged: (i) =>
                          setState(() => _currentCategory = i),
                      itemCount: _categories.length,
                      itemBuilder: (context, i) {
                        final catId = _categoryIds[i];
                        final creators =
                            _creatorsByCategory[catId] ?? [];
                        return _CreatorGrid(
                          creators: creators,
                          selectedIds: _selectedIds,
                          onToggle: _toggleCreator,
                        );
                      },
                    ),
            ),
          ),

          // ── Continue Button ────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _selectedIds.isNotEmpty ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 16, 32, bottom + 32),
              child: _ZingButton(
                label: _selectedIds.isEmpty
                    ? 'SELECT SOMEONE'
                    : 'LET\'S ZING  →',
                onTap: _selectedIds.isEmpty ? null : _finish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Tabs ─────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int current;
  final ValueChanged<int> onTap;

  const _CategoryTabs({
    required this.categories,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: ZingTheme.darkGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(categories.length, (i) {
            final isActive = i == current;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    categories[i].toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'ZingDisplay',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isActive ? Colors.black : ZingTheme.softGrey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Creator Grid ──────────────────────────────────────────────────────────────

class _CreatorGrid extends StatelessWidget {
  final List<Creator> creators;
  final Set<String> selectedIds;
  final ValueChanged<Creator> onToggle;

  const _CreatorGrid({
    required this.creators,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return Center(
        child: Text(
          'MORE COMING SOON',
          style: TextStyle(
            fontFamily: 'ZingDisplay',
            fontSize: 12,
            color: ZingTheme.softGrey,
            letterSpacing: 2.0,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: creators.length,
      itemBuilder: (context, i) {
        final creator = creators[i];
        final isSelected = selectedIds.contains(creator.id);
        return _CreatorCard(
          creator: creator,
          isSelected: isSelected,
          onTap: () => onToggle(creator),
        );
      },
    );
  }
}

// ── Creator Card ──────────────────────────────────────────────────────────────

class _CreatorCard extends StatefulWidget {
  final Creator creator;
  final bool isSelected;
  final VoidCallback onTap;

  const _CreatorCard({
    required this.creator,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CreatorCard> createState() => _CreatorCardState();
}

class _CreatorCardState extends State<_CreatorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.white : ZingTheme.darkGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? Colors.white : ZingTheme.dividerGrey,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Checkmark when selected
              AnimatedOpacity(
                opacity: widget.isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.creator.name.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'ZingDisplay',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.isSelected ? Colors.black : Colors.white,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.creator.quoteCount} quotes',
                style: TextStyle(
                  fontFamily: 'ZingDisplay',
                  fontSize: 10,
                  color: widget.isSelected
                      ? Colors.black54
                      : ZingTheme.softGrey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Zing Button ───────────────────────────────────────────────────────────────

class _ZingButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _ZingButton({required this.label, this.onTap});

  @override
  State<_ZingButton> createState() => _ZingButtonState();
}

class _ZingButtonState extends State<_ZingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.onTap != null ? Colors.white : ZingTheme.darkGrey,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'ZingDisplay',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.onTap != null ? Colors.black : ZingTheme.softGrey,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
