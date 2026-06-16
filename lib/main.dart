import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/database_service.dart';
import 'presentation/theme/zing_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await DatabaseService().init();

  runApp(const ProviderScope(child: ZingApp()));
}

class ZingApp extends StatelessWidget {
  const ZingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zing',
      debugShowCheckedModeBanner: false,
      theme: ZingTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
