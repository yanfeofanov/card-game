import 'package:card_game/models/card.dart';
import 'package:card_game/models/game_state.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:card_game/widgets/card_widget.dart';
import 'package:card_game/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'battle_screen.dart';

class BattlePreparationScreen extends StatefulWidget {
  const BattlePreparationScreen({super.key});

  @override
  State<BattlePreparationScreen> createState() =>
      _BattlePreparationScreenState();
}

class _BattlePreparationScreenState extends State<BattlePreparationScreen> {
  List<CardModel> _availableCards = [];
  List<CardModel> _selectedCards = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Загружаем карты при создании экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadCards();
      _loadUserCards();
    });
  }

  Future<void> _preloadCards() async {
    // Предзагрузка в фоне для мгновенного отображения
    final gameState = Provider.of<GameState>(context, listen: false);
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    // Запускаем в фоне без ожидания
    supabaseService.preloadUserCards(gameState.userId);
  }

  Future<void> _loadUserCards() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final gameState = Provider.of<GameState>(context, listen: false);

      print('🔄 Загрузка карт (с кэшем)...');

      // Сначала пробуем из кэша для мгновенного отображения
      final cacheService = CacheService();
      final cachedCards = await cacheService.getUserCards(gameState.userId);

      if (cachedCards.isNotEmpty && mounted) {
        setState(() {
          _availableCards = cachedCards;
        });
      }

      // Затем пытаемся обновить из сети (если Supabase доступен)
      if (supabaseService.isInitialized) {
        final cards =
            await supabaseService.getUserCardsWithCache(gameState.userId);

        if (mounted) {
          setState(() {
            _availableCards = cards;
            _isLoading = false;
          });
        }
      } else {
        // Используем только кэш
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = cachedCards.isEmpty
                ? 'Нет доступных карт. Подключитесь к сети.'
                : null;
          });
        }
      }
    } catch (e) {
      print('❌ Ошибка загрузки карт: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Не удалось загрузить карты. Проверьте подключение.';
        });
      }
    }
  }

  void _selectCard(CardModel card) {
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else if (_selectedCards.length < 5) {
        _selectedCards.add(card);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Максимум 5 карт для боя'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _removeCard(CardModel card) {
    setState(() {
      _selectedCards.remove(card);
    });
  }

  void _reorderCard(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final card = _selectedCards.removeAt(oldIndex);
      _selectedCards.insert(newIndex, card);
    });
  }

  void _startBattle() {
    if (_selectedCards.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нужно выбрать 5 карт для боя'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Переходим к бою
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(
          playerCards: _selectedCards,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Загружаем ваши карты...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Неизвестная ошибка',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserCards,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.collections, color: Colors.grey, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Нет доступных карт',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'У вас пока нет карт. Купите набор в магазине!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Переход в магазин
                Navigator.pop(context);
              },
              child: const Text('В магазин'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGrid() {
    if (_availableCards.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6,
      ),
      itemCount: _availableCards.length,
      itemBuilder: (context, index) {
        final card = _availableCards[index];
        final isSelected = _selectedCards.contains(card);

        return GestureDetector(
          onTap: () => _selectCard(card),
          child: Stack(
            children: [
              CardWidget(
                card: card,
                compact: true,
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подготовка к бою'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUserCards,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Выбранные карты
          Container(
            height: 120,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                const Text(
                  'Ваша колода (5 карт)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _selectedCards.isEmpty
                      ? const Center(
                          child: Text(
                            'Выберите 5 карт из списка ниже',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedCards.length,
                          itemBuilder: (context, index) {
                            final card = _selectedCards[index];
                            return Container(
                              key: Key('selected_${card.id}_$index'),
                              width: 70,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  CardWidget(
                                    card: card,
                                    compact: true,
                                    onTap: () => _removeCard(card),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeCard(card),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      color: Colors.blue.shade800,
                                      child: Text(
                                        '${index + 1}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onReorder: _reorderCard,
                        ),
                ),
              ],
            ),
          ),

          // Информация
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Выберите 5 карт и определите порядок атаки. Карты атакуют по очереди.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Доступные карты или состояние загрузки/ошибки
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _isLoading
                  ? _buildLoadingState()
                  : _hasError
                      ? _buildErrorState()
                      : _buildCardGrid(),
            ),
          ),

          // Кнопка начала боя
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedCards.length == 5 ? _startBattle : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCards.length == 5
                      ? Colors.deepPurple
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'НАЧАТЬ БОЙ (${_selectedCards.length}/5)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
