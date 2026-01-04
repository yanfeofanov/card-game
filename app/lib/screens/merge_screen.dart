import 'package:card_game/models/card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_game/models/game_state.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:card_game/widgets/card_widget.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  List<Map<String, dynamic>> _mergeableCards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Используем задержку для избежания одновременной загрузки нескольких экранов
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadMergeableCards();
      }
    });
  }

  Future<void> _loadMergeableCards() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final gameState = Provider.of<GameState>(context, listen: false);

      // Используем специальный метод для получения карт, доступных к объединению
      final mergeableCards =
          await supabaseService.getMergeableCards(gameState.userId);

      if (mounted) {
        setState(() {
          _mergeableCards = mergeableCards;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading mergeable cards: $e');
      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки данных: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _mergeCard(int cardId, CardType cardType, int level) async {
    try {
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final gameState = Provider.of<GameState>(context, listen: false);

      // Проверяем возможность объединения
      final canMerge = await supabaseService.canMergeCards(
        gameState.userId,
        cardId,
        cardType,
        level,
      );

      if (!canMerge) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Недостаточно карт для объединения (нужно 3 одинаковые)',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Подтверждение
      final bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Объединение карт'),
              content: const Text('Объединить 3 карты для улучшения?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Объединить'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      // Показываем индикатор
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Выполняем объединение
      final mergedCard = await supabaseService.mergeCards(
        gameState.userId,
        cardId,
        cardType,
        level,
      );

      // Закрываем индикатор
      Navigator.pop(context);

      if (mergedCard != null) {
        // ОБНОВЛЯЕМ ДАННЫЕ
        await _loadMergeableCards(); // Обновляем список карт для объединения

        // Обновляем глобальное состояние
        final updatedCards =
            await supabaseService.getUserCards(gameState.userId);
        gameState.setUserCards(updatedCards);

        // Показываем результат
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Успех!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Карты успешно объединены!'),
                const SizedBox(height: 10),
                Text('Получена карта: ${mergedCard.name}'),
                Text('Уровень: ${mergedCard.level}'),
                const SizedBox(height: 20),
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 200, maxHeight: 300),
                  child: CardWidget(card: mergedCard),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Закрываем диалог результата
                  // Можно обновить список еще раз для надежности
                  _loadMergeableCards();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Закрываем индикатор если открыт
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Объединение карт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMergeableCards,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMergeableCards,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_mergeableCards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Нет доступных объединений',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Соберите минимум 3 одинаковые карты',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'Карты группируются по:\n• ID карты\n• Типу\n• Уровню',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Сортируем по уровню (сначала высокие) и типу
    _mergeableCards.sort((a, b) {
      final levelA = a['level'] as int;
      final levelB = b['level'] as int;
      if (levelA != levelB)
        return levelB.compareTo(levelA); // Сначала высокие уровни

      final countA = a['count'] as int;
      final countB = b['count'] as int;
      if (countA != countB)
        return countB.compareTo(countA); // Затем по количеству

      final typeA = a['type'] as CardType;
      final typeB = b['type'] as CardType;
      return typeA.index.compareTo(typeB.index);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mergeableCards.length,
      itemBuilder: (context, index) {
        final data = _mergeableCards[index];
        final card = data['card'] as CardModel;
        final cardId = data['cardId'] as int;
        final type = data['type'] as CardType;
        final level = data['level'] as int;
        final count = data['count'] as int;

        final cardToShow = card.copyWith(type: type, level: level);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 90,
                      child: CardWidget(
                        card: cardToShow,
                        showDetails: false,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Уровень $level',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getTypeName(type),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Количество: $count/3',
                            style: TextStyle(
                              fontSize: 14,
                              color: count >= 3 ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: count >= 3
                        ? () => _mergeCard(cardId, type, level)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          count >= 3 ? Colors.deepPurple : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      count >= 3 ? 'ОБЪЕДИНИТЬ' : 'НЕДОСТАТОЧНО КАРТ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTypeName(CardType type) {
    switch (type) {
      case CardType.warrior:
        return 'Воин';
      case CardType.mage:
        return 'Маг';
      case CardType.archer:
        return 'Лучник';
      case CardType.assassin:
        return 'Убийца';
      case CardType.tank:
        return 'Танк';
      case CardType.support:
        return 'Поддержка';
      case CardType.knight:
        return 'Рыцарь';
      case CardType.archmage:
        return 'Архимаг';
      case CardType.sniper:
        return 'Снайпер';
      case CardType.ninja:
        return 'Ниндзя';
      case CardType.juggernaut:
        return 'Джаггернаут';
      case CardType.priest:
        return 'Жрец';
      case CardType.paladin:
        return 'Паладин';
      case CardType.sorcerer:
        return 'Чародей';
      case CardType.hawkeye:
        return 'Ястребиный глаз';
      case CardType.shadowblade:
        return 'Теневой клинок';
      case CardType.colossus:
        return 'Колосс';
      case CardType.druid:
        return 'Друид';
      case CardType.dragonknight:
        return 'Рыцарь-дракон';
      case CardType.phoenixmage:
        return 'Маг-феникс';
      case CardType.celestialarcher:
        return 'Небесный лучник';
      case CardType.voidassassin:
        return 'Ассасин пустоты';
      case CardType.titan:
        return 'Титан';
      case CardType.lifeweaver:
        return 'Ткач жизни';
    }
  }
}
