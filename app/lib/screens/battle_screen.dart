import 'package:flutter/material.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Добавляем SafeArea
        child: SingleChildScrollView(
          // Добавляем прокрутку
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Заголовок
              const Text(
                'Режимы боя',
                style: TextStyle(
                  fontSize: 24, // Уменьшили размер шрифта
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Выберите тип сражения',
                style: TextStyle(
                  fontSize: 14, // Уменьшили размер шрифта
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Кнопки режимов
              _buildBattleModeCard(
                title: 'БЫСТРЫЙ БОЙ',
                subtitle: 'Сразитесь со случайным противником',
                icon: Icons.flash_on,
                color: Colors.blue,
                onTap: () {
                  _showComingSoon(context, 'Быстрый бой');
                },
              ),
              const SizedBox(height: 12),
              _buildBattleModeCard(
                title: 'РЕЙТИНГОВЫЙ',
                subtitle: 'Поднимитесь в таблице лидеров',
                icon: Icons.leaderboard,
                color: Colors.orange,
                onTap: () {
                  _showComingSoon(context, 'Рейтинговый бой');
                },
              ),
              const SizedBox(height: 12),
              _buildBattleModeCard(
                title: 'ТУРНИР',
                subtitle: 'Участвуйте в турнирах за награды',
                icon: Icons.emoji_events,
                color: Colors.purple,
                onTap: () {
                  _showComingSoon(context, 'Турниры');
                },
              ),
              const SizedBox(height: 24),
              // Текущие бои
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Активные бои',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        radius: 20, // Уменьшили размер
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.person,
                            color: Colors.green, size: 20),
                      ),
                      title: const Text(
                        'Игрок #1',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Ход: ваш',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: const Text(
                          'В процессе',
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.blue.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        visualDensity: VisualDensity.compact, // Компактный вид
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(Icons.person,
                            color: Colors.red, size: 20),
                      ),
                      title: const Text(
                        'Игрок #2',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Ожидание хода',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: const Text(
                          'Ожидание',
                          style: TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.orange.shade100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
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

  Widget _buildBattleModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скоро будет!'),
        content: Text('Функция "$feature" находится в разработке'),
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
