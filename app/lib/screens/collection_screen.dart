import 'package:card_game/models/card.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      print('🔄 CollectionScreen: Загружаем карты...');
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      print('📡 Делаем запрос к базе данных...');
      final data = await supabaseService.getAllCards();
      print('✅ Получено данных: ${data.length} записей');

      // Проверяем, не был ли виджет уничтожен
      if (!mounted) return;

      // Преобразуем данные в модели карт
      final List<CardModel> cards = [];
      for (var json in data) {
        try {
          final card = CardModel.fromJson(json);
          cards.add(card);
        } catch (e) {
          print('❌ Ошибка преобразования карты: $e');
          print('❌ Данные: $json');
        }
      }

      print('🎉 Успешно преобразовано ${cards.length} карт');

      // Проверяем mounted перед setState
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки карт: $e');

      // Проверяем mounted перед setState
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
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
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return CardWidget(card: _cards[index]);
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
