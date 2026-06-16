import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main/main_shell.dart';
import '../onboarding/onboarding_screen.dart';
import '../../../core/services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _letterSpacingAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _letterSpacingAnim = Tween<double>(begin: 24.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  void _navigate() {
    final prefs = DatabaseService().getPreferences();
    final destination = prefs.onboardingComplete
        ? const MainShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Text(
                  'ZING',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: _letterSpacingAnim.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
