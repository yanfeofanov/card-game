import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/supabase_service.dart';
import '../screens/pack_opening_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

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
              'Баланс: ${gameState.gold} 💰 ${gameState.gems} 💎',
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
                    canAfford: true,
                    onTap: () => _buyPack(
                        context, 'Стартовый набор', gameState, supabaseService),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Набор новичка',
                    description: '5 карт, минимум 1 редкая',
                    price: '100 💰',
                    color: Colors.green,
                    canAfford: gameState.gold >= 100,
                    onTap: () => _buyPack(
                        context, 'Набор новичка', gameState, supabaseService),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Эпический набор',
                    description: '10 карт, гарантированная эпическая',
                    price: '50 💎',
                    color: Colors.purple,
                    canAfford: gameState.gems >= 50,
                    onTap: () => _buyPack(
                        context, 'Эпический набор', gameState, supabaseService),
                  ),
                  const SizedBox(height: 16),
                  _buildShopItem(
                    title: 'Легендарный набор',
                    description: '15 карт, шанс на легендарную',
                    price: '100 💎',
                    color: Colors.orange,
                    canAfford: gameState.gems >= 100,
                    onTap: () => _buyPack(context, 'Легендарный набор',
                        gameState, supabaseService),
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
    required bool canAfford,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: canAfford ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Opacity(
            opacity: canAfford ? 1.0 : 0.5,
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
                    color: canAfford
                        ? color.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: canAfford ? color : Colors.grey,
                    ),
                  ),
                  child: Text(
                    price,
                    style: TextStyle(
                      color: canAfford ? color : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _buyPack(
    BuildContext context,
    String packName,
    GameState gameState,
    SupabaseService supabaseService,
  ) async {
    // Проверяем баланс
    switch (packName) {
      case 'Набор новичка':
        if (gameState.gold < 100) {
          _showErrorDialog(context, 'Недостаточно золота!');
          return;
        }
        break;
      case 'Эпический набор':
        if (gameState.gems < 50) {
          _showErrorDialog(context, 'Недостаточно алмазов!');
          return;
        }
        break;
      case 'Легендарный набор':
        if (gameState.gems < 100) {
          _showErrorDialog(context, 'Недостаточно алмазов!');
          return;
        }
        break;
    }

    // Подтверждение покупки
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Покупка'),
            content: Text('Вы уверены, что хотите купить "$packName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Купить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Совершаем покупку
      final purchase = await supabaseService.purchasePack(
        packName,
        gameState.userId,

        /// userId - нужно будет заменить на реальный ID пользователя
      );

      // Обновляем баланс
      switch (packName) {
        case 'Набор новичка':
          gameState.spendGold(100);
          break;
        case 'Эпический набор':
          gameState.spendGems(50);
          break;
        case 'Легендарный набор':
          gameState.spendGems(100);
          break;
      }

      // Закрываем индикатор
      Navigator.pop(context);

      // Добавляем покупку в историю
      gameState.addPurchase(purchase);

      // Показываем экран открытия карт
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PackOpeningScreen(
            purchase: purchase,
            onComplete: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Набор "$packName" успешно открыт!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Закрываем индикатор
      _showErrorDialog(context, 'Ошибка при покупке: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
