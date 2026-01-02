import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            const Text(
              'Магазин',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Баланс: ${gameState.gold} 💰  ${gameState.gems} 💎',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // Категории товаров
            const Text(
              'Наборы карт',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildShopItem(
                    title: 'Стартовый набор',
                    description: '3 случайные карты',
                    price: 'Бесплатно',
                    color: Colors.blue,
                    onTap: () => _buyPack(context, 'Стартовый набор'),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Набор новичка',
                    description: '5 карт, минимум 1 редкая',
                    price: '100 💰',
                    color: Colors.green,
                    onTap: () => _buyPack(context, 'Набор новичка'),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Эпический набор',
                    description: '10 карт, гарантированная эпическая',
                    price: '50 💎',
                    color: Colors.purple,
                    onTap: () => _buyPack(context, 'Эпический набор'),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Легендарный набор',
                    description: '15 карт, шанс на легендарную',
                    price: '100 💎',
                    color: Colors.orange,
                    onTap: () => _buyPack(context, 'Легендарный набор'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required String description,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.card_giftcard,
                    color: Colors.deepPurple, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buyPack(BuildContext context, String packName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Покупка'),
        content: Text('Вы уверены, что хотите купить "$packName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Набор "$packName" куплен!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Купить'),
          ),
        ],
      ),
    );
  }
}
