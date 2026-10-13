import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_item.dart';

class GameCardWidget extends StatefulWidget {
  final CardItem card;
  final VoidCallback onTap;

  const GameCardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    if (widget.card.isFaceUp || widget.card.isMatched) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant GameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isShow = widget.card.isFaceUp || widget.card.isMatched;
    if (isShow && _controller.value < 0.5) {
      _controller.forward();
    } else if (!isShow && _controller.value > 0.5) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isUnder = (angle >= (pi / 2));

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // 3D depth
            ..rotateY(angle),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: widget.card.isMatched ? null : widget.onTap,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildFrontSide(),
                  )
                : _buildBackSide(),
          ),
        );
      },
    );
  }

  // Card Front (Showing Animal / Fruit / Dinosaur / Vehicle with MAXIMIZED illustration)
  Widget _buildFrontSide() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: widget.card.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.card.isMatched ? Colors.green.shade500 : Colors.white,
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.card.isMatched
                ? Colors.green.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Extra Large Illustration (FittedBox ensures maximum size without overflowing)
              Expanded(
                flex: 7,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      widget.card.emoji,
                      style: const TextStyle(fontSize: 90),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Word label badge
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.card.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.card.isMatched)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Card Back (Hidden, playful candy rainbow theme)
  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF80AB), // Bright candy pink
            Color(0xFF80D8FF), // Cheerful baby blue
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 26),
            ),
          ),
        ),
      ),
    );
  }
}
