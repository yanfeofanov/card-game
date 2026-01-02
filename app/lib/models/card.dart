class CardModel {
  final int id;
  final String name;
  final String description;
  final Rarity rarity;
  final CardType type;
  final int level;
  final int attack;
  final int health;
  final int manaCost;
  final String imagePath;

const CardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.type,
    this.level = 1,
    required this.attack,
    required this.health,
    required this.manaCost,
    required this.imagePath,
  });

  // Цвет карты в зависимости от редкости
  int get rarityColor {
    switch (rarity) {
      case Rarity.common:
        return 0xFF9E9E9E; // Серый
      case Rarity.rare:
        return 0xFF2196F3; // Синий
      case Rarity.epic:
        return 0xFF9C27B0; // Фиолетовый
      case Rarity.legendary:
        return 0xFFFF9800; // Оранжевый
    }
  }

  // Иконка типа карты
  String get typeIcon {
    switch (type) {
      case CardType.warrior:
        return '⚔️';
      case CardType.mage:
        return '🔮';
      case CardType.archer:
        return '🏹';
      case CardType.assassin:
        return '🗡️';
      case CardType.tank:
        return '🛡️';
      case CardType.support:
        return '❤️';
    }
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      rarity: Rarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
        orElse: () => Rarity.common,
      ),
      type: CardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CardType.warrior,
      ),
      level: json['level'] ?? 1,
      attack: json['attack'],
      health: json['health'],
      manaCost: json['mana_cost'] ?? 2,
      imagePath: json['image_path'] ?? 'assets/cards/default.png',
    );
  }
}

enum Rarity { common, rare, epic, legendary }

enum CardType { warrior, mage, archer, assassin, tank, support }
