import 'package:card_game/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    // Используем FutureBuilder для загрузки статистики карт
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: Provider.of<SupabaseService>(context, listen: false)
              .getUserCardStats(gameState.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }

            final stats = snapshot.data ?? {};

            // Извлекаем данные статистики
            final totalCards = stats['totalCards'] as int? ?? 0;
            final uniqueCards = stats['uniqueCards'] as int? ?? 0;
            final totalAttack = stats['totalAttack'] as int? ?? 0;
            final totalHealth = stats['totalHealth'] as int? ?? 0;
            final avgAttack =
                (stats['avgAttack'] as double? ?? 0).toStringAsFixed(1);
            final avgHealth =
                (stats['avgHealth'] as double? ?? 0).toStringAsFixed(1);

            final rarityStats =
                stats['rarityStats'] as Map<String, dynamic>? ?? {};
            final commonCards = rarityStats['common'] as int? ?? 0;
            final rareCards = rarityStats['rare'] as int? ?? 0;
            final epicCards = rarityStats['epic'] as int? ?? 0;
            final legendaryCards = rarityStats['legendary'] as int? ?? 0;

            final mergeableCards = stats['mergeableCards'] as List? ?? [];
            final mergeableCount = mergeableCards.length;

            return SingleChildScrollView(
              // Добавляем прокрутку
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Профиль пользователя
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40, // Уменьшили радиус
                            backgroundColor: Colors.deepPurple.shade100,
                            child: const Icon(
                              Icons.person,
                              size: 40, // Уменьшили размер иконки
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            gameState.playerName,
                            style: const TextStyle(
                              fontSize: 20, // Уменьшили размер шрифта
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Уровень ${gameState.level}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Прогресс уровня
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Опыт',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${gameState.exp}/${gameState.level * 100}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: gameState.exp / (gameState.level * 100),
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.deepPurple,
                                minHeight: 6, // Уменьшили высоту
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Статистика
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Статистика карт',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                          'Всего карт', '$totalCards', Icons.collections),
                      _buildStatCard(
                          'Уникальных карт', '$uniqueCards', Icons.filter_list),
                      _buildStatCard('Игр сыграно', '12', Icons.sports_esports),
                      _buildStatCard('Побед', '8', Icons.emoji_events),
                    ],
                  ),
                  // Настройки
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings, size: 22),
                          title: const Text(
                            'Настройки',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            // TODO: Настройки
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        ListTile(
                          leading: const Icon(Icons.help, size: 22),
                          title: const Text(
                            'Помощь',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            // TODO: Помощь
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        ListTile(
                          leading: const Icon(Icons.info, size: 22),
                          title: const Text(
                            'О приложении',
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Отступ снизу
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('О приложении'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Game'),
          SizedBox(height: 6),
          Text('Версия: 1.0.0'),
          SizedBox(height: 6),
          Text('Карточная игра с прокачкой карт и PvP боями.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
