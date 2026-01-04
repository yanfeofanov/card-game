import 'package:card_game/models/card.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool compact;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showDetails = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: compact ? 2 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          side: BorderSide(
            color: Color(card.rarityColor),
            width: compact ? 1.0 : 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 8 : 12),
            color: Color(card.rarityColor).withOpacity(0.05),
          ),
          child: Column(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              // Верхняя часть карты (упрощенная)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 4 : 8, // Уменьшили padding
                  vertical: compact ? 2 : 6, // Уменьшили padding
                ),
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(compact ? 8 : 12),
                    topRight: Radius.circular(compact ? 8 : 12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Уровень карты
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 20 : 30, // Ограничиваем ширину
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 2 : 4, // Уменьшили padding
                        vertical: compact ? 0 : 1, // Уменьшили padding
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(compact ? 3 : 4), // Уменьшили радиус
                      ),
                      child: FittedBox( // Используем FittedBox для масштабирования текста
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Lv.${card.level}',
                          style: TextStyle(
                            color: Color(card.rarityColor),
                            fontWeight: FontWeight.bold,
                            fontSize: compact ? 7 : 9, // Уменьшили размер шрифта
                          ),
                        ),
                      ),
                    ),
                    // Тип карты
                    Expanded( // Используем Expanded для иконки
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: FittedBox( // Используем FittedBox для иконки
                          fit: BoxFit.scaleDown,
                          child: Text(
                            card.typeIcon,
                            style: TextStyle(fontSize: compact ? 10 : 12), // Уменьшили размер
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Название карты
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 4 : 6, // Уменьшили padding
                  vertical: compact ? 2 : 4, // Уменьшили padding
                ),
                child: FittedBox( // Используем FittedBox для названия
                  fit: BoxFit.scaleDown,
                  child: Text(
                    card.name,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14, // Уменьшили размер шрифта
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Изображение карты (упрощенная заглушка)
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: compact ? 4 : 6), // Уменьшили margin
                  decoration: BoxDecoration(
                    color: Color(card.rarityColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(compact ? 4 : 6), // Уменьшили радиус
                    border: Border.all(
                      color: Color(card.rarityColor).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(card.type),
                      size: compact ? 24 : 32, // Уменьшили размер иконки
                      color: Color(card.rarityColor).withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              // Статистика карты (только если showDetails = true)
              if (showDetails) ..._buildStats(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStats() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 2 : 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('⚔️', '${card.attack}'),
            _buildStat('❤️', '${card.health}'),
            _buildStat('🌀', '${card.manaCost}'),
          ],
        ),
      ),
      // Кнопка улучшения (только если есть обработчик)
      if (onTap != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(card.rarityColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const Text(
                'УЛУЧШИТЬ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildStat(String icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: compact ? 12 : 14),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(CardType type) {
    switch (type) {
      // Базовые типы
      case CardType.warrior:
        return Icons.security;
      case CardType.mage:
        return Icons.auto_awesome;
      case CardType.archer:
        return Icons.arrow_circle_up;
      case CardType.assassin:
        return Icons.nightlight_round;
      case CardType.tank:
        return Icons.shield;
      case CardType.support:
        return Icons.favorite;
      // Улучшенные типы
      case CardType.knight:
        return Icons.king_bed;
      case CardType.archmage:
        return Icons.stars;
      case CardType.sniper:
        return Icons.center_focus_strong;
      case CardType.ninja:
        return Icons.person_outline;
      case CardType.juggernaut:
        return Icons.fitness_center;
      case CardType.priest:
        return Icons.spa;
      // Эпические типы
      case CardType.paladin:
        return Icons.gavel;
      case CardType.sorcerer:
        return Icons.whatshot;
      case CardType.hawkeye:
        return Icons.remove_red_eye;
      case CardType.shadowblade:
        return Icons.dark_mode;
      case CardType.colossus:
        return Icons.landscape;
      case CardType.druid:
        return Icons.eco;
      // Легендарные типы
      case CardType.dragonknight:
        return Icons.pets;
      case CardType.phoenixmage:
        return Icons.local_fire_department;
      case CardType.celestialarcher:
        return Icons.wb_twilight;
      case CardType.voidassassin:
        return Icons.circle_outlined;
      case CardType.titan:
        return Icons.terrain;
      case CardType.lifeweaver:
        return Icons.filter_vintage;
    }
  }
}