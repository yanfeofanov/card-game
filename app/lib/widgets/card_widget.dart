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
    if (compact) {
      return _buildUltraCompactCard();
    } else {
      return _buildNormalCard(context);
    }
  }

  Widget _buildUltraCompactCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: Color(card.rarityColor),
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          // Добавляем прокрутку
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Верхняя часть - уровень и редкость
              Container(
                height: 14,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lv${card.level}',
                      style: TextStyle(
                        color: Color(card.rarityColor),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMiniTypeIcon(card.type),
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              // Название карты
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Center(
                  child: Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Иконка типа
              Container(
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  _getTypeIcon(card.type),
                  size: 14,
                  color: Color(card.rarityColor),
                ),
              ),

              // Статистика (только если showDetails)
              if (showDetails) _buildUltraCompactStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltraCompactStats() {
    return Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 7)),
              Text(
                '${card.attack}',
                style: const TextStyle(
                  fontSize: 6,
                  height: 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('❤️', style: TextStyle(fontSize: 8)),
              Text(
                '${card.health}',
                style: const TextStyle(
                  fontSize: 5, // Уменьшаем до 5
                  fontWeight: FontWeight.bold,
                  height: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color(card.rarityColor),
            width: 1.5,
          ),
        ),
        // Используем цвет карты из темы
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 180,
            maxHeight: 220,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Верхняя часть карты
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(card.rarityColor).withOpacity(0.1),
                      Color(card.rarityColor).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Уровень карты
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lv.${card.level}',
                        style: TextStyle(
                          color: Color(card.rarityColor),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Тип карты
                    Text(
                      card.typeIcon,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Название карты
              Text(
                card.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Изображение карты
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Color(card.rarityColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(card.rarityColor).withOpacity(0.3),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(card.rarityColor).withOpacity(0.05),
                      Color(card.rarityColor).withOpacity(0.15),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(card.type),
                    size: 36,
                    color: Color(card.rarityColor).withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Статистика карты
              if (showDetails)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNormalStats(context),
                ),

              // Кнопка улучшения
              if (onTap != null && showDetails)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: _buildUpgradeButton(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalStats(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('⚔️', '${card.attack}', 16, 14),
          _buildStat('❤️', '${card.health}', 16, 14),
          _buildStat('🌀', '${card.manaCost}', 16, 14),
        ],
      ),
    );
  }

  Widget _buildStat(
      String icon, String value, double iconSize, double textSize) {
    return Container(
      height: 50, // Фиксированная высота
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: iconSize),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(card.rarityColor),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 2,
          ),
          child: Text(
            'УЛУЧШИТЬ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // Мини-иконка типа для ультра-компактного режима
  String _getMiniTypeIcon(CardType type) {
    switch (type) {
      case CardType.warrior:
      case CardType.knight:
      case CardType.paladin:
      case CardType.dragonknight:
        return '⚔️';
      case CardType.mage:
      case CardType.archmage:
      case CardType.sorcerer:
      case CardType.phoenixmage:
        return '🔮';
      case CardType.archer:
      case CardType.sniper:
      case CardType.hawkeye:
      case CardType.celestialarcher:
        return '🏹';
      case CardType.assassin:
      case CardType.ninja:
      case CardType.shadowblade:
      case CardType.voidassassin:
        return '🗡️';
      case CardType.tank:
      case CardType.juggernaut:
      case CardType.colossus:
      case CardType.titan:
        return '🛡️';
      case CardType.support:
      case CardType.priest:
      case CardType.druid:
      case CardType.lifeweaver:
        return '❤️';
    }
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
