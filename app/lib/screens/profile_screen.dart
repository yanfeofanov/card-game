import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: SafeArea(
        // Добавляем SafeArea
        child: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'Статистика',
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
                childAspectRatio: 1.3, // Изменили соотношение сторон
                children: [
                  _buildStatCard('Игр сыграно', '12', Icons.sports_esports),
                  _buildStatCard('Побед', '8', Icons.emoji_events),
                  _buildStatCard(
                      'Карт', '6', Icons.collections), // Укоротили текст
                  _buildStatCard(
                      'Дней', '1', Icons.calendar_today), // Укоротили текст
                ],
              ),
              const SizedBox(height: 16),
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
                fontSize: 11, // Уменьшили размер шрифта
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
}
