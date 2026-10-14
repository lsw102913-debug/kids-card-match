import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  int shape; // 0: circle, 1: ribbon, 2: star, 3: heart

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final ConfettiController controller;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class ConfettiController extends ChangeNotifier {
  bool _isActive = false;
  bool _isMismatch = false;
  String? _toastMessage;
  Timer? _mismatchTimer;

  bool get isActive => _isActive;
  bool get isMismatch => _isMismatch;
  String? get toastMessage => _toastMessage;

  void blast({String? message}) {
    _mismatchTimer?.cancel();
    _isMismatch = false;
    _isActive = true;
    _toastMessage = message ?? '우와! 짝을 찾았어요! 🎉';
    notifyListeners();
  }

  void showMismatch(String message) {
    _mismatchTimer?.cancel();
    _isActive = false;
    _isMismatch = true;
    _toastMessage = message;
    notifyListeners();

    _mismatchTimer = Timer(const Duration(milliseconds: 1400), () {
      _isMismatch = false;
      _toastMessage = null;
      notifyListeners();
    });
  }

  void stop() {
    _mismatchTimer?.cancel();
    _isActive = false;
    _isMismatch = false;
    _toastMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    super.dispose();
  }
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<ConfettiParticle> _particles = [];
  final Random _rng = Random();

  static const List<Color> _palette = [
    Color(0xFFFF1744), // Vivid Red
    Color(0xFFFF007F), // Neon Pink
    Color(0xFFFF9100), // Bright Orange
    Color(0xFFFFEA00), // Sunny Yellow
    Color(0xFF00E676), // Neon Green
    Color(0xFF00E5FF), // Aqua Blue
    Color(0xFF651FFF), // Purple
    Color(0xFFFFD700), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.stop();
          _particles.clear();
        }
      });

    widget.controller.addListener(_handleController);
  }

  void _handleController() {
    if (widget.controller.isActive && !_animController.isAnimating) {
      _spawnSpectacularParticles();
      _animController.forward(from: 0.0);
    }
  }

  void _spawnSpectacularParticles() {
    _particles.clear();

    for (int i = 0; i < 140; i++) {
      final originType = i % 3;
      double startX;
      double startY;
      double baseAngle;

      if (originType == 0) {
        startX = 0.15;
        startY = 0.9;
        baseAngle = -pi / 3 + (_rng.nextDouble() - 0.5) * 0.8;
      } else if (originType == 1) {
        startX = 0.85;
        startY = 0.9;
        baseAngle = -2 * pi / 3 + (_rng.nextDouble() - 0.5) * 0.8;
      } else {
        startX = 0.5;
        startY = 0.45;
        baseAngle = _rng.nextDouble() * 2 * pi;
      }

      final speed = originType == 2
          ? (4.0 + _rng.nextDouble() * 12.0)
          : (8.0 + _rng.nextDouble() * 14.0);

      _particles.add(
        ConfettiParticle(
          x: startX,
          y: startY,
          vx: cos(baseAngle) * speed * 0.0035,
          vy: sin(baseAngle) * speed * 0.0035,
          size: 10.0 + _rng.nextDouble() * 12.0,
          color: _palette[_rng.nextInt(_palette.length)],
          rotation: _rng.nextDouble() * 2 * pi,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 0.28,
          shape: _rng.nextInt(4),
        ),
      );
    }
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.00035;
      p.vx *= 0.99;
      p.rotation += p.rotationSpeed;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showMismatchToast = widget.controller.isMismatch && widget.controller.toastMessage != null;
    final showMatchToast = _animController.isAnimating && widget.controller.toastMessage != null;

    return Stack(
      children: [
        widget.child,
        if (_animController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SpectacularConfettiPainter(_particles),
              ),
            ),
          ),

        // Cheerful Match Praise Floating Banner
        if (showMatchToast)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 260),
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFF4081), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.controller.toastMessage!,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF4081),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Playful Mismatch Banner for Hae-rin
        if (showMismatchToast)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 260),
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFF9800), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.controller.toastMessage!,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SpectacularConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _SpectacularConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      if (p.shape == 0) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else if (p.shape == 1) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.2, height: p.size * 0.5),
            const Radius.circular(3),
          ),
          paint,
        );
      } else if (p.shape == 2) {
        _drawStar(canvas, p.size / 2, paint);
      } else {
        _drawHeart(canvas, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * pi / 5) - pi / 2;
      final x = cos(outerAngle) * radius;
      final y = sin(outerAngle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    final width = radius * 1.5;
    final height = radius * 1.5;
    path.moveTo(0, height * 0.3);
    path.cubicTo(-width * 0.5, -height * 0.2, -width * 0.7, height * 0.4, 0, height);
    path.cubicTo(width * 0.7, height * 0.4, width * 0.5, -height * 0.2, 0, height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpectacularConfettiPainter oldDelegate) => true;
}
