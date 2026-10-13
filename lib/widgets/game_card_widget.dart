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
      duration: const Duration(milliseconds: 340),
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
      decoration: BoxDecoration(
        color: widget.card.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.card.isMatched ? const Color(0xFF00E676) : Colors.white,
          width: widget.card.isMatched ? 3.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.card.isMatched
                ? const Color(0xFF00E676).withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Extra Large Illustration filling virtually the entire card
          Positioned.fill(
            bottom: 18, // Leave just enough space for the small bottom badge
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    widget.card.emoji,
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
            ),
          ),
          // Word label badge overlay at bottom
          Positioned(
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                widget.card.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263238),
                ),
              ),
            ),
          ),
          // Matched Checkmark Badge
          if (widget.card.isMatched)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 13,
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
