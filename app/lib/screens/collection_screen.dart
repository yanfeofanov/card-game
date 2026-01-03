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
      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final data = await supabaseService.getAllCards();

      setState(() {
        _cards = data.map((json) => CardModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCards,
                ),
              ],
            ),
          ),

          // Состояние загрузки/ошибки
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ошибка: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCards,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            )
          else if (_cards.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Нет карт в коллекции'),
              ),
            )
          else
            // Список карт
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCards,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
