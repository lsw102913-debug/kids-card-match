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
  String? _toastMessage;

  bool get isActive => _isActive;
  String? get toastMessage => _toastMessage;

  void blast({String? message}) {
    _isActive = true;
    _toastMessage = message ?? '우와! 짝을 찾았어요! 🎉';
    notifyListeners();
  }

  void stop() {
    _isActive = false;
    _toastMessage = null;
    notifyListeners();
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

    // Spawn 140 particles from dual cannons (Left & Right) + Center Burst
    for (int i = 0; i < 140; i++) {
      // 0: Left cannon, 1: Right cannon, 2: Center firework
      final originType = i % 3;
      double startX;
      double startY;
      double baseAngle;

      if (originType == 0) {
        // Bottom Left Cannon -> Shoots Up-Right
        startX = 0.15;
        startY = 0.9;
        baseAngle = -pi / 3 + (_rng.nextDouble() - 0.5) * 0.8;
      } else if (originType == 1) {
        // Bottom Right Cannon -> Shoots Up-Left
        startX = 0.85;
        startY = 0.9;
        baseAngle = -2 * pi / 3 + (_rng.nextDouble() - 0.5) * 0.8;
      } else {
        // Center Firework Burst
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
      p.vy += 0.00035; // gravity pull down
      p.vx *= 0.99;    // air resistance
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
    return Stack(
      children: [
        widget.child,
        if (_animController.isAnimating) ...[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SpectacularConfettiPainter(_particles),
              ),
            ),
          ),
          // Cheerful praise floating banner
          if (widget.controller.toastMessage != null)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
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
                            fontSize: 20,
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
        ],
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
        // Circle sparkle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else if (p.shape == 1) {
        // Ribbon / rectangle
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.2, height: p.size * 0.5),
            const Radius.circular(3),
          ),
          paint,
        );
      } else if (p.shape == 2) {
        // 5-point Star
        _drawStar(canvas, p.size / 2, paint);
      } else {
        // Heart
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
