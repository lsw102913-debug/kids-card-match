import 'package:flutter/material.dart';

enum CardCategory {
  animals,
  fruits,
  vehicles,
  dinosaurs,
}

class CardItem {
  final int id;
  final int pairId;
  final String name;
  final String emoji;
  final CardCategory category;
  final Color cardColor;
  bool isFaceUp;
  bool isMatched;

  CardItem({
    required this.id,
    required this.pairId,
    required this.name,
    required this.emoji,
    required this.category,
    required this.cardColor,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  CardItem copyWith({
    int? id,
    int? pairId,
    String? name,
    String? emoji,
    CardCategory? category,
    Color? cardColor,
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return CardItem(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      cardColor: cardColor ?? this.cardColor,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
