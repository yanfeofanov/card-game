import 'package:card_game/models/game_state.dart';
import 'package:card_game/screens/collection_screen.dart';
import 'package:card_game/screens/battle_screen.dart';
import 'package:card_game/screens/merge_screen.dart';
import 'package:card_game/screens/shop_screen.dart';
import 'package:card_game/screens/profile_screen.dart';
import 'package:card_game/screens/user_collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Инициализируем список настоящих экранов
  final List<Widget> _screens = [
    const CollectionScreen(),
    const BattleScreen(),
    const ShopScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strange Battle'),
        actions: [
          // Кнопка для перехода в коллекцию пользователя
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserCollectionScreen(),
                ),
              );
            },
            tooltip: 'Мои карты',
          ),
          IconButton(
            icon: const Icon(Icons.merge),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MergeScreen(),
                ),
              );
            },
            tooltip: 'Объединение карт',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildResourceItem('💰', '${gameState.gold}'),
                const SizedBox(width: 12),
                _buildResourceItem('💎', '${gameState.gems}'),
              ],
            ),
          )
        ],
      ),
      body: _screens[_selectedIndex], // Отображаем выбранный экран
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Коллекция',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Бой',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Магазин',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildResourceItem(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
