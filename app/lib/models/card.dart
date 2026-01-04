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

  String get typeName {
    switch (type) {
      // Базовые типы
      case CardType.warrior:
        return 'Воин';
      case CardType.mage:
        return 'Маг';
      case CardType.archer:
        return 'Лучник';
      case CardType.assassin:
        return 'Убийца';
      case CardType.tank:
        return 'Танк';
      case CardType.support:
        return 'Поддержка';

      // Улучшенные типы
      case CardType.knight:
        return 'Рыцарь';
      case CardType.archmage:
        return 'Архимаг';
      case CardType.sniper:
        return 'Снайпер';
      case CardType.ninja:
        return 'Ниндзя';
      case CardType.juggernaut:
        return 'Джаггернаут';
      case CardType.priest:
        return 'Жрец';

      // Эпические типы
      case CardType.paladin:
        return 'Паладин';
      case CardType.sorcerer:
        return 'Чародей';
      case CardType.hawkeye:
        return 'Ястребиный глаз';
      case CardType.shadowblade:
        return 'Теневой клинок';
      case CardType.colossus:
        return 'Колосс';
      case CardType.druid:
        return 'Друид';

      // Легендарные типы
      case CardType.dragonknight:
        return 'Рыцарь-дракон';
      case CardType.phoenixmage:
        return 'Маг-феникс';
      case CardType.celestialarcher:
        return 'Небесный лучник';
      case CardType.voidassassin:
        return 'Ассасин пустоты';
      case CardType.titan:
        return 'Титан';
      case CardType.lifeweaver:
        return 'Ткач жизни';
    }
  }

  // Иконка типа карты
  String get typeIcon {
    switch (type) {
      // Базовые типы
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

      // Улучшенные типы
      case CardType.knight:
        return '⚔️👑'; // Воин с короной
      case CardType.archmage:
        return '🔮🌟'; // Маг со звездой
      case CardType.sniper:
        return '🏹🎯'; // Лучник с мишенью
      case CardType.ninja:
        return '🗡️👤'; // Ассасин с тенью
      case CardType.juggernaut:
        return '🛡️💪'; // Танк с мускулом
      case CardType.priest:
        return '❤️✨'; // Поддержка с сиянием

      // Эпические типы
      case CardType.paladin:
        return '⚔️✨👑'; // Паладин
      case CardType.sorcerer:
        return '🔮🔥🌟'; // Чародей
      case CardType.hawkeye:
        return '🏹👁️🎯'; // Ястребиный глаз
      case CardType.shadowblade:
        return '🗡️🌑👤'; // Теневой клинок
      case CardType.colossus:
        return '🛡️🗿💪'; // Колосс
      case CardType.druid:
        return '❤️🌿✨'; // Друид

      // Легендарные типы
      case CardType.dragonknight:
        return '⚔️🐉👑'; // Рыцарь-дракон
      case CardType.phoenixmage:
        return '🔮🔥🕊️'; // Маг-феникс
      case CardType.celestialarcher:
        return '🏹⭐👁️'; // Небесный лучник
      case CardType.voidassassin:
        return '🗡️⚫👤'; // Ассасин пустоты
      case CardType.titan:
        return '🛡️🏔️🗿'; // Титан
      case CardType.lifeweaver:
        return '❤️🌌✨'; // Ткач жизни
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

  CardModel copyWith({
    int? id,
    String? name,
    String? description,
    Rarity? rarity,
    CardType? type,
    int? level,
    int? attack,
    int? health,
    int? manaCost,
    String? imagePath,
  }) {
    return CardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      level: level ?? this.level,
      attack: attack ?? this.attack,
      health: health ?? this.health,
      manaCost: manaCost ?? this.manaCost,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  CardType get nextUpgradedType {
    switch (type) {
      // Базовые -> Улучшенные
      case CardType.warrior:
        return CardType.knight;
      case CardType.mage:
        return CardType.archmage;
      case CardType.archer:
        return CardType.sniper;
      case CardType.assassin:
        return CardType.ninja;
      case CardType.tank:
        return CardType.juggernaut;
      case CardType.support:
        return CardType.priest;

      // Улучшенные -> Эпические
      case CardType.knight:
        return CardType.paladin;
      case CardType.archmage:
        return CardType.sorcerer;
      case CardType.sniper:
        return CardType.hawkeye;
      case CardType.ninja:
        return CardType.shadowblade;
      case CardType.juggernaut:
        return CardType.colossus;
      case CardType.priest:
        return CardType.druid;

      // Эпические -> Легендарные
      case CardType.paladin:
        return CardType.dragonknight;
      case CardType.sorcerer:
        return CardType.phoenixmage;
      case CardType.hawkeye:
        return CardType.celestialarcher;
      case CardType.shadowblade:
        return CardType.voidassassin;
      case CardType.colossus:
        return CardType.titan;
      case CardType.druid:
        return CardType.lifeweaver;

      // Легендарные остаются легендарными (только улучшение характеристик)
      default:
        return type;
    }
  }

// Метод для определения уровня улучшения
  int get upgradeTier {
    if (type.index <= CardType.support.index) return 1; // Базовые
    if (type.index <= CardType.priest.index) return 2; // Улучшенные
    if (type.index <= CardType.druid.index) return 3; // Эпические
    return 4; // Легендарные
  }
}

enum Rarity { common, rare, epic, legendary }

enum CardType {
  // Базовые типы
  warrior,
  mage,
  archer,
  assassin,
  tank,
  support,

  // Улучшенные типы (получаются при слиянии)
  knight, // улучшенный warrior
  archmage, // улучшенный mage
  sniper, // улучшенный archer
  ninja, // улучшенный assassin
  juggernaut, // улучшенный tank
  priest, // улучшенный support

  // Эпические типы (получаются при слиянии улучшенных)
  paladin, // эпический knight
  sorcerer, // эпический archmage
  hawkeye, // эпический sniper
  shadowblade, // эпический ninja
  colossus, // эпический juggernaut
  druid, // эпический priest

  // Легендарные типы (получаются при слиянии эпических)
  dragonknight, // легендарный paladin
  phoenixmage, // легендарный sorcerer
  celestialarcher, // легендарный hawkeye
  voidassassin, // легендарный shadowblade
  titan, // легендарный colossus
  lifeweaver, // легендарный druid
}
