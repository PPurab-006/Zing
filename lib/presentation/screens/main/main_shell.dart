import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/zing_theme.dart';
import '../home/home_screen.dart';
import '../discover/discover_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Keep screens alive when switching tabs
  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    SettingsScreen(),
  ];

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: ZingTheme.dividerGrey, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.format_quote_rounded,
                  label: 'HOME',
                  isActive: _currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _TabItem(
                  icon: Icons.explore_rounded,
                  label: 'DISCOVER',
                  isActive: _currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _TabItem(
                  icon: Icons.tune_rounded,
                  label: 'SETTINGS',
                  isActive: _currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive ? Colors.white : ZingTheme.softGrey,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: ZingTheme.bodyFont,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isActive ? Colors.white : ZingTheme.softGrey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
