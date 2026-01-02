import 'package:card_game/models/card.dart';
import 'package:card_game/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  final List<CardModel> _cards = const [
    CardModel(
      id: 1,
      name: 'Воин',
      description: 'Базовый боец с хорошей атакой',
      rarity: Rarity.common,
      type: CardType.warrior,
      level: 1,
      attack: 5,
      health: 10,
      manaCost: 2,
      imagePath: 'assets/cards/warrior.png',
    ),
    CardModel(
      id: 2,
      name: 'Маг',
      description: 'Сильный маг с магической атакой',
      rarity: Rarity.rare,
      type: CardType.mage,
      level: 1,
      attack: 8,
      health: 6,
      manaCost: 3,
      imagePath: 'assets/cards/mage.png',
    ),
    CardModel(
      id: 3,
      name: 'Лучник',
      description: 'Меткий стрелок с дальним боем',
      rarity: Rarity.common,
      type: CardType.archer,
      level: 2,
      attack: 7,
      health: 8,
      manaCost: 2,
      imagePath: 'assets/cards/archer.png',
    ),
    CardModel(
      id: 4,
      name: 'Ассассин',
      description: 'Скрытный убийца с критическим уроном',
      rarity: Rarity.epic,
      type: CardType.assassin,
      level: 1,
      attack: 12,
      health: 4,
      manaCost: 4,
      imagePath: 'assets/cards/assassin.png',
    ),
    CardModel(
      id: 5,
      name: 'Танк',
      description: 'Защитник с высоким здоровьем',
      rarity: Rarity.common,
      type: CardType.tank,
      level: 3,
      attack: 4,
      health: 18,
      manaCost: 3,
      imagePath: 'assets/cards/tank.png',
    ),
    CardModel(
      id: 6,
      name: 'Жрец',
      description: 'Лекарь с целительными способностями',
      rarity: Rarity.rare,
      type: CardType.support,
      level: 2,
      attack: 5,
      health: 10,
      manaCost: 3,
      imagePath: 'assets/cards/priest.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Заголовок и фильтры
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Коллекция карт',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Показать фильтры
                  },
                ),
              ],
            ),
          ),

          // Список карт
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // Уменьшите это значение
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return CardWidget(
                    card: _cards[index]); // Убедитесь, что нет лишних анимаций
              },
            ),
          ),
        ],
      ),
    );
  }
}
