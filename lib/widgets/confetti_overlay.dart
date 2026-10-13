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
  int shape; // 0: circle, 1: square, 2: star

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
  bool get isActive => _isActive;

  void blast() {
    _isActive = true;
    notifyListeners();
  }

  void stop() {
    _isActive = false;
    notifyListeners();
  }
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<ConfettiParticle> _particles = [];
  final Random _rng = Random();

  static const List<Color> _palette = [
    Color(0xFFFF1744),
    Color(0xFFFF9100),
    Color(0xFFFFEA00),
    Color(0xFF00E676),
    Color(0xFF00B0FF),
    Color(0xFFD500F9),
    Color(0xFFFF4081),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
      _spawnParticles();
      _animController.forward(from: 0.0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 65; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 4.0 + _rng.nextDouble() * 10.0;
      _particles.add(
        ConfettiParticle(
          x: 0.5,
          y: 0.35,
          vx: cos(angle) * speed * 0.0035,
          vy: sin(angle) * speed * 0.0035 - 0.006,
          size: 8.0 + _rng.nextDouble() * 8.0,
          color: _palette[_rng.nextInt(_palette.length)],
          rotation: _rng.nextDouble() * 2 * pi,
          rotationSpeed: (_rng.nextDouble() - 0.5) * 0.2,
          shape: _rng.nextInt(3),
        ),
      );
    }
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.0003; // gravity
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
        if (_animController.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(_particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

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
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(3),
          ),
          paint,
        );
      } else {
        // Star-like diamond
        final path = Path()
          ..moveTo(0, -p.size / 2)
          ..lineTo(p.size / 3, 0)
          ..lineTo(0, p.size / 2)
          ..lineTo(-p.size / 3, 0)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
