import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/creator_model.dart';
import '../../theme/zing_theme.dart';

class CreatorsScreen extends StatefulWidget {
  const CreatorsScreen({super.key});

  @override
  State<CreatorsScreen> createState() => _CreatorsScreenState();
}

class _CreatorsScreenState extends State<CreatorsScreen> {
  final _db = DatabaseService();
  late List<Creator> _creators;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _creators = _db.getAllCreators()
      ..sort((a, b) => a.name.compareTo(b.name)); // alphabetical
  }

  List<Creator> get _filtered {
    if (_search.isEmpty) return _creators;
    return _creators
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  Future<void> _toggle(Creator creator) async {
    HapticFeedback.lightImpact();
    await _db.toggleCreatorSelection(creator.id, !creator.isSelected);
    setState(() {
      _creators = _db.getAllCreators()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    final categories = [
      ('YOUTUBERS', 'youtuber'),
      ('STREAMERS', 'streamer'),
      ('ICONS', 'public_figure'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
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
                Text('YOUR CREATORS',
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

          const SizedBox(height: 16),

          // ── Search ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: ZingTheme.darkGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ZingTheme.dividerGrey),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded,
                      color: ZingTheme.softGrey, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: TextStyle(
                        fontFamily: ZingTheme.bodyFont,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search creators...',
                        hintStyle: TextStyle(
                          fontFamily: ZingTheme.bodyFont,
                          fontSize: 14,
                          color: ZingTheme.softGrey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Creator List (alphabetical, grouped by category) ───────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottom + 32),
              children: [
                if (_search.isNotEmpty)
                  // Flat search results
                  ..._filtered.map((c) => _CreatorRow(
                        creator: c,
                        onToggle: () => _toggle(c),
                      ))
                else
                  // Grouped by category
                  ...categories.expand((cat) {
                    final label = cat.$1;
                    final id = cat.$2;
                    final group =
                        _filtered.where((c) => c.category == id).toList();
                    if (group.isEmpty) return <Widget>[];
                    return [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 12),
                        child: Text(label,
                            style: TextStyle(
                              fontFamily: ZingTheme.bodyFont,
                              fontSize: 10,
                              color: ZingTheme.softGrey,
                              letterSpacing: 2.5,
                            )),
                      ),
                      ...group.map((c) => _CreatorRow(
                            creator: c,
                            onToggle: () => _toggle(c),
                          )),
                    ];
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Creator Row ───────────────────────────────────────────────────────────────

class _CreatorRow extends StatelessWidget {
  final Creator creator;
  final VoidCallback onToggle;

  const _CreatorRow({required this.creator, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: creator.isSelected ? Colors.white : ZingTheme.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: creator.isSelected ? Colors.white : ZingTheme.dividerGrey,
          ),
        ),
        child: Row(
          children: [
            // Avatar placeholder — initials
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: creator.isSelected
                    ? ZingTheme.darkGrey
                    : ZingTheme.dividerGrey,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                creator.name[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: ZingTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: creator.isSelected ? Colors.white : ZingTheme.softGrey,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creator.name,
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          creator.isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    creator.category == 'youtuber'
                        ? 'YouTuber'
                        : creator.category == 'streamer'
                            ? 'Streamer'
                            : 'Public Figure',
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 11,
                      color: creator.isSelected
                          ? Colors.black45
                          : ZingTheme.softGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Quotes count
            Text(
              '${creator.quoteCount} quotes',
              style: TextStyle(
                fontFamily: ZingTheme.bodyFont,
                fontSize: 11,
                color: creator.isSelected
                    ? Colors.black38
                    : ZingTheme.dividerGrey,
              ),
            ),

            const SizedBox(width: 12),

            // Toggle indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: creator.isSelected ? Colors.black : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: creator.isSelected
                      ? Colors.black
                      : ZingTheme.dividerGrey,
                ),
              ),
              child: creator.isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
