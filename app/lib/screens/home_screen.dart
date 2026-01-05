import 'package:card_game/models/game_state.dart';
import 'package:card_game/screens/collection_screen.dart';
import 'package:card_game/screens/battle_screen.dart';
import 'package:card_game/screens/merge_screen.dart';
import 'package:card_game/screens/shop_screen.dart';
import 'package:card_game/screens/profile_screen.dart';
import 'package:card_game/screens/user_collection_screen.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'battle_preparation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Инициализируем список настоящих экранов
  final List<Widget> _screens = const [
    CollectionScreen(),
    BattlePreparationScreen(), // Заменяем BattleScreen
    ShopScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Предзагрузка данных при запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadData();
    });
  }

  void _preloadData() {
    final context = this.context;
    final gameState = Provider.of<GameState>(context, listen: false);
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    // Предзагрузка карт в фоне
    supabaseService.preloadUserCards(gameState.userId);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Индикатор уровня
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text(
                    'Ур. ${gameState.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                _buildResourceItem(context, '💰', '${gameState.gold}'),
                const SizedBox(width: 12),
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

  Widget _buildResourceItem(BuildContext context, String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
