import 'package:card_game/models/card.dart';
import 'package:card_game/models/game_state.dart';
import 'package:card_game/services/cache_service.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:card_game/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<CardModel> _cards = [];
  bool _isLoading = true;
  String? _error;
  bool _isSupabaseInitialized = false;

  @override
  void initState() {
    super.initState();

    // Ждем инициализации Supabase
    _checkSupabaseAndLoadCards();
  }

  Future<void> _checkSupabaseAndLoadCards() async {
    // Даем время на инициализацию
    await Future.delayed(const Duration(milliseconds: 500));

    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    // Проверяем, инициализирован ли Supabase
    try {
      // Простая проверка через клиент
      final client = supabaseService.client;
      _isSupabaseInitialized = true;

      // Загружаем карты
      _loadCards();
    } catch (e) {
      print('⚠️ Supabase не инициализирован, используем кэш');
      setState(() {
        _error = 'Используем кэшированные данные. Сеть недоступна.';
        _isLoading = false;
      });

      // Пробуем загрузить из кэша
      _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final gameState = Provider.of<GameState>(context, listen: false);
      final cacheService = CacheService();

      final cachedCards = await cacheService.getUserCards(gameState.userId);

      if (mounted) {
        setState(() {
          _cards = cachedCards;
          _isLoading = false;
          _error = cachedCards.isEmpty
              ? 'Кэш пуст. Подключитесь к сети для загрузки карт.'
              : 'Используем кэшированные данные (${cachedCards.length} карт)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить данные. Проверьте подключение.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCards() async {
    if (!_isSupabaseInitialized) {
      await _loadFromCache();
      return;
    }

    try {
      print('🔄 CollectionScreen: Загружаем карты...');
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);

      print('📡 Делаем запрос к базе данных...');
      final data = await supabaseService.getAllCards();

      print('✅ Получено данных: ${data.length} записей');

      if (!mounted) return;

      final List<CardModel> cards = [];
      for (var json in data) {
        try {
          final card = CardModel.fromJson(json);
          cards.add(card);
        } catch (e) {
          print('❌ Ошибка преобразования карты: $e');
        }
      }

      print('🎉 Успешно преобразовано ${cards.length} карт');

      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки карт: $e');

      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки: $e';
          _isLoading = false;
        });

        // Пробуем загрузить из кэша при ошибке
        await _loadFromCache();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Заголовок и кнопка обновления
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
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCards,
                  tooltip: 'Обновить',
                ),
              ],
            ),
          ),

          // Показываем статус инициализации
          if (!_isSupabaseInitialized && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Загружаем кэшированные данные...',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Состояние загрузки
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text('Загружаем коллекцию карт...'),
                    const SizedBox(height: 10),
                    Text('${_cards.length} карт загружено'),
                  ],
                ),
              ),
            )

          // Состояние ошибки
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    const Text(
                      'Ошибка загрузки',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadCards,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            )

          // Коллекция пуста
          else if (_cards.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.collections, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'Коллекция пуста',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Карты не найдены в базе данных',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadCards,
                      child: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
            )

          // Отображение карт
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    // Ленивая загрузка карточек
                    return FutureBuilder(
                      future: Future.microtask(() => _cards[index]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CardWidget(card: snapshot.data!);
                        }
                        return const SizedBox(
                          width: 100,
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCards,
        child: const Icon(Icons.refresh),
        tooltip: 'Обновить коллекцию',
      ),
    );
  }
}
