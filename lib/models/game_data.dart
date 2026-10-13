import 'dart:math';
import 'package:flutter/material.dart';
import 'card_item.dart';

class GameThemeInfo {
  final CardCategory category;
  final String title;
  final String icon;
  final Color primaryColor;

  const GameThemeInfo({
    required this.category,
    required this.title,
    required this.icon,
    required this.primaryColor,
  });
}

enum Difficulty {
  easy,   // 4 cards (2x2)
  medium, // 6 cards (2x3)
  hard,   // 12 cards (3x4)
}

extension DifficultyExt on Difficulty {
  String get title {
    switch (this) {
      case Difficulty.easy:
        return '🐣 새싹 (4장)';
      case Difficulty.medium:
        return '🐥 꽃잎 (6장)';
      case Difficulty.hard:
        return '🦁 나무 (12장)';
    }
  }

  int get cardCount {
    switch (this) {
      case Difficulty.easy:
        return 4;
      case Difficulty.medium:
        return 6;
      case Difficulty.hard:
        return 12;
    }
  }

  int get pairCount => cardCount ~/ 2;

  int get crossAxisCount {
    switch (this) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }
}

class GameData {
  static const List<GameThemeInfo> themes = [
    GameThemeInfo(
      category: CardCategory.animals,
      title: '동물 친구들',
      icon: '🐻',
      primaryColor: Color(0xFFFFB6C1),
    ),
    GameThemeInfo(
      category: CardCategory.fruits,
      title: '달콤 과일',
      icon: '🍓',
      primaryColor: Color(0xFFFFD180),
    ),
    GameThemeInfo(
      category: CardCategory.vehicles,
      title: '신나는 탈것',
      icon: '🚗',
      primaryColor: Color(0xFF80D8FF),
    ),
  ];

  static final List<CardItem> animalPool = [
    CardItem(id: 0, pairId: 1, name: '아기곰', emoji: '🐻', category: CardCategory.animals, cardColor: Color(0xFFFFE0B2)),
    CardItem(id: 0, pairId: 2, name: '토끼', emoji: '🐰', category: CardCategory.animals, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 3, name: '판다', emoji: '🐼', category: CardCategory.animals, cardColor: Color(0xFFE0E0E0)),
    CardItem(id: 0, pairId: 4, name: '멍멍이', emoji: '🐶', category: CardCategory.animals, cardColor: Color(0xFFFFE082)),
    CardItem(id: 0, pairId: 5, name: '야옹이', emoji: '🐱', category: CardCategory.animals, cardColor: Color(0xFFFFCCBC)),
    CardItem(id: 0, pairId: 6, name: '병아리', emoji: '🐥', category: CardCategory.animals, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 7, name: '개구리', emoji: '🐸', category: CardCategory.animals, cardColor: Color(0xFFC8E6C9)),
    CardItem(id: 0, pairId: 8, name: '코알라', emoji: '🐨', category: CardCategory.animals, cardColor: Color(0xFFB0BEC5)),
  ];

  static final List<CardItem> fruitPool = [
    CardItem(id: 0, pairId: 101, name: '딸기', emoji: '🍓', category: CardCategory.fruits, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 102, name: '사과', emoji: '🍎', category: CardCategory.fruits, cardColor: Color(0xFFEF9A9A)),
    CardItem(id: 0, pairId: 103, name: '바나나', emoji: '🍌', category: CardCategory.fruits, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 104, name: '포도', emoji: '🍇', category: CardCategory.fruits, cardColor: Color(0xFFE1BEE7)),
    CardItem(id: 0, pairId: 105, name: '수박', emoji: '🍉', category: CardCategory.fruits, cardColor: Color(0xFFA5D6A7)),
    CardItem(id: 0, pairId: 106, name: '오렌지', emoji: '🍊', category: CardCategory.fruits, cardColor: Color(0xFFFFCC80)),
    CardItem(id: 0, pairId: 107, name: '체리', emoji: '🍒', category: CardCategory.fruits, cardColor: Color(0xFFF48FB1)),
    CardItem(id: 0, pairId: 108, name: '파인애플', emoji: '🍍', category: CardCategory.fruits, cardColor: Color(0xFFFFE082)),
  ];

  static final List<CardItem> vehiclePool = [
    CardItem(id: 0, pairId: 201, name: '경찰차', emoji: '🚓', category: CardCategory.vehicles, cardColor: Color(0xFFBBDEFB)),
    CardItem(id: 0, pairId: 202, name: '소방차', emoji: '🚒', category: CardCategory.vehicles, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 203, name: '비행기', emoji: '✈️', category: CardCategory.vehicles, cardColor: Color(0xFFB3E5FC)),
    CardItem(id: 0, pairId: 204, name: '로켓', emoji: '🚀', category: CardCategory.vehicles, cardColor: Color(0xFFD1C4E9)),
    CardItem(id: 0, pairId: 205, name: '기차', emoji: '🚂', category: CardCategory.vehicles, cardColor: Color(0xFFC5CAE9)),
    CardItem(id: 0, pairId: 206, name: '버스', emoji: '🚌', category: CardCategory.vehicles, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 207, name: '택시', emoji: '🚕', category: CardCategory.vehicles, cardColor: Color(0xFFFFE082)),
    CardItem(id: 0, pairId: 208, name: '헬리콥터', emoji: '🚁', category: CardCategory.vehicles, cardColor: Color(0xFFB2DFDB)),
  ];

  static List<CardItem> generateDeck({
    required CardCategory category,
    required Difficulty difficulty,
    Random? random,
  }) {
    final rng = random ?? Random();
    List<CardItem> source;
    switch (category) {
      case CardCategory.animals:
        source = List.from(animalPool);
        break;
      case CardCategory.fruits:
        source = List.from(fruitPool);
        break;
      case CardCategory.vehicles:
        source = List.from(vehiclePool);
        break;
    }

    source.shuffle(rng);
    final selectedPairs = source.take(difficulty.pairCount).toList();

    List<CardItem> deck = [];
    int cardInstanceId = 0;
    for (final template in selectedPairs) {
      // First card of the pair
      deck.add(template.copyWith(id: cardInstanceId++));
      // Second card of the pair
      deck.add(template.copyWith(id: cardInstanceId++));
    }

    deck.shuffle(rng);
    return deck;
  }
}
