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
      duration: const Duration(milliseconds: 380),
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
            ..setEntry(3, 2, 0.002) // 3D perspective
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

  // Card Front (Showing Animal/Fruit/Vehicle)
  Widget _buildFrontSide() {
    return Container(
      decoration: BoxDecoration(
        color: widget.card.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.card.isMatched ? Colors.green.shade400 : Colors.white,
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.card.isMatched
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big cute emoji
              Text(
                widget.card.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 6),
              // Word label badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.card.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
              ),
            ],
          ),
          if (widget.card.isMatched)
            Positioned(
              top: 6,
              right: 6,
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

  // Card Back (Hidden, kid-friendly mystery card)
  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFC1E3), // Soft candy pink
            Color(0xFFB3E5FC), // Soft baby blue
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white,
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF80AB).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
