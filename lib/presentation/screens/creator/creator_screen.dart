import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/database_service.dart';
import '../../../data/models/creator_model.dart';
import '../../theme/zing_theme.dart';

class CreatorScreen extends StatefulWidget {
  final String creatorId;
  final String creatorName;

  const CreatorScreen({
    super.key,
    required this.creatorId,
    required this.creatorName,
  });

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  Creator? _creator;

  late AnimationController _entryController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _creator = _db.getAllCreators()
        .where((c) => c.id == widget.creatorId)
        .firstOrNull;

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
        parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addToMyZing() async {
    if (_creator == null) return;
    HapticFeedback.mediumImpact();
    await _db.toggleCreatorSelection(
        widget.creatorId, !(_creator!.isSelected));
    setState(() {
      _creator = _db.getAllCreators()
          .where((c) => c.id == widget.creatorId)
          .firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final isSelected = _creator?.isSelected ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              SizedBox(height: top + 24),

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 44, height: 44,
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Text('KNOW THE CREATOR',
                        style: TextStyle(
                          fontFamily: ZingTheme.bodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ZingTheme.softGrey,
                          letterSpacing: 2.5,
                        )),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Avatar ─────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: ZingTheme.darkGrey,
                  shape: BoxShape.circle,
                  border: Border.all(color: ZingTheme.dividerGrey, width: 1),
                  image: _creator?.avatarAsset != null
                      ? DecorationImage(
                          image: AssetImage(_creator!.avatarAsset!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: _creator?.avatarAsset == null
                    ? Text(
                        widget.creatorName[0].toUpperCase(),
                        style: TextStyle(
                          fontFamily: ZingTheme.bodyFont,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 20),

              // ── Name + Category ────────────────────────────────────────
              Text(
                widget.creatorName,
                style: TextStyle(
                  fontFamily: ZingTheme.displayFont,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _creator?.category == 'youtuber'
                    ? 'YOUTUBER'
                    : _creator?.category == 'streamer'
                        ? 'STREAMER'
                        : 'PUBLIC FIGURE',
                style: TextStyle(
                  fontFamily: ZingTheme.bodyFont,
                  fontSize: 11,
                  color: ZingTheme.softGrey,
                  letterSpacing: 3.0,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${_creator?.quoteCount ?? 0} quotes in Zing',
                style: TextStyle(
                  fontFamily: ZingTheme.bodyFont,
                  fontSize: 12,
                  color: ZingTheme.dividerGrey,
                ),
              ),

              if (_creator?.bio != null && _creator!.bio!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _creator!.bio!,
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 14,
                      color: ZingTheme.softGrey,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // ── Platform Links ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    if (_creator?.youtubeUrl != null)
                      _PlatformButton(
                        label: 'WATCH ON YOUTUBE',
                        icon: Icons.play_circle_outline_rounded,
                        color: const Color(0xFFE53935),
                        onTap: () => _launch(_creator!.youtubeUrl!),
                      ),
                    if (_creator?.twitchUrl != null) ...[
                      const SizedBox(height: 12),
                      _PlatformButton(
                        label: 'WATCH ON TWITCH',
                        icon: Icons.live_tv_rounded,
                        color: const Color(0xFF9146FF),
                        onTap: () => _launch(_creator!.twitchUrl!),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Add to My Zing ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: _addToMyZing,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : ZingTheme.dividerGrey,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          color: isSelected
                              ? Colors.black
                              : ZingTheme.softGrey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSelected
                              ? 'IN YOUR ZING'
                              : 'ADD TO MY ZING',
                          style: TextStyle(
                            fontFamily: ZingTheme.bodyFont,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : ZingTheme.softGrey,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Philosophy ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, bottom + 24),
                child: Text(
                  'Zing only gives, never takes.',
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 11,
                    color: ZingTheme.dividerGrey,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PlatformButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: ZingTheme.bodyFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
