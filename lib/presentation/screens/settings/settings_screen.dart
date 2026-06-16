import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/font_service.dart';
import '../../../data/models/preferences_model.dart';
import '../../theme/zing_theme.dart';
import 'font_screen.dart';
import 'creators_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late UserPreferences _prefs;

  late AnimationController _entryController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _prefs = _db.getPreferences();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _save() async => await _db.savePreferences(_prefs);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final currentFont = ref.watch(quoteFontProvider);
    final fontLabel = ZingTheme.quoteFonts
        .firstWhere((f) => f.id == currentFont,
            orElse: () => ZingTheme.quoteFonts.first)
        .label;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(32, top + 24, 32, bottom + 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Row(
                  children: [
                    const SizedBox(width: 44),
                    const Spacer(),
                    Text('SETTINGS',
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

                const SizedBox(height: 40),

                // ── Quotes Per Day ─────────────────────────────────────────
                _SectionLabel(label: 'QUOTES PER DAY'),
                const SizedBox(height: 16),
                _FrequencySelector(
                  value: _prefs.quotesPerDay,
                  onChange: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _prefs.quotesPerDay = val);
                    _save();
                  },
                ),

                const SizedBox(height: 40),
                _Divider(),
                const SizedBox(height: 40),

                // ── Appearance ─────────────────────────────────────────────
                _SectionLabel(label: 'APPEARANCE'),
                const SizedBox(height: 16),

                // Font picker row → navigates to full font screen
                _NavRow(
                  label: 'Quote font',
                  value: fontLabel,
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const FontScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOut)),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _Divider(),
                const SizedBox(height: 40),

                // ── Notifications ──────────────────────────────────────────
                _SectionLabel(label: 'NOTIFICATIONS'),
                const SizedBox(height: 16),
                _ToggleRow(
                  label: 'Quote notifications',
                  sublabel: 'Get notified when your quote refreshes',
                  value: _prefs.notificationsEnabled,
                  onToggle: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _prefs.notificationsEnabled = val);
                    _save();
                  },
                ),
                const SizedBox(height: 24),
                _ToggleRow(
                  label: 'Home widget',
                  sublabel: 'Show current quote on your home screen',
                  value: _prefs.widgetEnabled,
                  onToggle: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _prefs.widgetEnabled = val);
                    _save();
                  },
                ),

                const SizedBox(height: 40),
                _Divider(),
                const SizedBox(height: 40),

                // ── Content ────────────────────────────────────────────────
                _SectionLabel(label: 'CONTENT'),
                const SizedBox(height: 16),
                _ToggleRow(
                  label: 'Profanity filter',
                  sublabel: 'Hide quotes containing strong language',
                  value: _prefs.profanityFilter,
                  onToggle: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _prefs.profanityFilter = val);
                    _save();
                  },
                ),

                const SizedBox(height: 40),
                _Divider(),
                const SizedBox(height: 40),

                // ── Creators ───────────────────────────────────────────────
                _SectionLabel(label: 'CREATORS'),
                const SizedBox(height: 16),
                _NavRow(
                  label: 'Manage your creators',
                  value: 'View all',
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const CreatorsScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOut)),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _Divider(),
                const SizedBox(height: 40),

                // ── About ──────────────────────────────────────────────────
                _SectionLabel(label: 'ABOUT'),
                const SizedBox(height: 16),
                Text('An open only you place.',
                    style: TextStyle(
                      fontFamily: ZingTheme.displayFont,
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.6,
                    )),
                const SizedBox(height: 8),
                Text(
                  'Zing collects no data. Everything lives on your device. No account. No tracking. Nothing leaves.',
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 13,
                    color: ZingTheme.softGrey,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text('VERSION 1.0.0',
                    style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 11,
                      color: ZingTheme.dividerGrey,
                      letterSpacing: 2.0,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Row ───────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _NavRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: ZingTheme.darkGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZingTheme.dividerGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 14,
                    color: Colors.white,
                  )),
            ),
            Text(value,
                style: TextStyle(
                  fontFamily: ZingTheme.bodyFont,
                  fontSize: 13,
                  color: ZingTheme.softGrey,
                )),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                color: ZingTheme.softGrey, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Frequency Selector ────────────────────────────────────────────────────────

class _FrequencySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;

  const _FrequencySelector({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final options = [1, 2, 3, 5, 10];
    return Row(
      children: options.map((opt) {
        final isActive = opt == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(opt),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : ZingTheme.darkGrey,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive ? Colors.white : ZingTheme.dividerGrey),
              ),
              alignment: Alignment.center,
              child: Text('$opt',
                  style: TextStyle(
                    fontFamily: ZingTheme.bodyFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.black : ZingTheme.softGrey,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onToggle;

  const _ToggleRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 14,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(sublabel,
                  style: TextStyle(
                      fontFamily: ZingTheme.bodyFont,
                      fontSize: 12,
                      color: ZingTheme.softGrey)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _ZingSwitch(value: value, onToggle: onToggle),
      ],
    );
  }
}

class _ZingSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;

  const _ZingSwitch({required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48, height: 28,
        decoration: BoxDecoration(
          color: value ? Colors.white : ZingTheme.darkGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: value ? Colors.white : ZingTheme.dividerGrey),
        ),
        padding: const EdgeInsets.all(3),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: value ? Colors.black : ZingTheme.softGrey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          fontFamily: ZingTheme.bodyFont,
          fontSize: 11,
          color: ZingTheme.softGrey,
          letterSpacing: 2.5,
        ));
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: ZingTheme.dividerGrey);
}
