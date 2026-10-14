import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Gracefully handle any layout / rendering errors without showing an opaque grey screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Caught Flutter UI error: ${details.exception}');
    return Material(
      color: const Color(0xFFF9F7FE),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✨', style: TextStyle(fontSize: 32)),
              SizedBox(height: 8),
              Text(
                '화면을 깔끔하게 다시 맞추는 중이에요 🐣',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Lock to landscape mode for spacious and open gameplay
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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
