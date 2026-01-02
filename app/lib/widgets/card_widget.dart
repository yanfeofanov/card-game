import 'package:card_game/models/card.dart';
import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final bool showDetails;

  const CardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3, // Уменьшили elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Уменьшили радиус
          side: BorderSide(
            color: Color(card.rarityColor),
            width: 1.5, // Уменьшили ширину
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                Color(card.rarityColor).withOpacity(0.05), // Упростили градиент
          ),
          child: Column(
            children: [
              // Верхняя часть карты (упрощенная)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Уровень карты
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lv.${card.level}',
                        style: TextStyle(
                          color: Color(card.rarityColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    // Тип карты
                    Text(
                      card.typeIcon,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Название карты
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  card.name,
                  style: const TextStyle(
                    fontSize: 16, // Уменьшили размер шрифта
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Изображение карты (упрощенная заглушка)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Color(card.rarityColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(card.rarityColor).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(card.type),
                      size: 40, // Уменьшили размер иконки
                      color: Color(card.rarityColor).withOpacity(0.7),
                    ),
                  ),
                ),
              ),

              // Статистика карты (только если showDetails = true)
              if (showDetails) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                if (showDetails && onTap != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(card.rarityColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        child: const Text(
                          'УЛУЧШИТЬ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(CardType type) {
    switch (type) {
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
      default:
        return Icons.help;
    }
  }

  Widget _buildStat(String icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
