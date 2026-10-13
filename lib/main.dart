import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure pleasant portrait orientation for kids
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KidsCardMatchApp());
}

class KidsCardMatchApp extends StatelessWidget {
  const KidsCardMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아기자기 같은 그림 찾기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF80AB),
          primary: const Color(0xFFFF80AB),
          secondary: const Color(0xFF80D8FF),
          surface: const Color(0xFFF9F7FE),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7FE),
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
