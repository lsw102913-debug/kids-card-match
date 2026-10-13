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
  easy,   // 4 cards (4x1 or 2x2)
  medium, // 6 cards (3x2)
  hard,   // 12 cards (4x3)
  expert, // 16 cards (4x4)
  master, // 20 cards (5x4)
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
      case Difficulty.expert:
        return '🌟 무지개 (16장)';
      case Difficulty.master:
        return '👑 우주 (20장)';
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
      case Difficulty.expert:
        return 16;
      case Difficulty.master:
        return 20;
    }
  }

  int get pairCount => cardCount ~/ 2;

  // Optimized for Landscape screens
  int get crossAxisCount {
    switch (this) {
      case Difficulty.easy:
        return 4; // 4x1 (Large wide layout)
      case Difficulty.medium:
        return 3; // 3x2
      case Difficulty.hard:
        return 4; // 4x3
      case Difficulty.expert:
        return 4; // 4x4
      case Difficulty.master:
        return 5; // 5x4
    }
  }
}

class GameData {
  static const List<GameThemeInfo> themes = [
    GameThemeInfo(
      category: CardCategory.dinosaurs,
      title: '쿵쾅 공룡',
      icon: '🦖',
      primaryColor: Color(0xFF81C784),
    ),
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

  // Dinosaur pool (10 items)
  static final List<CardItem> dinosaurPool = [
    CardItem(id: 0, pairId: 301, name: '티라노', emoji: '🦖', category: CardCategory.dinosaurs, cardColor: Color(0xFFA5D6A7)),
    CardItem(id: 0, pairId: 302, name: '브라키오', emoji: '🦕', category: CardCategory.dinosaurs, cardColor: Color(0xFF80CBC4)),
    CardItem(id: 0, pairId: 303, name: '트리케라', emoji: '🐊', category: CardCategory.dinosaurs, cardColor: Color(0xFFC8E6C9)),
    CardItem(id: 0, pairId: 304, name: '프테라', emoji: '🦅', category: CardCategory.dinosaurs, cardColor: Color(0xFFB0BEC5)),
    CardItem(id: 0, pairId: 305, name: '스테고', emoji: '🦎', category: CardCategory.dinosaurs, cardColor: Color(0xFFDCE775)),
    CardItem(id: 0, pairId: 306, name: '아기공룡알', emoji: '🥚', category: CardCategory.dinosaurs, cardColor: Color(0xFFFFF9C4)),
    CardItem(id: 0, pairId: 307, name: '공룡발자국', emoji: '🐾', category: CardCategory.dinosaurs, cardColor: Color(0xFFFFCCBC)),
    CardItem(id: 0, pairId: 308, name: '불타는화산', emoji: '🌋', category: CardCategory.dinosaurs, cardColor: Color(0xFFFFAB91)),
    CardItem(id: 0, pairId: 309, name: '공룡뼈화석', emoji: '🦴', category: CardCategory.dinosaurs, cardColor: Color(0xFFCFD8DC)),
    CardItem(id: 0, pairId: 310, name: '꼬마도마뱀', emoji: '🦎', category: CardCategory.dinosaurs, cardColor: Color(0xFFB2DFDB)),
  ];

  // Animal pool (10 items)
  static final List<CardItem> animalPool = [
    CardItem(id: 0, pairId: 1, name: '아기곰', emoji: '🐻', category: CardCategory.animals, cardColor: Color(0xFFFFE0B2)),
    CardItem(id: 0, pairId: 2, name: '토끼', emoji: '🐰', category: CardCategory.animals, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 3, name: '판다', emoji: '🐼', category: CardCategory.animals, cardColor: Color(0xFFE0E0E0)),
    CardItem(id: 0, pairId: 4, name: '멍멍이', emoji: '🐶', category: CardCategory.animals, cardColor: Color(0xFFFFE082)),
    CardItem(id: 0, pairId: 5, name: '야옹이', emoji: '🐱', category: CardCategory.animals, cardColor: Color(0xFFFFCCBC)),
    CardItem(id: 0, pairId: 6, name: '병아리', emoji: '🐥', category: CardCategory.animals, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 7, name: '개구리', emoji: '🐸', category: CardCategory.animals, cardColor: Color(0xFFC8E6C9)),
    CardItem(id: 0, pairId: 8, name: '코알라', emoji: '🐨', category: CardCategory.animals, cardColor: Color(0xFFB0BEC5)),
    CardItem(id: 0, pairId: 9, name: '아기사자', emoji: '🦁', category: CardCategory.animals, cardColor: Color(0xFFFFD54F)),
    CardItem(id: 0, pairId: 10, name: '꼬마원숭이', emoji: '🐵', category: CardCategory.animals, cardColor: Color(0xFFD7CCC8)),
  ];

  // Fruit pool (10 items)
  static final List<CardItem> fruitPool = [
    CardItem(id: 0, pairId: 101, name: '딸기', emoji: '🍓', category: CardCategory.fruits, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 102, name: '사과', emoji: '🍎', category: CardCategory.fruits, cardColor: Color(0xFFEF9A9A)),
    CardItem(id: 0, pairId: 103, name: '바나나', emoji: '🍌', category: CardCategory.fruits, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 104, name: '포도', emoji: '🍇', category: CardCategory.fruits, cardColor: Color(0xFFE1BEE7)),
    CardItem(id: 0, pairId: 105, name: '수박', emoji: '🍉', category: CardCategory.fruits, cardColor: Color(0xFFA5D6A7)),
    CardItem(id: 0, pairId: 106, name: '오렌지', emoji: '🍊', category: CardCategory.fruits, cardColor: Color(0xFFFFCC80)),
    CardItem(id: 0, pairId: 107, name: '체리', emoji: '🍒', category: CardCategory.fruits, cardColor: Color(0xFFF48FB1)),
    CardItem(id: 0, pairId: 108, name: '파인애플', emoji: '🍍', category: CardCategory.fruits, cardColor: Color(0xFFFFE082)),
    CardItem(id: 0, pairId: 109, name: '복숭아', emoji: '🍑', category: CardCategory.fruits, cardColor: Color(0xFFFFAB91)),
    CardItem(id: 0, pairId: 110, name: '망고', emoji: '🥭', category: CardCategory.fruits, cardColor: Color(0xFFFFE082)),
  ];

  // Vehicle pool (10 items)
  static final List<CardItem> vehiclePool = [
    CardItem(id: 0, pairId: 201, name: '경찰차', emoji: '🚓', category: CardCategory.vehicles, cardColor: Color(0xFFBBDEFB)),
    CardItem(id: 0, pairId: 202, name: '소방차', emoji: '🚒', category: CardCategory.vehicles, cardColor: Color(0xFFFFCDD2)),
    CardItem(id: 0, pairId: 203, name: '비행기', emoji: '✈️', category: CardCategory.vehicles, cardColor: Color(0xFFB3E5FC)),
    CardItem(id: 0, pairId: 204, name: '로켓', emoji: '🚀', category: CardCategory.vehicles, cardColor: Color(0xFFD1C4E9)),
    CardItem(id: 0, pairId: 205, name: '기차', emoji: '🚂', category: CardCategory.vehicles, cardColor: Color(0xFFC5CAE9)),
    CardItem(id: 0, pairId: 206, name: '버스', emoji: '🚌', category: CardCategory.vehicles, cardColor: Color(0xFFFFF59D)),
    CardItem(id: 0, pairId: 207, name: '택시', emoji: '🚕', category: CardCategory.vehicles, cardColor: Color(0xFFFFE082)),
    CardItem(id: 0, pairId: 208, name: '헬리콥터', emoji: '🚁', category: CardCategory.vehicles, cardColor: Color(0xFFB2DFDB)),
    CardItem(id: 0, pairId: 209, name: '트랙터', emoji: '🚜', category: CardCategory.vehicles, cardColor: Color(0xFFA5D6A7)),
    CardItem(id: 0, pairId: 210, name: '멋진요트', emoji: '⛵', category: CardCategory.vehicles, cardColor: Color(0xFF80DEEA)),
  ];

  static List<CardItem> generateDeck({
    required CardCategory category,
    required Difficulty difficulty,
    Random? random,
  }) {
    final rng = random ?? Random();
    List<CardItem> source;
    switch (category) {
      case CardCategory.dinosaurs:
        source = List.from(dinosaurPool);
        break;
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
      deck.add(template.copyWith(id: cardInstanceId++));
      deck.add(template.copyWith(id: cardInstanceId++));
    }

    deck.shuffle(rng);
    return deck;
  }
}
