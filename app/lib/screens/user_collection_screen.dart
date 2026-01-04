import 'package:card_game/models/card.dart';
import 'package:card_game/models/game_state.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:card_game/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCollectionScreen extends StatefulWidget {
  const UserCollectionScreen({super.key});

  @override
  State<UserCollectionScreen> createState() => _UserCollectionScreenState();
}

class _UserCollectionScreenState extends State<UserCollectionScreen> {
  List<CardModel> _userCards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserCards();
  }

  Future<void> _loadUserCards() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final supabaseService =
          Provider.of<SupabaseService>(context, listen: false);
      final gameState = context.read<GameState>();
      final cards = await supabaseService.getUserCards(gameState.userId);

      if (mounted) {
        setState(() {
          _userCards = cards;
          _isLoading = false;
          _error = null;
        });

        // Обновляем глобальное состояние
        gameState.setUserCards(cards);
      }
    } catch (e) {
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
      appBar: AppBar(
        title: const Text('Мои карты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserCards,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCards.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.collections, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'У вас пока нет карт',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Купите набор в магазине!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _userCards.length,
                  itemBuilder: (context, index) {
                    return CardWidget(card: _userCards[index]);
                  },
                ),
    );
  }
}
